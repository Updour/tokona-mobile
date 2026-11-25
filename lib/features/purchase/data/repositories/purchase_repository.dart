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
    if (validationError != null) throw ArgumentError(validationError);

    final db = await appDatabase.database;
    final now = DateTime.now();
    final purchaseId = IdGenerator.generateId(prefix: 'PUR');
    final customInv = dto.invoiceNumber?.trim();
    final firstItem = dto.items.isNotEmpty ? dto.items.first.productName : null;
    final invoiceNumber = (customInv != null && customInv.isNotEmpty)
        ? customInv
        : _generateInvoiceNumber(now, supplierName: dto.supplierName ?? dto.platform, productName: firstItem);

    return await db.transaction<PurchaseModel>((txn) async {
      final purchaseModel = PurchaseModel(
        id: purchaseId, storeId: dto.storeId, userId: dto.userId, invoiceNumber: invoiceNumber,
        supplierId: dto.supplierId, supplierName: dto.supplierName?.trim().isEmpty == true ? null : dto.supplierName?.trim(),
        purchaseType: dto.purchaseType, platform: dto.platform, deviceTag: dto.deviceTag,
        paymentAccount: dto.paymentAccount, serviceFee: dto.serviceFee, shippingFee: dto.shippingFee,
        status: dto.status, poDays: dto.poDays, estimatedArrival: dto.estimatedArrival,
        estimatedArrivalEnd: dto.estimatedArrivalEnd, refundStatus: 'none', totalAmount: dto.grandTotal,
        notes: dto.notes?.trim().isEmpty == true ? null : dto.notes?.trim(),
        imagePath: dto.imagePath, trackingNumber: dto.trackingNumber,
        installmentMonths: dto.installmentMonths, monthlyInstallment: dto.monthlyInstallment,
        coPartner: dto.coPartner?.trim().isEmpty == true ? null : dto.coPartner?.trim(),
        coProfit: dto.coProfit, addToStock: dto.addToStock, shippingDiscount: dto.shippingDiscount,
        voucherDiscount: dto.voucherDiscount, items: const [], createdAt: now, updatedAt: now,
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

        if (dto.status == 'received' && dto.addToStock) {
          await _updateProductStockAndHpp(
            txn: txn, productId: itemDto.productId,
            addedQtyBase: itemModel.totalBaseQuantity,
            incomingBaseCost: itemModel.baseUnitCost,
            now: now, deviceTag: dto.deviceTag,
          );
        }
      }

      final isFundedByPartner = dto.purchaseType == 'co_order' &&
          (dto.paymentAccount == null ||
              dto.paymentAccount == 'Dana Rekan' ||
              dto.paymentAccount == 'Non-Kas Toko');

      if (!isFundedByPartner && dto.paymentAccount != null && dto.paymentAccount!.trim().isNotEmpty) {
        await const PaymentAccountDao().adjustBalance(
          txn, storeId: dto.storeId, accountNameOrId: dto.paymentAccount!,
          deltaAmount: -dto.grandTotal,
        );
      }
      return purchaseModel.copyWith(items: itemModels);
    });
  }

  Future<void> confirmReceived(String purchaseId, {bool isAutoReceived = false, String? autoNote}) async {
    final db = await appDatabase.database;
    final now = DateTime.now();
    await db.transaction((txn) async {
      final purchase = await purchaseDao.getById(txn, purchaseId);
      if (purchase == null) throw StateError('Data pembelian tidak ditemukan');
      if (purchase.status == 'received') return;

      if (purchase.addToStock) {
        final items = await purchaseItemDao.getByPurchaseId(txn, purchaseId);
        for (final item in items) {
          await _updateProductStockAndHpp(
            txn: txn, productId: item.productId, addedQtyBase: item.totalBaseQuantity,
            incomingBaseCost: item.baseUnitCost, now: now, deviceTag: purchase.deviceTag,
          );
        }
      }
      final updatedNotes = autoNote != null
          ? (purchase.notes != null && purchase.notes!.isNotEmpty ? '${purchase.notes}\n$autoNote' : autoNote)
          : purchase.notes;
      await purchaseDao.updateStatus(
        txn, purchaseId, status: 'received', isAutoReceived: isAutoReceived,
        notes: updatedNotes, updatedAt: now,
      );
    });
  }

  /// Memeriksa dan menyelesaikan pesanan PO / Dikirim secara otomatis jika melewati batas estimasi maksimal
  Future<int> checkAndAutoReceiveExpiredOrders(String storeId) async {
    final activeOrders = await getActiveOrders(storeId);
    final now = DateTime.now();
    int count = 0;
    for (final order in activeOrders) {
      final rawDeadline = order.estimatedArrivalEnd ?? order.estimatedArrival;
      if (rawDeadline != null) {
        // Batas maksimal adalah akhir hari tanggal estimasi (23:59:59)
        final endOfDay = DateTime(rawDeadline.year, rawDeadline.month, rawDeadline.day, 23, 59, 59, 999);
        if (now.isAfter(endOfDay)) {
          final dateStr = '${rawDeadline.day}/${rawDeadline.month}/${rawDeadline.year}';
          final autoNote = 'pesanan di terima otomatis by sistem (melewati batas estimasi $dateStr)';
          await confirmReceived(order.id, isAutoReceived: true, autoNote: autoNote);
          count++;
        }
      }
    }
    return count;
  }

  Future<void> markAsShipped(String purchaseId, {String? trackingNumber}) async {
    final db = await appDatabase.database;
    await purchaseDao.updateStatus(db, purchaseId, status: 'shipping', trackingNumber: trackingNumber, updatedAt: DateTime.now());
  }

  Future<void> updateTrackingNumber(String purchaseId, String trackingNumber) async {
    final db = await appDatabase.database;
    await purchaseDao.updateTrackingNumber(db, purchaseId, trackingNumber);
  }

  Future<void> cancelPurchase(String purchaseId) async {
    final db = await appDatabase.database;
    await purchaseDao.updateStatus(db, purchaseId, status: 'cancelled', refundStatus: 'pending_refund', updatedAt: DateTime.now());
  }

  Future<void> markRefunded(String purchaseId) async {
    final db = await appDatabase.database;
    final now = DateTime.now();
    await db.transaction((txn) async {
      final p = await purchaseDao.getById(txn, purchaseId);
      await purchaseDao.updateStatus(txn, purchaseId, status: 'cancelled', refundStatus: 'refunded', updatedAt: now);
      if (p != null && p.paymentAccount != null && p.paymentAccount!.trim().isNotEmpty) {
        await const PaymentAccountDao().adjustBalance(
          txn, storeId: p.storeId, accountNameOrId: p.paymentAccount!, deltaAmount: p.grandTotal,
        );
      }
    });
  }

  Future<List<PurchaseModel>> getPendingRefunds(String storeId) async =>
      _hydrateItems(await appDatabase.database, await purchaseDao.getPendingRefunds(await appDatabase.database, storeId));

  Future<List<PurchaseModel>> getCompletedRefunds(String storeId) async =>
      _hydrateItems(await appDatabase.database, await purchaseDao.getCompletedRefunds(await appDatabase.database, storeId));

  Future<List<PurchaseModel>> getActiveOrders(String storeId) async =>
      _hydrateItems(await appDatabase.database, await purchaseDao.getActiveOrders(await appDatabase.database, storeId));

  Future<List<PurchaseModel>> getPurchases(String storeId, {int limit = 50, int offset = 0}) async =>
      _hydrateItems(await appDatabase.database, await purchaseDao.getByStoreId(await appDatabase.database, storeId, limit: limit, offset: offset));

  Future<List<PurchaseModel>> getPurchasesByProduct(String productId, {int limit = 50}) async {
    final db = await appDatabase.database;
    return _hydrateItems(db, await purchaseDao.getByProductId(db, productId, limit: limit));
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
    if (purchases.isEmpty) return const [];
    final purchaseIds = purchases.map((p) => p.id).toList();
    final itemsMap = await purchaseItemDao.getByPurchaseIds(db, purchaseIds);
    return purchases.map((p) => p.copyWith(items: itemsMap[p.id] ?? const [])).toList();
  }

  Future<void> _updateProductStockAndHpp({
    required Transaction txn,
    required String productId,
    required double addedQtyBase,
    required double incomingBaseCost,
    required DateTime now,
    String? deviceTag,
  }) async {
    final rows = await txn.query(DatabaseTables.products, where: '${DatabaseTables.columnId} = ?', whereArgs: [productId], limit: 1);
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

    await txn.update(DatabaseTables.products, updateData, where: '${DatabaseTables.columnId} = ?', whereArgs: [productId]);
    await const StockMutationDao().insert(
      txn, StockMutationModel(
        id: IdGenerator.generateId(prefix: 'MUT'), storeId: currentProduct.storeId,
        productId: productId, productName: currentProduct.name, type: 'in',
        quantity: addedQtyBase, previousStock: currentStock, currentStock: newStock,
        reason: 'purchase', notes: 'Pembelian Belanja Stok', createdAt: now,
      ),
    );
  }

  Future<void> updatePurchaseInvoiceAndSupplier({required String purchaseId, required String invoiceNumber, String? supplierName, String? notes}) async {
    final db = await appDatabase.database;
    await purchaseDao.updateInvoiceAndSupplier(db, purchaseId, invoiceNumber: invoiceNumber, supplierName: supplierName, notes: notes);
  }

  Future<void> updateInstallmentProgress({required String purchaseId, required int paidInstallments}) async {
    final db = await appDatabase.database;
    await purchaseDao.updateInstallmentProgress(db, purchaseId, paidInstallments: paidInstallments);
  }

  String _generateInvoiceNumber(DateTime now, {String? supplierName, String? productName}) {
    final dStr = '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final sTag = supplierName?.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final pTag = productName?.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final sStr = (sTag != null && sTag.isNotEmpty) ? (sTag.length > 4 ? sTag.substring(0, 4) : sTag) : 'TKO';
    final pStr = (pTag != null && pTag.isNotEmpty) ? (pTag.length > 3 ? pTag.substring(0, 3) : pTag) : 'STK';
    final suffix = List.generate(4, (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[Random().nextInt(32)]).join();
    return 'PUR-$sStr-$pStr-$dStr-$suffix';
  }
}
