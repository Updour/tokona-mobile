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

  /// Batch query mengambil item dari banyak transaksi sekaligus (mencegah N+1 query loop)
  Future<Map<String, List<SaleItemModel>>> getBySaleIds(DatabaseExecutor db, List<String> saleIds) async {
    if (saleIds.isEmpty) return {};
    final map = <String, List<SaleItemModel>>{};
    const chunkSize = 500;
    for (var i = 0; i < saleIds.length; i += chunkSize) {
      final chunk = saleIds.sublist(i, (i + chunkSize > saleIds.length) ? saleIds.length : i + chunkSize);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.rawQuery('''
        SELECT si.*, p.${DatabaseTables.columnProductName} as product_name
        FROM ${DatabaseTables.saleItems} si
        LEFT JOIN ${DatabaseTables.products} p ON si.${DatabaseTables.columnSaleItemProductId} = p.${DatabaseTables.columnId}
        WHERE si.${DatabaseTables.columnSaleItemSaleId} IN ($placeholders)
        ORDER BY si.${DatabaseTables.columnCreatedAt} ASC
      ''', chunk);
      for (final r in rows) {
        final item = SaleItemModel.fromMap(r);
        map.putIfAbsent(item.saleId, () => []).add(item);
      }
    }
    return map;
  }
}
