import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';

class SaleItemDao {
  const SaleItemDao();

  Future<void> insert(DatabaseExecutor db, SaleItemModel item) async {
    await db.insert(
      DatabaseTables.saleItems,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertBatch(DatabaseExecutor db, List<SaleItemModel> items) async {
    for (final item in items) {
      await insert(db, item);
    }
  }

  Future<List<SaleItemModel>> getBySaleId(DatabaseExecutor db, String saleId) async {
    final rows = await db.rawQuery('''
      SELECT si.*, p.${DatabaseTables.columnProductName} as product_name
      FROM ${DatabaseTables.saleItems} si
      LEFT JOIN ${DatabaseTables.products} p ON si.${DatabaseTables.columnSaleItemProductId} = p.${DatabaseTables.columnId}
      WHERE si.${DatabaseTables.columnSaleItemSaleId} = ?
      ORDER BY si.${DatabaseTables.columnCreatedAt} ASC
    ''', [saleId]);
    return rows.map((r) => SaleItemModel.fromMap(r)).toList();
  }
}
