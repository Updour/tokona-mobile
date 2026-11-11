import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class CategorySchema {
  CategorySchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.productCategories} (
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
    CREATE INDEX IF NOT EXISTS idx_categories_store_id
    ON ${DatabaseTables.productCategories} (${DatabaseTables.columnProductStoreId});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createStoreIndex);
  }
}
