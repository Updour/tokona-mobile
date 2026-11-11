import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class StoreCapitalSchema {
  StoreCapitalSchema._();

  static const String createTableQuery = '''
    CREATE TABLE ${DatabaseTables.storeCapitals} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnCapitalStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnCapitalAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnCapitalType} TEXT NOT NULL DEFAULT 'TAMBAH_MODAL',
      ${DatabaseTables.columnCapitalDate} TEXT NOT NULL,
      ${DatabaseTables.columnCapitalAccountId} TEXT,
      ${DatabaseTables.columnCapitalAccountName} TEXT,
      ${DatabaseTables.columnCapitalSource} TEXT,
      ${DatabaseTables.columnCapitalNotes} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnCapitalStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX idx_store_capitals_store_id ON ${DatabaseTables.storeCapitals} (
      ${DatabaseTables.columnCapitalStoreId}
    )
  ''';

  static const String createIndexDateQuery = '''
    CREATE INDEX idx_store_capitals_date ON ${DatabaseTables.storeCapitals} (
      ${DatabaseTables.columnCapitalDate}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexStoreQuery);
    await db.execute(createIndexDateQuery);
  }
}
