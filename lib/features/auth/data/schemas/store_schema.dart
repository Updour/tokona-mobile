import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class StoreSchema {
  StoreSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.stores} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnStoreName} TEXT NOT NULL,
      ${DatabaseTables.columnStoreAddress} TEXT,
      ${DatabaseTables.columnStorePhone} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT
    );
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
  }
}
