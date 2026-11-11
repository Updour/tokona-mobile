import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class SaleItemSchema {
  SaleItemSchema._();

  static const String createTableQuery = '''
    CREATE TABLE ${DatabaseTables.saleItems} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnSaleItemSaleId} TEXT NOT NULL,
      ${DatabaseTables.columnSaleItemProductId} TEXT NOT NULL,
      ${DatabaseTables.columnSaleItemUnitId} TEXT,
      ${DatabaseTables.columnSaleItemUnitName} TEXT NOT NULL,
      ${DatabaseTables.columnSaleItemQuantity} REAL NOT NULL,
      ${DatabaseTables.columnSaleItemConversionFactor} REAL NOT NULL DEFAULT 1.0,
      ${DatabaseTables.columnSaleItemSellingPrice} REAL NOT NULL,
      ${DatabaseTables.columnSaleItemCostPrice} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSaleItemSubtotal} REAL NOT NULL,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnSaleItemSaleId}) 
        REFERENCES ${DatabaseTables.sales} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseTables.columnSaleItemProductId}) 
        REFERENCES ${DatabaseTables.products} (${DatabaseTables.columnId}) 
        ON DELETE RESTRICT
    )
  ''';

  static const String createIndexSaleQuery = '''
    CREATE INDEX idx_sale_items_sale ON ${DatabaseTables.saleItems} (
      ${DatabaseTables.columnSaleItemSaleId}
    )
  ''';

  static const String createIndexProductQuery = '''
    CREATE INDEX idx_sale_items_product ON ${DatabaseTables.saleItems} (
      ${DatabaseTables.columnSaleItemProductId}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexSaleQuery);
    await db.execute(createIndexProductQuery);
  }
}
