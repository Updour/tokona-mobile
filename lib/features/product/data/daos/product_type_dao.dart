import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class ProductTypeDao {
  final Database Function() _getDatabase;

  ProductTypeDao(this._getDatabase);

  Future<List<String>> getTypesByStore(String storeId) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.productTypes,
      columns: [DatabaseTables.columnProductName],
      where: '${DatabaseTables.columnProductStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnProductName} ASC',
    );
    return results.map((row) => row[DatabaseTables.columnProductName] as String).toList();
  }

  Future<void> insertType({
    required String id,
    required String storeId,
    required String name,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    final now = DateTime.now().toIso8601String();
    await executor.insert(
      DatabaseTables.productTypes,
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

  Future<void> updateType({
    required String storeId,
    required String oldName,
    required String newName,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    final now = DateTime.now().toIso8601String();
    await executor.update(
      DatabaseTables.productTypes,
      {
        DatabaseTables.columnProductName: newName,
        DatabaseTables.columnUpdatedAt: now,
      },
      where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductName} = ?',
      whereArgs: [storeId, oldName],
    );
  }

  Future<void> deleteType({
    required String storeId,
    required String name,
    Transaction? txn,
  }) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productTypes,
      where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductName} = ?',
      whereArgs: [storeId, name],
    );
  }
}
