import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';

class StockMutationDao {
  const StockMutationDao();

  Future<void> insert(DatabaseExecutor db, StockMutationModel mutation) async {
    await db.insert(
      DatabaseTables.stockMutations,
      mutation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StockMutationModel>> getByProductId(
    DatabaseExecutor db,
    String productId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await db.rawQuery('''
      SELECT sm.*, p.${DatabaseTables.columnProductName} AS product_name
      FROM ${DatabaseTables.stockMutations} sm
      LEFT JOIN ${DatabaseTables.products} p ON sm.${DatabaseTables.columnMutationProductId} = p.${DatabaseTables.columnId}
      WHERE sm.${DatabaseTables.columnMutationProductId} = ?
      ORDER BY sm.${DatabaseTables.columnCreatedAt} DESC
      LIMIT ? OFFSET ?
    ''', [productId, limit, offset]);

    return rows.map((r) => StockMutationModel.fromMap(r)).toList();
  }

  Future<List<StockMutationModel>> getByStoreId(
    DatabaseExecutor db,
    String storeId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await db.rawQuery('''
      SELECT sm.*, p.${DatabaseTables.columnProductName} AS product_name
      FROM ${DatabaseTables.stockMutations} sm
      LEFT JOIN ${DatabaseTables.products} p ON sm.${DatabaseTables.columnMutationProductId} = p.${DatabaseTables.columnId}
      WHERE sm.${DatabaseTables.columnMutationStoreId} = ?
      ORDER BY sm.${DatabaseTables.columnCreatedAt} DESC
      LIMIT ? OFFSET ?
    ''', [storeId, limit, offset]);

    return rows.map((r) => StockMutationModel.fromMap(r)).toList();
  }
}

