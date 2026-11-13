import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class PurchaseDao {
  const PurchaseDao();

  Future<void> insert(DatabaseExecutor db, PurchaseModel purchase) async {
    await db.insert(
      DatabaseTables.purchases,
      purchase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PurchaseModel?> getById(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      DatabaseTables.purchases,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PurchaseModel.fromMap(rows.first);
  }

  Future<void> updateStatus(
    DatabaseExecutor db,
    String id, {
    required String status,
    String? refundStatus,
    String? trackingNumber,
    DateTime? updatedAt,
  }) async {
    final values = <String, dynamic>{
      DatabaseTables.columnPurchaseStatus: status,
      DatabaseTables.columnUpdatedAt: (updatedAt ?? DateTime.now()).toIso8601String(),
    };
    if (refundStatus != null) values[DatabaseTables.columnPurchaseRefundStatus] = refundStatus;
    if (trackingNumber != null) values[DatabaseTables.columnPurchaseTrackingNumber] = trackingNumber;
    await db.update(DatabaseTables.purchases, values, where: '${DatabaseTables.columnId} = ?', whereArgs: [id]);
  }

  Future<void> updateTrackingNumber(DatabaseExecutor db, String id, String trackingNumber) async {
    await db.update(
      DatabaseTables.purchases,
      {
        DatabaseTables.columnPurchaseTrackingNumber: trackingNumber,
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInvoiceAndSupplier(
    DatabaseExecutor db,
    String id, {
    required String invoiceNumber,
    String? supplierName,
    String? notes,
  }) async {
    final values = <String, dynamic>{
      DatabaseTables.columnPurchaseInvoiceNumber: invoiceNumber,
      DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
    };
    if (supplierName != null) values[DatabaseTables.columnPurchaseSupplierName] = supplierName;
    if (notes != null) values[DatabaseTables.columnPurchaseNotes] = notes;
    await db.update(
      DatabaseTables.purchases,
      values,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<PurchaseModel>> getByStoreId(
    DatabaseExecutor db,
    String storeId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await db.query(
      DatabaseTables.purchases,
      where: '${DatabaseTables.columnPurchaseStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => PurchaseModel.fromMap(r)).toList();
  }

  Future<List<PurchaseModel>> getPendingRefunds(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.purchases,
      where: '${DatabaseTables.columnPurchaseStoreId} = ? AND ${DatabaseTables.columnPurchaseRefundStatus} = ?',
      whereArgs: [storeId, 'pending_refund'],
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
    );
    return rows.map((r) => PurchaseModel.fromMap(r)).toList();
  }

  Future<List<PurchaseModel>> getCompletedRefunds(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.purchases,
      where: '${DatabaseTables.columnPurchaseStoreId} = ? AND ${DatabaseTables.columnPurchaseRefundStatus} = ?',
      whereArgs: [storeId, 'refunded'],
      orderBy: '${DatabaseTables.columnUpdatedAt} DESC',
    );
    return rows.map((r) => PurchaseModel.fromMap(r)).toList();
  }

  Future<List<PurchaseModel>> getActiveOrders(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.purchases,
      where: '${DatabaseTables.columnPurchaseStoreId} = ? AND ${DatabaseTables.columnPurchaseStatus} IN (?, ?)',
      whereArgs: [storeId, 'pre_order', 'shipping'],
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
    );
    return rows.map((r) => PurchaseModel.fromMap(r)).toList();
  }

  Future<List<PurchaseModel>> getByProductId(DatabaseExecutor db, String productId, {int limit = 50}) async {
    final rows = await db.rawQuery('''
      SELECT DISTINCT p.*
      FROM ${DatabaseTables.purchases} p
      INNER JOIN ${DatabaseTables.purchaseItems} pi ON p.${DatabaseTables.columnId} = pi.${DatabaseTables.columnPurchaseItemPurchaseId}
      WHERE pi.${DatabaseTables.columnPurchaseItemProductId} = ?
      ORDER BY p.${DatabaseTables.columnCreatedAt} DESC
      LIMIT ?
    ''', [productId, limit]);
    return rows.map((r) => PurchaseModel.fromMap(r)).toList();
  }
}
