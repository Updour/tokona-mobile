import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class StockMutationSchema {
  StockMutationSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.stockMutations} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnMutationStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnMutationProductId} TEXT NOT NULL,
      ${DatabaseTables.columnMutationType} TEXT NOT NULL,
      ${DatabaseTables.columnMutationQuantity} REAL NOT NULL,
      ${DatabaseTables.columnMutationPreviousStock} REAL NOT NULL,
      ${DatabaseTables.columnMutationCurrentStock} REAL NOT NULL,
      ${DatabaseTables.columnMutationReason} TEXT NOT NULL,
      ${DatabaseTables.columnMutationReferenceId} TEXT,
      ${DatabaseTables.columnMutationNotes} TEXT,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseTables.columnMutationProductId}) 
        REFERENCES ${DatabaseTables.products} (${DatabaseTables.columnId}) 
        ON DELETE CASCADE
    )
  ''';

  static const String createIndexProductQuery = '''
    CREATE INDEX IF NOT EXISTS idx_stock_mutations_product ON ${DatabaseTables.stockMutations} (
      ${DatabaseTables.columnMutationProductId},
      ${DatabaseTables.columnCreatedAt} DESC
    )
  ''';

  static const String createIndexStoreQuery = '''
    CREATE INDEX IF NOT EXISTS idx_stock_mutations_store ON ${DatabaseTables.stockMutations} (
      ${DatabaseTables.columnMutationStoreId},
      ${DatabaseTables.columnCreatedAt} DESC
    )
  ''';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(createTableQuery);
    await db.execute(createIndexProductQuery);
    await db.execute(createIndexStoreQuery);
  }
}

