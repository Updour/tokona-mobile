import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class DeviceSchema {
  DeviceSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.devices} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnDeviceStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnDeviceName} TEXT NOT NULL,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnDeviceStoreId}) 
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX IF NOT EXISTS idx_devices_store ON ${DatabaseTables.devices} (
      ${DatabaseTables.columnDeviceStoreId}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexStoreQuery);
  }
}
