import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class CategoryDao {
  final Database Function() _getDatabase;

  CategoryDao(this._getDatabase);

  Future<List<String>> getCategoriesByStore(String storeId) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.productCategories,
      columns: [DatabaseTables.columnProductName],
      where: '${DatabaseTables.columnProductStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnProductName} ASC',
    );
    return results.map((row) => row[DatabaseTables.columnProductName] as String).toList();
  }

  Future<void> insertCategory({
    required String id,
    required String storeId,
    required String name,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    final now = DateTime.now().toIso8601String();
    await executor.insert(
      DatabaseTables.productCategories,
      {
        DatabaseTables.columnId: id,
        DatabaseTables.columnProductStoreId: storeId,
        DatabaseTables.columnProductName: name,
        DatabaseTables.columnCreatedAt: now,
        DatabaseTables.columnUpdatedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory({
    required String storeId,
    required String oldName,
    required String newName,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    final now = DateTime.now().toIso8601String();
    await executor.update(
      DatabaseTables.productCategories,
      {
        DatabaseTables.columnProductName: newName,
        DatabaseTables.columnUpdatedAt: now,
      },
      where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductName} = ?',
      whereArgs: [storeId, oldName],
    );
  }

  Future<void> deleteCategory({
    required String storeId,
    required String name,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productCategories,
      where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductName} = ?',
      whereArgs: [storeId, name],
    );
  }
}
