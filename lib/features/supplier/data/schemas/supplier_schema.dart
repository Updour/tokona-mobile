import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class SupplierSchema {
  SupplierSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.suppliers} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnSupplierStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnSupplierName} TEXT NOT NULL,
      ${DatabaseTables.columnSupplierType} TEXT NOT NULL DEFAULT 'offline',
      ${DatabaseTables.columnSupplierPlatform} TEXT,
      ${DatabaseTables.columnSupplierContactName} TEXT,
      ${DatabaseTables.columnSupplierPhone} TEXT,
      ${DatabaseTables.columnSupplierAddress} TEXT,
      ${DatabaseTables.columnSupplierNotes} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnSupplierStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createStoreIndex = '''
    CREATE INDEX IF NOT EXISTS idx_suppliers_store_id
    ON ${DatabaseTables.suppliers} (${DatabaseTables.columnSupplierStoreId});
  ''';

  static const String createTypeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_suppliers_type
    ON ${DatabaseTables.suppliers} (${DatabaseTables.columnSupplierType});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createStoreIndex);
    await db.execute(createTypeIndex);
  }
}
