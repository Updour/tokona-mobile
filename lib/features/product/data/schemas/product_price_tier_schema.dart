import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class ProductPriceTierSchema {
  ProductPriceTierSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.productPriceTiers} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnTierProductId} TEXT NOT NULL,
      ${DatabaseTables.columnTierUnitName} TEXT,
      ${DatabaseTables.columnTierMinQuantity} REAL NOT NULL,
      ${DatabaseTables.columnTierPrice} REAL NOT NULL,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnTierProductId})
        REFERENCES ${DatabaseTables.products} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createProductIndex = '''
    CREATE INDEX IF NOT EXISTS idx_product_price_tiers_product_id
    ON ${DatabaseTables.productPriceTiers} (${DatabaseTables.columnTierProductId});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createProductIndex);
  }
}
