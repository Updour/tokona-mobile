import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class CustomerSchema {
  CustomerSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.customers} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnCustomerStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnCustomerName} TEXT NOT NULL,
      ${DatabaseTables.columnCustomerPhone} TEXT,
      ${DatabaseTables.columnCustomerAddress} TEXT,
      ${DatabaseTables.columnCustomerType} TEXT NOT NULL DEFAULT 'umum',
      ${DatabaseTables.columnCustomerNotes} TEXT,
      ${DatabaseTables.columnCustomerReceivableBalance} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnCustomerStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createStoreIndex = '''
    CREATE INDEX IF NOT EXISTS idx_customers_store_id
    ON ${DatabaseTables.customers} (${DatabaseTables.columnCustomerStoreId});
  ''';

  static const String createTypeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_customers_type
    ON ${DatabaseTables.customers} (${DatabaseTables.columnCustomerType});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createStoreIndex);
    await db.execute(createTypeIndex);
  }
}

