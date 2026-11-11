import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class PaymentAccountSchema {
  PaymentAccountSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.paymentAccounts} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnAccountStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnAccountName} TEXT NOT NULL,
      ${DatabaseTables.columnAccountType} TEXT NOT NULL DEFAULT 'bank',
      ${DatabaseTables.columnAccountNumber} TEXT,
      ${DatabaseTables.columnAccountHolderName} TEXT,
      ${DatabaseTables.columnAccountInitialBalance} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnAccountCurrentBalance} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnAccountIsActive} INTEGER NOT NULL DEFAULT 1,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnAccountStoreId}) 
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX IF NOT EXISTS idx_payment_accounts_store ON ${DatabaseTables.paymentAccounts} (
      ${DatabaseTables.columnAccountStoreId}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexStoreQuery);
  }
}
