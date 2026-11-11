import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class PurchaseItemSchema {
  PurchaseItemSchema._();

  static const String createTableQuery = '''
    CREATE TABLE ${DatabaseTables.purchaseItems} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnPurchaseItemPurchaseId} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseItemProductId} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseItemUnitId} TEXT,
      ${DatabaseTables.columnPurchaseItemUnitName} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseItemQuantity} REAL NOT NULL,
      ${DatabaseTables.columnPurchaseItemConversionFactor} REAL NOT NULL DEFAULT 1.0,
      ${DatabaseTables.columnPurchaseItemUnitCost} REAL NOT NULL,
      ${DatabaseTables.columnPurchaseItemSubtotal} REAL NOT NULL,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnPurchaseItemPurchaseId}) 
        REFERENCES ${DatabaseTables.purchases} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseTables.columnPurchaseItemProductId}) 
        REFERENCES ${DatabaseTables.products} (${DatabaseTables.columnId}) 
        ON DELETE RESTRICT
    )
  ''';

  static const String createIndexPurchaseQuery = '''
    CREATE INDEX idx_purchase_items_purchase ON ${DatabaseTables.purchaseItems} (
      ${DatabaseTables.columnPurchaseItemPurchaseId}
    )
  ''';

  static const String createIndexProductQuery = '''
    CREATE INDEX idx_purchase_items_product ON ${DatabaseTables.purchaseItems} (
      ${DatabaseTables.columnPurchaseItemProductId}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexPurchaseQuery);
    await db.execute(createIndexProductQuery);
  }
}
