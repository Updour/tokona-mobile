import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/data/daos/sale_dao.dart';
import 'package:tokona/features/pos/data/daos/sale_item_dao.dart';
import 'package:tokona/features/pos/domain/dtos/create_sale_dto.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/product/data/daos/stock_mutation_dao.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return SaleRepository(
    appDatabase: appDb,
    saleDao: const SaleDao(),
    saleItemDao: const SaleItemDao(),
  );
});

class SaleRepository {
  final AppDatabase appDatabase;
  final SaleDao saleDao;
  final SaleItemDao saleItemDao;

  const SaleRepository({
    required this.appDatabase,
    required this.saleDao,
    required this.saleItemDao,
  });

  Future<SaleModel> recordSale(CreateSaleDto dto) async {
    final validationError = dto.validate();
    if (validationError != null) throw ArgumentError(validationError);

    final db = await appDatabase.database;
    final now = DateTime.now();
    final saleId = IdGenerator.generateId(prefix: 'INV');
    final invoiceNumber = _generateInvoiceNumber(now);

    return await db.transaction<SaleModel>((txn) async {
      final saleModel = SaleModel(
        id: saleId,
        storeId: dto.storeId,
        userId: dto.userId,
        customerId: dto.customerId,
        invoiceNumber: invoiceNumber,
        customerName: dto.customerName?.trim().isEmpty == true ? null : dto.customerName?.trim(),
        totalAmount: dto.totalAmount,
        discountAmount: dto.discountAmount,
        finalAmount: dto.finalAmount,
        cashPaid: dto.cashPaid,
        changeAmount: dto.changeAmount,
        paymentMethod: dto.paymentMethod,
        status: 'COMPLETED',
        notes: dto.notes?.trim().isEmpty == true ? null : dto.notes?.trim(),
        imagePath: dto.imagePath,
        dueDate: dto.dueDate,
        items: const [],
        createdAt: now,
        updatedAt: now,
      );

      await saleDao.insert(txn, saleModel);

      final List<SaleItemModel> itemModels = [];
      for (final itemDto in dto.items) {
        final productRows = await txn.query(
          DatabaseTables.products,
          where: '${DatabaseTables.columnId} = ?',
          whereArgs: [itemDto.productId],
          limit: 1,
        );

        if (productRows.isEmpty) {
          throw StateError('Produk dengan ID ${itemDto.productId} tidak ditemukan.');
        }

        final product = ProductModel.fromMap(productRows.first);
        final double baseDeduct = itemDto.totalBaseQuantity;

        if (product.stockBase < baseDeduct) {
          throw StateError(
            'Stok ${product.name} tidak cukup (sisa ${product.stockBase.toStringAsFixed(0)} ${product.baseUnit})',
          );
        }

        final double newStock = product.stockBase - baseDeduct;
        await txn.update(
          DatabaseTables.products,
          {
            DatabaseTables.columnProductStockBase: newStock,
            DatabaseTables.columnUpdatedAt: now.toIso8601String(),
          },
          where: '${DatabaseTables.columnId} = ?',
          whereArgs: [product.id],
        );

        final mutationId = IdGenerator.generateId(prefix: 'MUT');
        await const StockMutationDao().insert(
          txn,
          StockMutationModel(
            id: mutationId,
            storeId: dto.storeId,
            productId: product.id,
            productName: product.name,
            type: 'out',
            quantity: baseDeduct,
            previousStock: product.stockBase,
            currentStock: newStock,
            reason: 'sale',
            referenceId: invoiceNumber,
            notes: 'Penjualan Kasir ($invoiceNumber)',
            createdAt: now,
          ),
        );

        final itemId = IdGenerator.generateId(prefix: 'SLI');
        final itemModel = SaleItemModel(
          id: itemId,
          saleId: saleId,
          productId: itemDto.productId,
          productName: product.name,
          unitId: itemDto.unitId,
          unitName: itemDto.unitName,
          quantity: itemDto.quantity,
          conversionFactor: itemDto.conversionFactor,
          sellingPrice: itemDto.sellingPrice,
          costPrice: itemDto.costPrice > 0 ? itemDto.costPrice : product.baseCostPrice,
          subtotal: itemDto.subtotal,
          createdAt: now,
        );

        await saleItemDao.insert(txn, itemModel);
        itemModels.add(itemModel);
      }

      if (dto.paymentMethod.toUpperCase() == 'KASBON') {
        if (dto.customerId != null && dto.customerId!.isNotEmpty) {
          await txn.rawUpdate('''
            UPDATE ${DatabaseTables.customers}
            SET ${DatabaseTables.columnCustomerReceivableBalance} = ${DatabaseTables.columnCustomerReceivableBalance} + ?,
                ${DatabaseTables.columnUpdatedAt} = ?
            WHERE ${DatabaseTables.columnId} = ?
          ''', [dto.finalAmount, now.toIso8601String(), dto.customerId]);
        }
      } else {
        await const PaymentAccountDao().adjustBalance(
          txn,
          storeId: dto.storeId,
          accountNameOrId: dto.paymentMethod,
          deltaAmount: dto.finalAmount,
        );
      }

      return saleModel.copyWith(items: itemModels);
    });
  }

  Future<List<SaleModel>> getSales(
    String storeId, {
    String? searchQuery,
    String? paymentMethod,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    final db = await appDatabase.database;
    final headers = await saleDao.getByStoreIdWithFilters(
      db,
      storeId,
      searchQuery: searchQuery,
      paymentMethod: paymentMethod,
      status: status,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
    final List<SaleModel> populated = [];
    for (final header in headers) {
      final items = await saleItemDao.getBySaleId(db, header.id);
      populated.add(header.copyWith(items: items));
    }
    return populated;
  }

  Future<SaleModel?> getSaleById(String saleId) async {
    final db = await appDatabase.database;
    final header = await saleDao.getById(db, saleId);
    if (header == null) return null;
    final items = await saleItemDao.getBySaleId(db, saleId);
    return header.copyWith(items: items);
  }

  Future<void> voidSale(String saleId, String storeId) async {
    final db = await appDatabase.database;
    final sale = await getSaleById(saleId);
    if (sale == null || sale.isVoided) return;

    final now = DateTime.now();

    await db.transaction((txn) async {
      await saleDao.voidSale(txn, saleId);

      for (final item in sale.items) {
        final productRows = await txn.query(
          DatabaseTables.products,
          where: '${DatabaseTables.columnId} = ?',
          whereArgs: [item.productId],
          limit: 1,
        );
        if (productRows.isNotEmpty) {
          final product = ProductModel.fromMap(productRows.first);
          final double returnQty = item.totalBaseQuantity;
          final double restoredStock = product.stockBase + returnQty;

          await txn.update(
            DatabaseTables.products,
            {
              DatabaseTables.columnProductStockBase: restoredStock,
              DatabaseTables.columnUpdatedAt: now.toIso8601String(),
            },
            where: '${DatabaseTables.columnId} = ?',
            whereArgs: [product.id],
          );

          final mutationId = IdGenerator.generateId(prefix: 'MUT');
          await const StockMutationDao().insert(
            txn,
            StockMutationModel(
              id: mutationId,
              storeId: storeId,
              productId: product.id,
              productName: product.name,
              type: 'in',
              quantity: returnQty,
              previousStock: product.stockBase,
              currentStock: restoredStock,
              reason: 'koreksi',
              referenceId: sale.invoiceNumber,
              notes: 'Void Transaksi Penjualan (${sale.invoiceNumber})',
              createdAt: now,
            ),
          );
        }
      }

      if (sale.paymentMethod.toUpperCase() == 'KASBON') {
        if (sale.customerId != null && sale.customerId!.isNotEmpty) {
          await txn.rawUpdate('''
            UPDATE ${DatabaseTables.customers}
            SET ${DatabaseTables.columnCustomerReceivableBalance} = MAX(0.0, ${DatabaseTables.columnCustomerReceivableBalance} - ?),
                ${DatabaseTables.columnUpdatedAt} = ?
            WHERE ${DatabaseTables.columnId} = ?
          ''', [sale.finalAmount, now.toIso8601String(), sale.customerId]);
        }
      } else {
        await const PaymentAccountDao().adjustBalance(
          txn,
          storeId: storeId,
          accountNameOrId: sale.paymentMethod,
          deltaAmount: -sale.finalAmount,
        );
      }
    });
  }

  Future<Map<String, double>> getSalesSummary(String storeId, {DateTime? startDate, DateTime? endDate}) async {
    final db = await appDatabase.database;
    return await saleDao.getSalesSummary(db, storeId, startDate: startDate, endDate: endDate);
  }

  Future<({double totalSales, int count})> getTodaySalesSummary(String storeId) async {
    final db = await appDatabase.database;
    final total = await saleDao.getTodayTotalSales(db, storeId);
    final count = await saleDao.getTodayTransactionCount(db, storeId);
    return (totalSales: total, count: count);
  }

  String _generateInvoiceNumber(DateTime dt) {
    final datePart = '${dt.year}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
    final randomPart = IdGenerator.generateId().substring(0, 4).toUpperCase();
    return 'INV-$datePart-$randomPart';
  }
}
