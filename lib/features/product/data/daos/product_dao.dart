import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/product/domain/models/device_stock_summary.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_valuation_model.dart';

class ProductDao {
  final Database Function() _getDatabase;

  ProductDao(this._getDatabase);

  Future<void> insertProduct(ProductModel product, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.products,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(ProductModel product, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.products,
      product.toMap(),
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> updateStock(String id, double newStock, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.products,
      {
        DatabaseTables.columnProductStockBase: newStock,
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePrices(String id, double baseCostPrice, double baseSellingPrice, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.products,
      {
        DatabaseTables.columnProductBaseCostPrice: baseCostPrice,
        DatabaseTables.columnProductBaseSellingPrice: baseSellingPrice,
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProduct(String id, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.products,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.products,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProductModel.fromMap(results.first);
  }

  Future<List<ProductModel>> getProductsByStore(
    String storeId, {
    String? searchQuery,
    String? category,
    String? deviceTag,
    ProductStockFilter stockFilter = ProductStockFilter.all,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    ProductSortBy sortBy = ProductSortBy.nameAsc,
  }) async {
    final db = _getDatabase();
    final List<String> whereClauses = ['${DatabaseTables.columnProductStoreId} = ?'];
    final List<dynamic> whereArgs = [storeId];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add(
        '(${DatabaseTables.columnProductName} LIKE ? OR ${DatabaseTables.columnProductSku} LIKE ?)',
      );
      final pattern = '%${searchQuery.trim()}%';
      whereArgs.add(pattern);
      whereArgs.add(pattern);
    }

    if (category != null && category.trim().isNotEmpty) {
      whereClauses.add('${DatabaseTables.columnProductCategory} = ?');
      whereArgs.add(category.trim());
    }

    if (deviceTag != null && deviceTag.trim().isNotEmpty) {
      if (deviceTag == 'Tanpa Device' || deviceTag == 'Lainnya') {
        whereClauses.add('(${DatabaseTables.columnProductDeviceTag} IS NULL OR ${DatabaseTables.columnProductDeviceTag} = "")');
      } else {
        whereClauses.add('${DatabaseTables.columnProductDeviceTag} = ?');
        whereArgs.add(deviceTag.trim());
      }
    }

    switch (stockFilter) {
      case ProductStockFilter.all:
        break;
      case ProductStockFilter.outOfStock:
        whereClauses.add('${DatabaseTables.columnProductStockBase} <= 0');
        break;
      case ProductStockFilter.lowStock:
        whereClauses.add(
          '${DatabaseTables.columnProductStockBase} > 0 AND ${DatabaseTables.columnProductStockBase} <= ${DatabaseTables.columnProductMinStockAlert}',
        );
        break;
      case ProductStockFilter.inStock:
        whereClauses.add(
          '${DatabaseTables.columnProductStockBase} > ${DatabaseTables.columnProductMinStockAlert}',
        );
        break;
    }

    if (startDate != null) {
      whereClauses.add('${DatabaseTables.columnCreatedAt} >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('${DatabaseTables.columnCreatedAt} <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (minPrice != null) {
      whereClauses.add('${DatabaseTables.columnProductBaseSellingPrice} >= ?');
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      whereClauses.add('${DatabaseTables.columnProductBaseSellingPrice} <= ?');
      whereArgs.add(maxPrice);
    }

    String orderByClause;
    switch (sortBy) {
      case ProductSortBy.nameAsc:
        orderByClause = '${DatabaseTables.columnProductName} COLLATE NOCASE ASC';
        break;
      case ProductSortBy.nameDesc:
        orderByClause = '${DatabaseTables.columnProductName} COLLATE NOCASE DESC';
        break;
      case ProductSortBy.newest:
        orderByClause = '${DatabaseTables.columnCreatedAt} DESC';
        break;
      case ProductSortBy.oldest:
        orderByClause = '${DatabaseTables.columnCreatedAt} ASC';
        break;
      case ProductSortBy.stockAsc:
        orderByClause = '${DatabaseTables.columnProductStockBase} ASC';
        break;
      case ProductSortBy.stockDesc:
        orderByClause = '${DatabaseTables.columnProductStockBase} DESC';
        break;
      case ProductSortBy.priceAsc:
        orderByClause = '${DatabaseTables.columnProductBaseSellingPrice} ASC';
        break;
      case ProductSortBy.priceDesc:
        orderByClause = '${DatabaseTables.columnProductBaseSellingPrice} DESC';
        break;
      case ProductSortBy.marginDesc:
        orderByClause = '(${DatabaseTables.columnProductBaseSellingPrice} - ${DatabaseTables.columnProductBaseCostPrice}) DESC';
        break;
    }

    final results = await db.query(
      DatabaseTables.products,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: orderByClause,
    );

    return results.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductValuationModel> getInventoryValuation(String storeId) async {
    final db = _getDatabase();
    final rows = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sku,
        COALESCE(SUM(${DatabaseTables.columnProductStockBase}), 0) as total_stock,
        COALESCE(SUM(${DatabaseTables.columnProductStockBase} * ${DatabaseTables.columnProductBaseCostPrice}), 0) as total_cost,
        COALESCE(SUM(${DatabaseTables.columnProductStockBase} * ${DatabaseTables.columnProductBaseSellingPrice}), 0) as total_revenue,
        SUM(CASE WHEN ${DatabaseTables.columnProductStockBase} <= 0 THEN 1 ELSE 0 END) as out_of_stock_count,
        SUM(CASE WHEN ${DatabaseTables.columnProductStockBase} > 0 AND ${DatabaseTables.columnProductStockBase} <= ${DatabaseTables.columnProductMinStockAlert} THEN 1 ELSE 0 END) as low_stock_count
      FROM ${DatabaseTables.products}
      WHERE ${DatabaseTables.columnProductStoreId} = ?
    ''', [storeId]);

    if (rows.isEmpty) return const ProductValuationModel();
    final r = rows.first;
    return ProductValuationModel(
      totalSku: (r['total_sku'] as num?)?.toInt() ?? 0,
      totalPhysicalStock: (r['total_stock'] as num?)?.toDouble() ?? 0.0,
      totalAssetCost: (r['total_cost'] as num?)?.toDouble() ?? 0.0,
      totalPotentialRevenue: (r['total_revenue'] as num?)?.toDouble() ?? 0.0,
      outOfStockCount: (r['out_of_stock_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (r['low_stock_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> updateStockBase(String productId, double newStock, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.update(
      DatabaseTables.products,
      {
        DatabaseTables.columnProductStockBase: newStock,
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [productId],
    );
  }

  Future<int> countProductsByStore(String storeId) async {
    final db = _getDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM ${DatabaseTables.products} WHERE ${DatabaseTables.columnProductStoreId} = ?',
      [storeId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<DeviceStockSummary>> getDeviceStockSummaries(String storeId) async {
    final db = _getDatabase();
    final rows = await db.rawQuery('''
      SELECT 
        COALESCE(${DatabaseTables.columnProductDeviceTag}, 'Tanpa Device') as device_name,
        COUNT(*) as total_sku,
        COALESCE(SUM(${DatabaseTables.columnProductStockBase}), 0) as total_stock,
        COALESCE(SUM(CASE WHEN ${DatabaseTables.columnProductStockBase} <= ${DatabaseTables.columnProductMinStockAlert} THEN 1 ELSE 0 END), 0) as low_stock_count
      FROM ${DatabaseTables.products}
      WHERE ${DatabaseTables.columnProductStoreId} = ?
      GROUP BY ${DatabaseTables.columnProductDeviceTag}
      ORDER BY total_sku DESC
    ''', [storeId]);
    return rows.map((r) => DeviceStockSummary.fromMap(r)).toList();
  }
}
