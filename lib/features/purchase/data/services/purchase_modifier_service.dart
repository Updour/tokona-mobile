import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/data/daos/stock_mutation_dao.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';
import 'package:tokona/features/purchase/data/daos/purchase_dao.dart';
import 'package:tokona/features/purchase/data/daos/purchase_item_dao.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';

final purchaseModifierServiceProvider = Provider<PurchaseModifierService>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return PurchaseModifierService(appDb);
});

class PurchaseModifierService {
  final AppDatabase appDatabase;
  final PurchaseDao purchaseDao = const PurchaseDao();
  final PurchaseItemDao purchaseItemDao = const PurchaseItemDao();

  const PurchaseModifierService(this.appDatabase);

  Future<void> updatePurchaseItemsAndDetails({
    required String purchaseId,
    required String invoiceNumber,
    String? supplierName,
    String? notes,
    double? serviceFee,
    double? shippingFee,
    required List<CreatePurchaseItemDto> newItems,
  }) async {
    final db = await appDatabase.database;
    final now = DateTime.now();

    await db.transaction((txn) async {
      final purchase = await purchaseDao.getById(txn, purchaseId);
      if (purchase == null) throw StateError('Data pembelian tidak ditemukan');

      final oldItems = await purchaseItemDao.getByPurchaseId(txn, purchaseId);
      final isReceived = purchase.status == 'received';

      // 1. Jika pesanan sudah berstatus received, sesuaikan perubahan stok
      if (isReceived) {
        // Rollback stok lama
        for (final oldItem in oldItems) {
          await _adjustStock(
            txn: txn,
            productId: oldItem.productId,
            deltaQtyBase: -oldItem.totalBaseQuantity,
            now: now,
            reason: 'Koreksi edit faktur pembelian (rollback)',
          );
        }
        // Tambahkan stok baru
        for (final newItem in newItems) {
          await _adjustStock(
            txn: txn,
            productId: newItem.productId,
            deltaQtyBase: newItem.totalBaseQuantity,
            now: now,
            reason: 'Koreksi edit faktur pembelian (update)',
          );
        }
      }

      // 2. Ganti items di database
      await purchaseItemDao.deleteByPurchaseId(txn, purchaseId);
      for (final it in newItems) {
        await purchaseItemDao.insert(
          txn,
          PurchaseItemModel(
            id: IdGenerator.generateId(prefix: 'PUI'),
            purchaseId: purchaseId,
            productId: it.productId,
            productName: it.productName,
            unitId: it.unitId,
            unitName: it.unitName,
            quantity: it.quantity,
            conversionFactor: it.conversionFactor,
            unitCost: it.unitCost,
            subtotal: it.subtotal,
            createdAt: now,
          ),
        );
      }

      // 3. Hitung ulang total amount & update kas jika ada payment account
      final newItemsSubtotal = newItems.fold<double>(0.0, (acc, i) => acc + i.subtotal);
      final effServiceFee = serviceFee ?? purchase.serviceFee;
      final effShippingFee = shippingFee ?? purchase.shippingFee;
      final newGrandTotal = newItemsSubtotal + effServiceFee + effShippingFee;
      final oldGrandTotal = purchase.grandTotal;

      if (purchase.paymentAccount != null && purchase.paymentAccount!.trim().isNotEmpty) {
        final diff = oldGrandTotal - newGrandTotal;
        if (diff != 0) {
          await const PaymentAccountDao().adjustBalance(
            txn,
            storeId: purchase.storeId,
            accountNameOrId: purchase.paymentAccount!,
            deltaAmount: diff,
          );
        }
      }

      // 4. Update purchase header
      await purchaseDao.updateInvoiceAndSupplier(
        txn,
        purchaseId,
        invoiceNumber: invoiceNumber,
        supplierName: supplierName,
        notes: notes,
        totalAmount: newItemsSubtotal,
        serviceFee: effServiceFee,
        shippingFee: effShippingFee,
      );
    });
  }

  Future<void> revertReceivedToShipping(String purchaseId) async {
    final db = await appDatabase.database;
    final now = DateTime.now();

    await db.transaction((txn) async {
      final purchase = await purchaseDao.getById(txn, purchaseId);
      if (purchase == null) throw StateError('Data pembelian tidak ditemukan');
      if (purchase.status != 'received') return;

      final items = await purchaseItemDao.getByPurchaseId(txn, purchaseId);

      // Rollback penambahan stok yang sempat masuk
      for (final item in items) {
        await _adjustStock(
          txn: txn,
          productId: item.productId,
          deltaQtyBase: -item.totalBaseQuantity,
          now: now,
          reason: 'Koreksi pembatalan terima barang (revert to shipping)',
        );
      }

      // Bersihkan catatan auto-receive dan kembalikan status ke shipping
      String? cleanedNotes = purchase.notes;
      if (cleanedNotes != null) {
        cleanedNotes = cleanedNotes
            .replaceAll(RegExp(r'\n?pesanan di terima otomatis by sistem[^\n]*', caseSensitive: false), '')
            .replaceAll(RegExp(r'\n?Diterima otomatis dari notifikasi Shopee[^\n]*', caseSensitive: false), '')
            .trim();
        if (cleanedNotes.isEmpty) cleanedNotes = null;
      }

      await purchaseDao.updateStatus(
        txn,
        purchaseId,
        status: 'shipping',
        isAutoReceived: false,
        notes: cleanedNotes,
        updatedAt: now,
      );
    });
  }

  Future<void> _adjustStock({
    required Transaction txn,
    required String productId,
    required double deltaQtyBase,
    required DateTime now,
    required String reason,
  }) async {
    final rows = await txn.query(
      DatabaseTables.products,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final product = ProductModel.fromMap(rows.first);
    final curStock = product.stockBase;
    final newStock = curStock + deltaQtyBase;

    await txn.update(
      DatabaseTables.products,
      {
        DatabaseTables.columnProductStockBase: newStock,
        DatabaseTables.columnUpdatedAt: now.toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [productId],
    );

    await const StockMutationDao().insert(
      txn,
      StockMutationModel(
        id: IdGenerator.generateId(prefix: 'MUT'),
        storeId: product.storeId,
        productId: productId,
        productName: product.name,
        type: deltaQtyBase >= 0 ? 'in' : 'out',
        quantity: deltaQtyBase.abs(),
        previousStock: curStock,
        currentStock: newStock,
        reason: 'adjustment',
        notes: reason,
        createdAt: now,
      ),
    );
  }
}

