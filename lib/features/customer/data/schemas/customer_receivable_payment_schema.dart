import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class CustomerReceivablePaymentSchema {
  CustomerReceivablePaymentSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.customerReceivablePayments} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnPaymentStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnPaymentCustomerId} TEXT NOT NULL,
      ${DatabaseTables.columnPaymentCustomerName} TEXT NOT NULL,
      ${DatabaseTables.columnPaymentAmount} REAL NOT NULL,
      ${DatabaseTables.columnPaymentDate} TEXT NOT NULL,
      ${DatabaseTables.columnPaymentAccountId} TEXT,
      ${DatabaseTables.columnPaymentAccountName} TEXT,
      ${DatabaseTables.columnPaymentNotes} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL
    );
  ''';

  static const List<String> createIndexesQueries = [
    'CREATE INDEX IF NOT EXISTS idx_crp_store_id ON ${DatabaseTables.customerReceivablePayments} (${DatabaseTables.columnPaymentStoreId});',
    'CREATE INDEX IF NOT EXISTS idx_crp_customer_id ON ${DatabaseTables.customerReceivablePayments} (${DatabaseTables.columnPaymentCustomerId});',
    'CREATE INDEX IF NOT EXISTS idx_crp_date ON ${DatabaseTables.customerReceivablePayments} (${DatabaseTables.columnPaymentDate});',
  ];

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    for (final query in createIndexesQueries) {
      await db.execute(query);
    }
  }
}
