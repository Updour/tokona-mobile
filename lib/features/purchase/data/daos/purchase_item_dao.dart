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
}
