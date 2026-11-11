import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';

class SupplierDao {
  final Database Function() _getDatabase;

  SupplierDao(this._getDatabase);

  Future<void> insertSupplier(SupplierModel supplier, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.suppliers,
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSupplier(SupplierModel supplier, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.suppliers,
      supplier.toMap(),
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<void> deleteSupplier(String id, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.suppliers,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.suppliers,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return SupplierModel.fromMap(results.first);
  }

  Future<List<SupplierModel>> getSuppliersByStore(
    String storeId, {
    String? type,
    String? searchQuery,
  }) async {
    final db = _getDatabase();
    final whereClauses = <String>['${DatabaseTables.columnSupplierStoreId} = ?'];
    final whereArgs = <dynamic>[storeId];

    if (type != null && type.isNotEmpty && type != 'all') {
      whereClauses.add('${DatabaseTables.columnSupplierType} = ?');
      whereArgs.add(type.toLowerCase());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(${DatabaseTables.columnSupplierName} LIKE ? OR ${DatabaseTables.columnSupplierContactName} LIKE ?)');
      final term = '%${searchQuery.trim()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final results = await db.query(
      DatabaseTables.suppliers,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '${DatabaseTables.columnSupplierName} ASC',
    );

    return results.map((e) => SupplierModel.fromMap(e)).toList();
  }
}
