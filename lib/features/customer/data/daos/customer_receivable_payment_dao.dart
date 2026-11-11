import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';

class CustomerReceivablePaymentDao {
  const CustomerReceivablePaymentDao();

  Future<void> insert(DatabaseExecutor db, CustomerReceivablePaymentModel payment) async {
    await db.insert(
      DatabaseTables.customerReceivablePayments,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomerReceivablePaymentModel>> getByCustomerId(DatabaseExecutor db, String customerId) async {
    final rows = await db.query(
      DatabaseTables.customerReceivablePayments,
      where: '${DatabaseTables.columnPaymentCustomerId} = ?',
      whereArgs: [customerId],
      orderBy: '${DatabaseTables.columnPaymentDate} DESC',
    );
    return rows.map(CustomerReceivablePaymentModel.fromMap).toList();
  }

  Future<List<CustomerReceivablePaymentModel>> getByStoreId(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.customerReceivablePayments,
      where: '${DatabaseTables.columnPaymentStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnPaymentDate} DESC',
    );
    return rows.map(CustomerReceivablePaymentModel.fromMap).toList();
  }

  Future<double> getTotalPaidByCustomer(DatabaseExecutor db, String customerId) async {
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(${DatabaseTables.columnPaymentAmount}), 0.0) as total_paid
      FROM ${DatabaseTables.customerReceivablePayments}
      WHERE ${DatabaseTables.columnPaymentCustomerId} = ?
      ''',
      [customerId],
    );
    return (result.first['total_paid'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> delete(DatabaseExecutor db, String id) async {
    await db.delete(
      DatabaseTables.customerReceivablePayments,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }
}
