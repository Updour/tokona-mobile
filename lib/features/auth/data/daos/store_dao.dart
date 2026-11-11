import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';

class StoreDao {
  final Database Function() _getDatabase;

  StoreDao(this._getDatabase);

  Future<void> insertStore(StoreModel store, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.stores,
      store.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StoreModel?> getFirstStore() async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.stores,
      limit: 1,
    );
    if (results.isEmpty) return null;
    return StoreModel.fromMap(results.first);
  }

  Future<StoreModel?> getStoreById(String id) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.stores,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return StoreModel.fromMap(results.first);
  }

  Future<int> countStores() async {
    final db = _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM ${DatabaseTables.stores}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> updateStore(StoreModel store) async {
    final db = _getDatabase();
    await db.update(
      DatabaseTables.stores,
      store.toMap(),
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [store.id],
    );
  }
}
