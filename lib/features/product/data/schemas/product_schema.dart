import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class ProductSchema {
  ProductSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.products} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnProductStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnProductSku} TEXT,
      ${DatabaseTables.columnProductName} TEXT NOT NULL,
      ${DatabaseTables.columnProductCategory} TEXT,
      ${DatabaseTables.columnProductBaseUnit} TEXT NOT NULL,
      ${DatabaseTables.columnProductStockBase} REAL NOT NULL DEFAULT 0,
      ${DatabaseTables.columnProductMinStockAlert} REAL DEFAULT 0,
      ${DatabaseTables.columnProductBaseCostPrice} REAL NOT NULL DEFAULT 0,
      ${DatabaseTables.columnProductBaseSellingPrice} REAL NOT NULL DEFAULT 0,
      ${DatabaseTables.columnProductType} TEXT DEFAULT 'Fisik',
      ${DatabaseTables.columnProductImagePath} TEXT,
      ${DatabaseTables.columnProductExpiredAt} TEXT,
      ${DatabaseTables.columnProductDeviceTag} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnProductStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createStoreIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_store_id
    ON ${DatabaseTables.products} (${DatabaseTables.columnProductStoreId});
  ''';

  static const String createSkuIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_sku
    ON ${DatabaseTables.products} (${DatabaseTables.columnProductSku});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createStoreIndex);
    await db.execute(createSkuIndex);
  }
}
