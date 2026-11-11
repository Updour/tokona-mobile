import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/product/data/daos/product_dao.dart';
import 'package:tokona/features/product/data/daos/product_price_tier_dao.dart';
import 'package:tokona/features/product/data/daos/product_unit_dao.dart';
import 'package:tokona/features/product/data/services/product_image_service.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/device_stock_summary.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_price_tier_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';
import 'package:tokona/features/product/domain/models/product_valuation_model.dart';

class ProductRepository {
  final AppDatabase _appDatabase;
  late final ProductDao _productDao;
  late final ProductUnitDao _productUnitDao;
  late final ProductPriceTierDao _productPriceTierDao;
  Database? _db;

  ProductRepository(this._appDatabase) {
    _productDao = ProductDao(() => _db!);
    _productUnitDao = ProductUnitDao(() => _db!);
    _productPriceTierDao = ProductPriceTierDao(() => _db!);
  }

  Future<void> initialize() async {
    _db = await _appDatabase.database;
  }

  Future<ProductModel> createProduct(String storeId, CreateProductDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) throw ArgumentError(validationError);

    final now = DateTime.now();
    final productId = IdGenerator.generateId(prefix: 'PRD');

    final product = ProductModel(
      id: productId,
      storeId: storeId,
      sku: dto.sku?.trim().isEmpty ?? true ? null : dto.sku?.trim(),
      name: dto.name.trim(),
      category: dto.category?.trim().isEmpty ?? true ? null : dto.category?.trim(),
      productType: dto.productType,
      imagePath: dto.imagePath,
      expiredAt: dto.expiredAt,
      deviceTag: dto.deviceTag?.trim().isEmpty ?? true ? null : dto.deviceTag?.trim(),
      baseUnit: dto.baseUnit.trim(),
      stockBase: dto.initialStock,
      minStockAlert: dto.minStockAlert,
      baseCostPrice: dto.baseCostPrice,
      baseSellingPrice: dto.baseSellingPrice,
      createdAt: now,
      updatedAt: now,
    );

    final units = dto.packagingUnits.map((u) => ProductUnitModel(
      id: IdGenerator.generateId(prefix: 'UNT'),
      productId: productId,
      unitName: u.unitName.trim(),
      conversionFactor: u.conversionFactor,
      costPrice: u.costPrice,
      sellingPrice: u.sellingPrice,
      barcode: u.barcode?.trim().isEmpty ?? true ? null : u.barcode?.trim(),
      createdAt: now,
      updatedAt: now,
    )).toList();

    final tiers = dto.priceTiers.map((t) => ProductPriceTierModel(
      id: IdGenerator.generateId(prefix: 'PTR'),
      productId: productId,
      unitName: t.unitName?.trim().isEmpty ?? true ? null : t.unitName?.trim(),
      minQuantity: t.minQuantity,
      price: t.price,
      createdAt: now,
      updatedAt: now,
    )).toList();

    await _db!.transaction((txn) async {
      await _productDao.insertProduct(product, txn: txn);
      for (final unit in units) await _productUnitDao.insertUnit(unit, txn: txn);
      for (final tier in tiers) await _productPriceTierDao.insertTier(tier, txn: txn);
    });

    return product.copyWith(units: units, priceTiers: tiers);
  }

  Future<ProductModel> updateProduct(String productId, UpdateProductDto dto) async {
    await initialize();
    final validationError = dto.validate();
    if (validationError != null) throw ArgumentError(validationError);

    final existingProduct = await _productDao.getProductById(productId);
    if (existingProduct == null) throw StateError('Produk tidak ditemukan');

    String? finalImagePath = existingProduct.imagePath;
    if (dto.clearImage) {
      finalImagePath = null;
    } else if (dto.imagePath != null) {
      finalImagePath = dto.imagePath;
    }

    DateTime? finalExpiredAt = existingProduct.expiredAt;
    if (dto.clearExpiredAt) {
      finalExpiredAt = null;
    } else if (dto.expiredAt != null) {
      finalExpiredAt = dto.expiredAt;
    }

    final now = DateTime.now();
    final updatedProduct = ProductModel(
      id: productId,
      storeId: existingProduct.storeId,
      sku: dto.sku?.trim().isEmpty ?? true ? null : dto.sku?.trim(),
      name: dto.name.trim(),
      category: dto.category?.trim().isEmpty ?? true ? null : dto.category?.trim(),
      productType: dto.productType,
      imagePath: finalImagePath,
      expiredAt: finalExpiredAt,
      deviceTag: dto.clearDeviceTag ? null : (dto.deviceTag?.trim().isEmpty ?? true ? existingProduct.deviceTag : dto.deviceTag?.trim()),
      baseUnit: dto.baseUnit.trim(),
      stockBase: dto.stockBase ?? existingProduct.stockBase,
      minStockAlert: dto.minStockAlert,
      baseCostPrice: dto.baseCostPrice,
      baseSellingPrice: dto.baseSellingPrice,
      createdAt: existingProduct.createdAt,
      updatedAt: now,
    );

    final units = dto.packagingUnits.map((u) => ProductUnitModel(
      id: IdGenerator.generateId(prefix: 'UNT'),
      productId: productId,
      unitName: u.unitName.trim(),
      conversionFactor: u.conversionFactor,
      costPrice: dto.baseCostPrice * u.conversionFactor,
      sellingPrice: u.sellingPrice,
      barcode: u.barcode?.trim().isEmpty ?? true ? null : u.barcode?.trim(),
      createdAt: now,
      updatedAt: now,
    )).toList();

    final tiers = dto.priceTiers.map((t) => ProductPriceTierModel(
      id: IdGenerator.generateId(prefix: 'PTR'),
      productId: productId,
      unitName: t.unitName?.trim().isEmpty ?? true ? null : t.unitName?.trim(),
      minQuantity: t.minQuantity,
      price: t.price,
      createdAt: now,
      updatedAt: now,
    )).toList();

    await _db!.transaction((txn) async {
      await _productDao.updateProduct(updatedProduct, txn: txn);
      await _productUnitDao.deleteUnitsByProductId(productId, txn: txn);
      for (final unit in units) {
        await _productUnitDao.insertUnit(unit, txn: txn);
      }
      await _productPriceTierDao.deleteTiersByProductId(productId, txn: txn);
      for (final tier in tiers) {
        await _productPriceTierDao.insertTier(tier, txn: txn);
      }
    });

    return updatedProduct.copyWith(units: units, priceTiers: tiers);
  }

  Future<List<ProductModel>> getProducts(
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
    await initialize();

    final baseProducts = await _productDao.getProductsByStore(
      storeId,
      searchQuery: searchQuery,
      category: category,
      deviceTag: deviceTag,
      stockFilter: stockFilter,
      startDate: startDate,
      endDate: endDate,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );

    final List<ProductModel> fullProducts = [];
    for (final product in baseProducts) {
      final units = await _productUnitDao.getUnitsByProductId(product.id);
      final tiers = await _productPriceTierDao.getTiersByProductId(product.id);
      fullProducts.add(product.copyWith(units: units, priceTiers: tiers));
    }

    return fullProducts;
  }

  Future<List<DeviceStockSummary>> getDeviceSummaries(String storeId) async {
    await initialize();
    return await _productDao.getDeviceStockSummaries(storeId);
  }

  Future<ProductValuationModel> getValuation(String storeId) async {
    await initialize();
    return await _productDao.getInventoryValuation(storeId);
  }

  Future<int> getTransactionCount(String productId) async {
    await initialize();
    final sCount = Sqflite.firstIntValue(await _db!.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseTables.saleItems} WHERE ${DatabaseTables.columnSaleItemProductId} = ?',
      [productId],
    )) ?? 0;
    final pCount = Sqflite.firstIntValue(await _db!.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseTables.purchaseItems} WHERE ${DatabaseTables.columnPurchaseItemProductId} = ?',
      [productId],
    )) ?? 0;
    return sCount + pCount;
  }

  Future<void> deleteProduct(String productId, {bool force = false}) async {
    await initialize();
    final existing = await _productDao.getProductById(productId);
    await _db!.transaction((txn) async {
      await _productPriceTierDao.deleteTiersByProductId(productId, txn: txn);
      await _productUnitDao.deleteUnitsByProductId(productId, txn: txn);
      await txn.delete(
        DatabaseTables.stockMutations,
        where: '${DatabaseTables.columnMutationProductId} = ?',
        whereArgs: [productId],
      );
      if (force) {
        await txn.delete(DatabaseTables.saleItems, where: '${DatabaseTables.columnSaleItemProductId} = ?', whereArgs: [productId]);
        await txn.delete(DatabaseTables.purchaseItems, where: '${DatabaseTables.columnPurchaseItemProductId} = ?', whereArgs: [productId]);
      }
      await _productDao.deleteProduct(productId, txn: txn);
    });
    if (existing?.imagePath != null) {
      await ProductImageService.deleteImageFile(existing!.imagePath);
    }
  }

  Future<int> countProducts(String storeId) async {
    await initialize();
    return await _productDao.countProductsByStore(storeId);
  }

  Future<void> updateStock(String productId, double newStock) async {
    await initialize();
    await _productDao.updateStock(productId, newStock);
  }

  Future<void> updatePrices(String productId, double baseCostPrice, double baseSellingPrice) async {
    await initialize();
    await _db!.transaction((txn) async {
      await _productDao.updatePrices(productId, baseCostPrice, baseSellingPrice, txn: txn);
      final existingUnits = await _productUnitDao.getUnitsByProductId(productId);
      for (final u in existingUnits) {
        final updatedUnit = u.copyWith(
          costPrice: baseCostPrice * u.conversionFactor,
          updatedAt: DateTime.now(),
        );
        await _productUnitDao.insertUnit(updatedUnit, txn: txn);
      }
    });
  }
}
