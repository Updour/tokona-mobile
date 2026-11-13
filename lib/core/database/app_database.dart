import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/auth/data/schemas/session_schema.dart';
import 'package:tokona/features/auth/data/schemas/store_schema.dart';
import 'package:tokona/features/auth/data/schemas/user_schema.dart';
import 'package:tokona/features/product/data/schemas/category_schema.dart';
import 'package:tokona/features/product/data/schemas/product_schema.dart';
import 'package:tokona/features/product/data/schemas/product_price_tier_schema.dart';
import 'package:tokona/features/product/data/schemas/product_type_schema.dart';
import 'package:tokona/features/product/data/schemas/product_unit_schema.dart';
import 'package:tokona/features/pos/data/schemas/sale_item_schema.dart';
import 'package:tokona/features/pos/data/schemas/sale_schema.dart';
import 'package:tokona/features/purchase/data/schemas/device_schema.dart';
import 'package:tokona/features/purchase/data/schemas/payment_account_schema.dart';
import 'package:tokona/features/purchase/data/schemas/purchase_item_schema.dart';
import 'package:tokona/features/purchase/data/schemas/purchase_schema.dart';
import 'package:tokona/features/customer/data/schemas/customer_schema.dart';
import 'package:tokona/features/customer/data/schemas/customer_receivable_payment_schema.dart';
import 'package:tokona/features/payment/data/schemas/store_capital_schema.dart';
import 'package:tokona/features/product/data/schemas/stock_mutation_schema.dart';
import 'package:tokona/features/supplier/data/schemas/supplier_schema.dart';

class AppDatabase {
  static const String databaseName = 'tokona_pos.db';
  static const int databaseVersion = 18;

  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();
  factory AppDatabase() => instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase({String? pathOverride}) async {
    final String dbPath = pathOverride ?? await _resolveDatabasePath();

    return await openDatabase(
      dbPath,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await StoreSchema.create(db);
        await UserSchema.create(db);
        await ProductSchema.create(db);
        await ProductUnitSchema.create(db);
        await ProductPriceTierSchema.create(db);
        await SupplierSchema.create(db);
        await CustomerSchema.create(db);
        await CategorySchema.create(db);
        await ProductTypeSchema.create(db);
        await SessionSchema.create(db);
        await PurchaseSchema.create(db);
        await PurchaseItemSchema.create(db);
        await SaleSchema.create(db);
        await SaleItemSchema.create(db);
        await StockMutationSchema.create(db);
        await StoreCapitalSchema.create(db);
        await CustomerReceivablePaymentSchema.create(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await ProductSchema.create(db);
          await ProductUnitSchema.create(db);
        }
        if (oldVersion < 3) {
          await SessionSchema.create(db);
        }
        if (oldVersion < 4) {
          await PurchaseSchema.create(db);
          await PurchaseItemSchema.create(db);
        }
        if (oldVersion < 5) {
          await SaleSchema.create(db);
          await SaleItemSchema.create(db);
        }
        if (oldVersion < 6) {
          await _addColumnIfNotExists(db, DatabaseTables.products, DatabaseTables.columnProductType, "TEXT DEFAULT 'Fisik'");
        }
        if (oldVersion < 7) {
          await CategorySchema.create(db);
          await ProductTypeSchema.create(db);
        }
        if (oldVersion < 8) {
          await _addColumnIfNotExists(db, DatabaseTables.products, DatabaseTables.columnProductImagePath, 'TEXT');
        }
        if (oldVersion < 9) {
          await _addColumnIfNotExists(db, DatabaseTables.products, DatabaseTables.columnProductExpiredAt, 'TEXT');
        }
        if (oldVersion < 10) {
          await ProductPriceTierSchema.create(db);
        }
        if (oldVersion < 13) {
          await _ensurePurchaseColumnsExist(db);
        }
        if (oldVersion < 15) {
          await StockMutationSchema.create(db);
        }
        if (oldVersion < 16) {
          await _addColumnIfNotExists(db, DatabaseTables.sales, DatabaseTables.columnSaleStatus, "TEXT DEFAULT 'COMPLETED'");
        }
        if (oldVersion < 17) {
          await StoreCapitalSchema.create(db);
        }
        if (oldVersion < 18) {
          await CustomerReceivablePaymentSchema.create(db);
        }
      },
      onOpen: (db) async {
        await _ensurePurchaseColumnsExist(db);
      },
    );
  }

  Future<void> _ensurePurchaseColumnsExist(Database db) async {
    try {
      await CustomerSchema.create(db);
    } catch (_) {}
    try {
      await SupplierSchema.create(db);
    } catch (_) {}
    try {
      await DeviceSchema.create(db);
    } catch (_) {}
    try {
      await PaymentAccountSchema.create(db);
    } catch (_) {}
    try {
      await StockMutationSchema.create(db);
    } catch (_) {}
    try {
      await StoreCapitalSchema.create(db);
    } catch (_) {}
    await _addColumnIfNotExists(db, DatabaseTables.paymentAccounts, DatabaseTables.columnAccountHolderName, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.paymentAccounts, DatabaseTables.columnAccountInitialBalance, 'REAL DEFAULT 0.0');
    await _addColumnIfNotExists(db, DatabaseTables.paymentAccounts, DatabaseTables.columnAccountCurrentBalance, 'REAL DEFAULT 0.0');
    await _addColumnIfNotExists(db, DatabaseTables.paymentAccounts, DatabaseTables.columnAccountIsActive, 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseSupplierId, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseSupplierName, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseType, "TEXT DEFAULT 'offline'");
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchasePlatform, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseDeviceTag, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchasePaymentAccount, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseServiceFee, 'REAL DEFAULT 0.0');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseShippingFee, 'REAL DEFAULT 0.0');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseStatus, "TEXT DEFAULT 'received'");
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchasePoDays, 'INTEGER');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseEstimatedArrival, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseRefundStatus, "TEXT DEFAULT 'none'");
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseImagePath, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.purchases, DatabaseTables.columnPurchaseTrackingNumber, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.sales, DatabaseTables.columnSaleCustomerId, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.sales, DatabaseTables.columnSaleStatus, "TEXT DEFAULT 'COMPLETED'");
    await _addColumnIfNotExists(db, DatabaseTables.sales, DatabaseTables.columnSaleDueDate, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.sales, DatabaseTables.columnSaleImagePath, 'TEXT');
    await _addColumnIfNotExists(db, DatabaseTables.products, DatabaseTables.columnProductDeviceTag, 'TEXT');
  }

  Future<void> _addColumnIfNotExists(Database db, String table, String column, String type) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($table)');
      final columnExists = info.any((col) => col['name'] == column);
      if (!columnExists) {
        await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
      }
    } catch (_) {
      // Ignore if table doesn't exist yet or already altered
    }
  }

  Future<String> _resolveDatabasePath() async {
    final defaultPath = await getDatabasesPath();
    return p.join(defaultPath, databaseName);
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
