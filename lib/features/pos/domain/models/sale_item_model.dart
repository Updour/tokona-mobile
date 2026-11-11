import 'package:tokona/core/database/database_tables.dart';

class SaleItemModel {
  final String id;
  final String saleId;
  final String productId;
  final String? productName;
  final String? unitId;
  final String unitName;
  final double quantity;
  final double conversionFactor;
  final double sellingPrice;
  final double costPrice;
  final double subtotal;
  final DateTime createdAt;

  const SaleItemModel({
    required this.id,
    required this.saleId,
    required this.productId,
    this.productName,
    this.unitId,
    required this.unitName,
    required this.quantity,
    required this.conversionFactor,
    required this.sellingPrice,
    required this.costPrice,
    required this.subtotal,
    required this.createdAt,
  });

  double get totalBaseQuantity => quantity * conversionFactor;
  double get totalProfit => subtotal - (costPrice * totalBaseQuantity);
  double get unitPrice => sellingPrice;

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map[DatabaseTables.columnId] as String,
      saleId: map[DatabaseTables.columnSaleItemSaleId] as String,
      productId: map[DatabaseTables.columnSaleItemProductId] as String,
      productName: map['product_name'] as String?,
      unitId: map[DatabaseTables.columnSaleItemUnitId] as String?,
      unitName: map[DatabaseTables.columnSaleItemUnitName] as String,
      quantity: (map[DatabaseTables.columnSaleItemQuantity] as num).toDouble(),
      conversionFactor: (map[DatabaseTables.columnSaleItemConversionFactor] as num?)?.toDouble() ?? 1.0,
      sellingPrice: (map[DatabaseTables.columnSaleItemSellingPrice] as num).toDouble(),
      costPrice: (map[DatabaseTables.columnSaleItemCostPrice] as num?)?.toDouble() ?? 0.0,
      subtotal: (map[DatabaseTables.columnSaleItemSubtotal] as num).toDouble(),
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnSaleItemSaleId: saleId,
      DatabaseTables.columnSaleItemProductId: productId,
      DatabaseTables.columnSaleItemUnitId: unitId,
      DatabaseTables.columnSaleItemUnitName: unitName,
      DatabaseTables.columnSaleItemQuantity: quantity,
      DatabaseTables.columnSaleItemConversionFactor: conversionFactor,
      DatabaseTables.columnSaleItemSellingPrice: sellingPrice,
      DatabaseTables.columnSaleItemCostPrice: costPrice,
      DatabaseTables.columnSaleItemSubtotal: subtotal,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  SaleItemModel copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    String? unitId,
    String? unitName,
    double? quantity,
    double? conversionFactor,
    double? sellingPrice,
    double? costPrice,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      quantity: quantity ?? this.quantity,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
