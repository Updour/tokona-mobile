import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_price_tier_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class ProductModel {
  final String id;
  final String storeId;
  final String? sku;
  final String name;
  final String? category;
  final String productType;
  final String? imagePath;
  final DateTime? expiredAt;
  final String? deviceTag;
  final String baseUnit;
  final double stockBase;
  final double minStockAlert;
  final double baseCostPrice;
  final double baseSellingPrice;
  final List<ProductUnitModel> units;
  final List<ProductPriceTierModel> priceTiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const ProductModel({
    required this.id,
    required this.storeId,
    this.sku,
    required this.name,
    this.category,
    this.productType = 'Fisik',
    this.imagePath,
    this.expiredAt,
    this.deviceTag,
    required this.baseUnit,
    this.stockBase = 0,
    this.minStockAlert = 0,
    required this.baseCostPrice,
    required this.baseSellingPrice,
    this.units = const [],
    this.priceTiers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  List<ProductUnitModel> get packagingUnits => units;

  List<String> get deviceTags {
    if (deviceTag == null || deviceTag!.trim().isEmpty) return const [];
    return deviceTag!
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
  }

  double get marginPerBaseUnit => baseSellingPrice - baseCostPrice;

  double get marginPercentage {
    if (baseCostPrice <= 0) return 0;
    return ((baseSellingPrice - baseCostPrice) / baseCostPrice) * 100;
  }

  bool get isLowStock => stockBase <= minStockAlert;

  bool get isOutOfStock => stockBase <= 0;

  bool get isExpired {
    if (expiredAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDate = DateTime(expiredAt!.year, expiredAt!.month, expiredAt!.day);
    return expDate.isBefore(today);
  }

  bool get isExpiringSoon {
    if (expiredAt == null || isExpired) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDate = DateTime(expiredAt!.year, expiredAt!.month, expiredAt!.day);
    final daysRemaining = expDate.difference(today).inDays;
    return daysRemaining <= 30;
  }

  double stockInUnit(double conversionFactor) {
    if (conversionFactor <= 0) return stockBase;
    return stockBase / conversionFactor;
  }

  double getEffectivePrice(double quantity, {String? unitName}) {
    final targetUnit = unitName ?? baseUnit;
    if (priceTiers.isEmpty) {
      if (unitName != null && unitName != baseUnit) {
        for (final u in units) {
          if (u.unitName == unitName) return u.sellingPrice;
        }
      }
      return baseSellingPrice;
    }

    final matchingTiers = priceTiers.where((tier) {
      final matchesUnit = tier.unitName == null ||
          tier.unitName!.isEmpty ||
          tier.unitName == targetUnit;
      return matchesUnit && quantity >= tier.minQuantity;
    }).toList();

    if (matchingTiers.isEmpty) {
      if (unitName != null && unitName != baseUnit) {
        for (final u in units) {
          if (u.unitName == unitName) return u.sellingPrice;
        }
      }
      return baseSellingPrice;
    }

    matchingTiers.sort((a, b) => b.minQuantity.compareTo(a.minQuantity));
    return matchingTiers.first.price;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'sku': sku,
      'name': name,
      'category': category,
      'product_type': productType,
      'image_path': imagePath,
      'expired_at': expiredAt?.toIso8601String(),
      'device_tag': deviceTag,
      'base_unit': baseUnit,
      'stock_base': stockBase,
      'min_stock_alert': minStockAlert,
      'base_cost_price': baseCostPrice,
      'base_selling_price': baseSellingPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(
    Map<String, dynamic> map, {
    List<ProductUnitModel> units = const [],
    List<ProductPriceTierModel> priceTiers = const [],
  }) {
    return ProductModel(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      sku: map['sku'] as String?,
      name: map['name'] as String,
      category: map['category'] as String?,
      productType: map['product_type'] as String? ?? 'Fisik',
      imagePath: map['image_path'] as String?,
      expiredAt: map['expired_at'] != null ? DateTime.tryParse(map['expired_at'].toString()) : null,
      deviceTag: map['device_tag'] as String?,
      baseUnit: map['base_unit'] as String,
      stockBase: (map['stock_base'] as num).toDouble(),
      minStockAlert: (map['min_stock_alert'] as num? ?? 0).toDouble(),
      baseCostPrice: (map['base_cost_price'] as num).toDouble(),
      baseSellingPrice: (map['base_selling_price'] as num).toDouble(),
      units: units,
      priceTiers: priceTiers,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? sku,
    String? name,
    String? category,
    String? productType,
    String? imagePath,
    bool clearImage = false,
    DateTime? expiredAt,
    bool clearExpiredAt = false,
    String? deviceTag,
    bool clearDeviceTag = false,
    String? baseUnit,
    double? stockBase,
    double? minStockAlert,
    double? baseCostPrice,
    double? baseSellingPrice,
    List<ProductUnitModel>? units,
    List<ProductPriceTierModel>? priceTiers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      productType: productType ?? this.productType,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      expiredAt: clearExpiredAt ? null : (expiredAt ?? this.expiredAt),
      deviceTag: clearDeviceTag ? null : (deviceTag ?? this.deviceTag),
      baseUnit: baseUnit ?? this.baseUnit,
      stockBase: stockBase ?? this.stockBase,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      baseCostPrice: baseCostPrice ?? this.baseCostPrice,
      baseSellingPrice: baseSellingPrice ?? this.baseSellingPrice,
      units: units ?? this.units,
      priceTiers: priceTiers ?? this.priceTiers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  UpdateProductDto toUpdateDto({
    double? stockBase,
    double? baseCostPrice,
    double? baseSellingPrice,
    String? imagePath,
    bool clearImage = false,
    DateTime? expiredAt,
    bool clearExpiredAt = false,
    String? deviceTag,
    bool clearDeviceTag = false,
  }) {
    return UpdateProductDto(
      name: name,
      sku: sku,
      category: category,
      productType: productType,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      clearImage: clearImage,
      expiredAt: clearExpiredAt ? null : (expiredAt ?? this.expiredAt),
      clearExpiredAt: clearExpiredAt,
      deviceTag: clearDeviceTag ? null : (deviceTag ?? this.deviceTag),
      clearDeviceTag: clearDeviceTag,
      baseUnit: baseUnit,
      stockBase: stockBase ?? this.stockBase,
      minStockAlert: minStockAlert,
      baseCostPrice: baseCostPrice ?? this.baseCostPrice,
      baseSellingPrice: baseSellingPrice ?? this.baseSellingPrice,
      packagingUnits: units
          .map(
            (u) => CreateProductUnitDto(
              unitName: u.unitName,
              conversionFactor: u.conversionFactor,
              costPrice: (baseCostPrice ?? this.baseCostPrice) * u.conversionFactor,
              sellingPrice: u.sellingPrice,
              barcode: u.barcode,
            ),
          )
          .toList(),
      priceTiers: priceTiers
          .map(
            (t) => CreateProductPriceTierDto(
              unitName: t.unitName,
              minQuantity: t.minQuantity,
              price: t.price,
            ),
          )
          .toList(),
    );
  }
}
