import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class SaleSchema {
  SaleSchema._();

  static const String createTableQuery = '''
    CREATE TABLE ${DatabaseTables.sales} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnSaleStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnSaleUserId} TEXT NOT NULL,
      ${DatabaseTables.columnSaleCustomerId} TEXT,
      ${DatabaseTables.columnSaleInvoiceNumber} TEXT NOT NULL,
      ${DatabaseTables.columnSaleCustomerName} TEXT,
      ${DatabaseTables.columnSaleTotalAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSaleDiscountAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSaleFinalAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSaleCashPaid} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSaleChangeAmount} REAL NOT NULL DEFAULT 0.0,
      ${DatabaseTables.columnSalePaymentMethod} TEXT NOT NULL DEFAULT 'CASH',
      ${DatabaseTables.columnSaleStatus} TEXT NOT NULL DEFAULT 'COMPLETED',
      ${DatabaseTables.columnSaleNotes} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnSaleStoreId}) 
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseTables.columnSaleUserId}) 
        REFERENCES ${DatabaseTables.users} (${DatabaseTables.columnId}) 
        ON DELETE RESTRICT
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX idx_sales_store_id ON ${DatabaseTables.sales} (
      ${DatabaseTables.columnSaleStoreId}
    )
  ''';

  static const String createIndexInvoiceQuery = '''
    CREATE INDEX idx_sales_invoice ON ${DatabaseTables.sales} (
      ${DatabaseTables.columnSaleInvoiceNumber}
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexStoreQuery);
    await db.execute(createIndexInvoiceQuery);
  }
}
