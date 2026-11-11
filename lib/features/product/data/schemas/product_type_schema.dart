import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class ProductTypeSchema {
  ProductTypeSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.productTypes} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnProductStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnProductName} TEXT NOT NULL,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnProductStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createStoreIndex = '''
    CREATE INDEX IF NOT EXISTS idx_product_types_store_id
    ON ${DatabaseTables.productTypes} (${DatabaseTables.columnProductStoreId});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createStoreIndex);
  }
}
