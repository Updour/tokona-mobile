import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';

class CustomerDao {
  final Database Function() _getDatabase;

  CustomerDao(this._getDatabase);

  Future<void> insertCustomer(CustomerModel customer, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.customers,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCustomer(CustomerModel customer, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.customers,
      customer.toMap(),
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> deleteCustomer(String id, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.customers,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.customers,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CustomerModel.fromMap(results.first);
  }

  Future<List<CustomerModel>> getCustomersByStore(
    String storeId, {
    String? type,
    String? searchQuery,
  }) async {
    final db = _getDatabase();
    final whereClauses = <String>['${DatabaseTables.columnCustomerStoreId} = ?'];
    final whereArgs = <dynamic>[storeId];

    if (type != null && type.isNotEmpty && type != 'all') {
      whereClauses.add('${DatabaseTables.columnCustomerType} = ?');
      whereArgs.add(type.toLowerCase());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim().toLowerCase()}%';
      whereClauses.add('''
        (
          LOWER(${DatabaseTables.columnCustomerName}) LIKE ? OR
          LOWER(${DatabaseTables.columnCustomerPhone}) LIKE ? OR
          LOWER(${DatabaseTables.columnCustomerAddress}) LIKE ?
        )
      ''');
      whereArgs.addAll([query, query, query]);
    }

    final results = await db.query(
      DatabaseTables.customers,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '${DatabaseTables.columnCustomerName} ASC',
    );

    return results.map(CustomerModel.fromMap).toList();
  }

  Future<void> adjustReceivable(String customerId, double deltaAmount, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.rawUpdate('''
      UPDATE ${DatabaseTables.customers}
      SET ${DatabaseTables.columnCustomerReceivableBalance} = MAX(0.0, ${DatabaseTables.columnCustomerReceivableBalance} + ?),
          ${DatabaseTables.columnUpdatedAt} = ?
      WHERE ${DatabaseTables.columnId} = ?
    ''', [deltaAmount, DateTime.now().toIso8601String(), customerId]);
  }
}

