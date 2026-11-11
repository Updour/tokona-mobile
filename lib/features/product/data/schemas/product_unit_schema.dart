import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class ProductUnitSchema {
  ProductUnitSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.productUnits} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnUnitProductId} TEXT NOT NULL,
      ${DatabaseTables.columnUnitName} TEXT NOT NULL,
      ${DatabaseTables.columnUnitConversionFactor} REAL NOT NULL,
      ${DatabaseTables.columnUnitCostPrice} REAL NOT NULL DEFAULT 0,
      ${DatabaseTables.columnUnitSellingPrice} REAL NOT NULL DEFAULT 0,
      ${DatabaseTables.columnUnitBarcode} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnUnitProductId})
        REFERENCES ${DatabaseTables.products} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createProductIndex = '''
    CREATE INDEX IF NOT EXISTS idx_product_units_product_id
    ON ${DatabaseTables.productUnits} (${DatabaseTables.columnUnitProductId});
  ''';

  static const String createBarcodeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_product_units_barcode
    ON ${DatabaseTables.productUnits} (${DatabaseTables.columnUnitBarcode});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createProductIndex);
    await db.execute(createBarcodeIndex);
  }
}
