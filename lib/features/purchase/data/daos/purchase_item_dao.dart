import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';

class PurchaseItemDao {
  const PurchaseItemDao();

  Future<void> insert(DatabaseExecutor db, PurchaseItemModel item) async {
    await db.insert(
      DatabaseTables.purchaseItems,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertBatch(DatabaseExecutor db, List<PurchaseItemModel> items) async {
    for (final item in items) {
      await insert(db, item);
    }
  }

  Future<void> deleteByPurchaseId(DatabaseExecutor db, String purchaseId) async {
    await db.delete(
      DatabaseTables.purchaseItems,
      where: '${DatabaseTables.columnPurchaseItemPurchaseId} = ?',
      whereArgs: [purchaseId],
    );
  }

  Future<List<PurchaseItemModel>> getByPurchaseId(DatabaseExecutor db, String purchaseId) async {
    final rows = await db.rawQuery('''
      SELECT pi.*, p.${DatabaseTables.columnProductName} AS product_name
      FROM ${DatabaseTables.purchaseItems} pi
      LEFT JOIN ${DatabaseTables.products} p ON pi.${DatabaseTables.columnPurchaseItemProductId} = p.${DatabaseTables.columnId}
      WHERE pi.${DatabaseTables.columnPurchaseItemPurchaseId} = ?
      ORDER BY pi.${DatabaseTables.columnCreatedAt} ASC
    ''', [purchaseId]);
    return rows.map((r) => PurchaseItemModel.fromMap(r)).toList();
  }

  /// Batch query mengambil item dari banyak pembelian sekaligus (mencegah N+1 query loop)
  Future<Map<String, List<PurchaseItemModel>>> getByPurchaseIds(DatabaseExecutor db, List<String> purchaseIds) async {
    if (purchaseIds.isEmpty) return {};
    final map = <String, List<PurchaseItemModel>>{};
    const chunkSize = 500;
    for (var i = 0; i < purchaseIds.length; i += chunkSize) {
      final chunk = purchaseIds.sublist(i, (i + chunkSize > purchaseIds.length) ? purchaseIds.length : i + chunkSize);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.rawQuery('''
        SELECT pi.*, p.${DatabaseTables.columnProductName} AS product_name
        FROM ${DatabaseTables.purchaseItems} pi
        LEFT JOIN ${DatabaseTables.products} p ON pi.${DatabaseTables.columnPurchaseItemProductId} = p.${DatabaseTables.columnId}
        WHERE pi.${DatabaseTables.columnPurchaseItemPurchaseId} IN ($placeholders)
        ORDER BY pi.${DatabaseTables.columnCreatedAt} ASC
      ''', chunk);
      for (final r in rows) {
        final item = PurchaseItemModel.fromMap(r);
        map.putIfAbsent(item.purchaseId, () => []).add(item);
      }
    }
    return map;
  }
}
