import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class PurchaseSchema {
  PurchaseSchema._();

  static const String createTableQuery = '''
    CREATE TABLE ${DatabaseTables.purchases} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnPurchaseStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseUserId} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseInvoiceNumber} TEXT NOT NULL,
      ${DatabaseTables.columnPurchaseSupplierId} TEXT,
      ${DatabaseTables.columnPurchaseSupplierName} TEXT,
      ${DatabaseTables.columnPurchaseType} TEXT NOT NULL DEFAULT 'offline',
      ${DatabaseTables.columnPurchasePlatform} TEXT,
      ${DatabaseTables.columnPurchaseDeviceTag} TEXT,
      ${DatabaseTables.columnPurchasePaymentAccount} TEXT,
      ${DatabaseTables.columnPurchaseServiceFee} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnPurchaseShippingFee} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnPurchaseStatus} TEXT NOT NULL DEFAULT 'received',
      ${DatabaseTables.columnPurchasePoDays} INTEGER,
      ${DatabaseTables.columnPurchaseEstimatedArrival} TEXT,
      ${DatabaseTables.columnPurchaseRefundStatus} TEXT NOT NULL DEFAULT 'none',
      ${DatabaseTables.columnPurchaseTotalAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnPurchaseNotes} TEXT,
      ${DatabaseTables.columnPurchaseImagePath} TEXT,
      ${DatabaseTables.columnPurchaseTrackingNumber} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnPurchaseStoreId}) 
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseTables.columnPurchaseUserId}) 
        REFERENCES ${DatabaseTables.users} (${DatabaseTables.columnId}) 
        ON DELETE RESTRICT
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX idx_purchases_store_id ON ${DatabaseTables.purchases} (
      ${DatabaseTables.columnPurchaseStoreId}
    )
  ''';

  static const String createIndexInvoiceQuery = '''
    CREATE INDEX idx_purchases_invoice ON ${DatabaseTables.purchases} (
      ${DatabaseTables.columnPurchaseInvoiceNumber}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexStoreQuery);
    await db.execute(createIndexInvoiceQuery);
  }
}
