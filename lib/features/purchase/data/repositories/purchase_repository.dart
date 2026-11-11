import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/data/daos/stock_mutation_dao.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';
import 'package:tokona/features/purchase/data/daos/purchase_dao.dart';
import 'package:tokona/features/purchase/data/daos/purchase_item_dao.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return PurchaseRepository(
    appDatabase: appDb,
    purchaseDao: const PurchaseDao(),
    purchaseItemDao: const PurchaseItemDao(),
  );
});

class PurchaseRepository {
  final AppDatabase appDatabase;
  final PurchaseDao purchaseDao;
  final PurchaseItemDao purchaseItemDao;

  const PurchaseRepository({
    required this.appDatabase,
    required this.purchaseDao,
    required this.purchaseItemDao,
  });

  Future<PurchaseModel> recordPurchase(CreatePurchaseDto dto) async {
    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final db = await appDatabase.database;
    final now = DateTime.now();
    final purchaseId = IdGenerator.generateId(prefix: 'PUR');
    final customInv = dto.invoiceNumber?.trim();
    final firstItemName = dto.items.isNotEmpty ? dto.items.first.productName : null;
    final invoiceNumber = (customInv != null && customInv.isNotEmpty)
        ? customInv
        : _generateInvoiceNumber(now, supplierName: dto.supplierName ?? dto.platform, productName: firstItemName);

    return await db.transaction<PurchaseModel>((txn) async {
      final purchaseModel = PurchaseModel(
        id: purchaseId, storeId: dto.storeId, userId: dto.userId, invoiceNumber: invoiceNumber,
        supplierId: dto.supplierId, supplierName: dto.supplierName?.trim().isEmpty == true ? null : dto.supplierName?.trim(),
        purchaseType: dto.purchaseType, platform: dto.platform, deviceTag: dto.deviceTag,
        paymentAccount: dto.paymentAccount, serviceFee: dto.serviceFee, shippingFee: dto.shippingFee,
        status: dto.status, poDays: dto.poDays, estimatedArrival: dto.estimatedArrival,
        refundStatus: 'none', totalAmount: dto.itemsSubtotal,
        notes: dto.notes?.trim().isEmpty == true ? null : dto.notes?.trim(),
        items: const [], createdAt: now, updatedAt: now,
      );

      await purchaseDao.insert(txn, purchaseModel);

      final List<PurchaseItemModel> itemModels = [];
      for (final itemDto in dto.items) {
        final itemModel = PurchaseItemModel(
          id: IdGenerator.generateId(prefix: 'PUI'), purchaseId: purchaseId,
          productId: itemDto.productId, productName: itemDto.productName,
          unitId: itemDto.unitId, unitName: itemDto.unitName, quantity: itemDto.quantity,
          conversionFactor: itemDto.conversionFactor, unitCost: itemDto.unitCost,
          subtotal: itemDto.subtotal, createdAt: now,
        );
        await purchaseItemDao.insert(txn, itemModel);
        itemModels.add(itemModel);

        if (dto.status == 'received') {
          await _updateProductStockAndHpp(
            txn: txn, productId: itemDto.productId,
            addedQtyBase: itemModel.totalBaseQuantity,
            incomingBaseCost: itemModel.baseUnitCost,
            now: now, deviceTag: dto.deviceTag,
          );
        }
      }

      if (dto.paymentAccount != null && dto.paymentAccount!.trim().isNotEmpty) {
        await const PaymentAccountDao().adjustBalance(
          txn,
          storeId: dto.storeId,
          accountNameOrId: dto.paymentAccount!,
          deltaAmount: -(dto.itemsSubtotal + dto.serviceFee + dto.shippingFee),
        );
      }
      return purchaseModel.copyWith(items: itemModels);
    });
  }

  Future<void> confirmReceived(String purchaseId) async {
    final db = await appDatabase.database;
    final now = DateTime.now();
    await db.transaction((txn) async {
      final purchase = await purchaseDao.getById(txn, purchaseId);
      if (purchase == null) throw StateError('Data pembelian tidak ditemukan');
      if (purchase.status == 'received') return;

      final items = await purchaseItemDao.getByPurchaseId(txn, purchaseId);
      for (final item in items) {
        await _updateProductStockAndHpp(
          txn: txn,
          productId: item.productId,
          addedQtyBase: item.totalBaseQuantity,
          incomingBaseCost: item.baseUnitCost,
          now: now,
          deviceTag: purchase.deviceTag,
        );
      }
      await purchaseDao.updateStatus(txn, purchaseId, status: 'received', updatedAt: now);
    });
  }

  Future<void> markAsShipped(String purchaseId) async {
    final db = await appDatabase.database;
    await purchaseDao.updateStatus(db, purchaseId, status: 'shipping', updatedAt: DateTime.now());
  }

  Future<void> cancelPurchase(String purchaseId) async {
    final db = await appDatabase.database;
    await purchaseDao.updateStatus(db, purchaseId, status: 'cancelled', refundStatus: 'pending_refund', updatedAt: DateTime.now());
  }

  Future<void> markRefunded(String purchaseId) async {
    final db = await appDatabase.database;
    final now = DateTime.now();
    await db.transaction((txn) async {
      final purchase = await purchaseDao.getById(txn, purchaseId);
      await purchaseDao.updateStatus(txn, purchaseId, status: 'cancelled', refundStatus: 'refunded', updatedAt: now);
      if (purchase != null && purchase.paymentAccount != null && purchase.paymentAccount!.trim().isNotEmpty) {
        await const PaymentAccountDao().adjustBalance(
          txn,
          storeId: purchase.storeId,
          accountNameOrId: purchase.paymentAccount!,
          deltaAmount: purchase.grandTotal,
        );
      }
    });
  }

  Future<List<PurchaseModel>> getPendingRefunds(String storeId) async {
    final db = await appDatabase.database;
    return _hydrateItems(db, await purchaseDao.getPendingRefunds(db, storeId));
  }

  Future<List<PurchaseModel>> getCompletedRefunds(String storeId) async {
    final db = await appDatabase.database;
    return _hydrateItems(db, await purchaseDao.getCompletedRefunds(db, storeId));
  }

  Future<List<PurchaseModel>> getActiveOrders(String storeId) async {
    final db = await appDatabase.database;
    return _hydrateItems(db, await purchaseDao.getActiveOrders(db, storeId));
  }

  Future<List<PurchaseModel>> getPurchases(String storeId, {int limit = 50, int offset = 0}) async {
    final db = await appDatabase.database;
    return _hydrateItems(db, await purchaseDao.getByStoreId(db, storeId, limit: limit, offset: offset));
  }

  Future<Map<String, double>> getProductDeviceBreakdown(String productId) async {
    final db = await appDatabase.database;
    final rows = await db.rawQuery('''
      SELECT 
        COALESCE(NULLIF(TRIM(p.${DatabaseTables.columnPurchaseDeviceTag}), ''), 'Lainnya') as device_name,
        SUM(pi.${DatabaseTables.columnPurchaseItemQuantity} * pi.${DatabaseTables.columnPurchaseItemConversionFactor}) as total_qty
      FROM ${DatabaseTables.purchaseItems} pi
      JOIN ${DatabaseTables.purchases} p ON pi.${DatabaseTables.columnPurchaseItemPurchaseId} = p.${DatabaseTables.columnId}
      WHERE pi.${DatabaseTables.columnPurchaseItemProductId} = ? AND p.${DatabaseTables.columnPurchaseStatus} = 'received'
      GROUP BY device_name
      ORDER BY total_qty DESC
    ''', [productId]);
    final result = <String, double>{};
    for (final r in rows) {
      final name = r['device_name'] as String;
      final qty = (r['total_qty'] as num?)?.toDouble() ?? 0.0;
      if (qty > 0) result[name] = qty;
    }
    return result;
  }

  Future<List<PurchaseModel>> _hydrateItems(Database db, List<PurchaseModel> purchases) async {
    final fullList = <PurchaseModel>[];
    for (final p in purchases) {
      final items = await purchaseItemDao.getByPurchaseId(db, p.id);
      fullList.add(p.copyWith(items: items));
    }
    return fullList;
  }

  Future<void> _updateProductStockAndHpp({
    required Transaction txn,
    required String productId,
    required double addedQtyBase,
    required double incomingBaseCost,
    required DateTime now,
    String? deviceTag,
  }) async {
    final rows = await txn.query(
      DatabaseTables.products,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final currentProduct = ProductModel.fromMap(rows.first);
    final currentStock = currentProduct.stockBase;
    final currentHpp = currentProduct.baseCostPrice;
    final newStock = currentStock + addedQtyBase;

    double newHpp = incomingBaseCost;
    if (currentStock > 0 && newStock > 0) {
      final totalCurrentValuation = currentStock * currentHpp;
      final totalIncomingValuation = addedQtyBase * incomingBaseCost;
      newHpp = (totalCurrentValuation + totalIncomingValuation) / newStock;
    }

    final existingTags = currentProduct.deviceTags;
    String? combinedDeviceTag = currentProduct.deviceTag;
    if (deviceTag != null && deviceTag.trim().isNotEmpty) {
      final incoming = deviceTag.trim();
      if (!existingTags.contains(incoming)) {
        combinedDeviceTag = existingTags.isEmpty ? incoming : '${existingTags.join(', ')}, $incoming';
      }
    }

    final updateData = <String, dynamic>{
      DatabaseTables.columnProductStockBase: newStock,
      DatabaseTables.columnProductBaseCostPrice: newHpp,
      DatabaseTables.columnUpdatedAt: now.toIso8601String(),
    };
    if (combinedDeviceTag != null && combinedDeviceTag.isNotEmpty) {
      updateData[DatabaseTables.columnProductDeviceTag] = combinedDeviceTag;
    }

    await txn.update(
      DatabaseTables.products,
      updateData,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [productId],
    );

    await const StockMutationDao().insert(
      txn,
      StockMutationModel(
        id: IdGenerator.generateId(prefix: 'MUT'),
        storeId: currentProduct.storeId,
        productId: productId,
        productName: currentProduct.name,
        type: 'in',
        quantity: addedQtyBase,
        previousStock: currentStock,
        currentStock: newStock,
        reason: 'purchase',
        notes: 'Pembelian Belanja Stok',
        createdAt: now,
      ),
    );
  }

  Future<void> updatePurchaseInvoiceAndSupplier({required String purchaseId, required String invoiceNumber, String? supplierName, String? notes}) async {
    final db = await appDatabase.database;
    await purchaseDao.updateInvoiceAndSupplier(db, purchaseId, invoiceNumber: invoiceNumber, supplierName: supplierName, notes: notes);
  }

  String _generateInvoiceNumber(DateTime now, {String? supplierName, String? productName}) {
    final dateStr = '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    String shopTag = 'TKO';
    if (supplierName != null && supplierName.trim().isNotEmpty) {
      final clean = supplierName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (clean.isNotEmpty) shopTag = clean.length > 4 ? clean.substring(0, 4) : clean;
    }
    String prodTag = 'STK';
    if (productName != null && productName.trim().isNotEmpty) {
      final clean = productName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (clean.isNotEmpty) prodTag = clean.length > 3 ? clean.substring(0, 3) : clean;
    }
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final randomSuffix = List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'INV-$shopTag-$prodTag-$dateStr-$randomSuffix';
  }
}
