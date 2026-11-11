import 'package:tokona/core/database/database_tables.dart';

class PurchaseItemModel {
  final String id;
  final String purchaseId;
  final String productId;
  final String? productName;
  final String? unitId;
  final String unitName;
  final double quantity;
  final double conversionFactor;
  final double unitCost;
  final double subtotal;
  final DateTime createdAt;

  const PurchaseItemModel({
    required this.id,
    required this.purchaseId,
    required this.productId,
    this.productName,
    this.unitId,
    required this.unitName,
    required this.quantity,
    required this.conversionFactor,
    required this.unitCost,
    required this.subtotal,
    required this.createdAt,
  });

  double get totalBaseQuantity => quantity * conversionFactor;
  double get baseUnitCost => conversionFactor > 0 ? unitCost / conversionFactor : unitCost;

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      id: map[DatabaseTables.columnId] as String,
      purchaseId: map[DatabaseTables.columnPurchaseItemPurchaseId] as String,
      productId: map[DatabaseTables.columnPurchaseItemProductId] as String,
      productName: map['product_name'] as String?,
      unitId: map[DatabaseTables.columnPurchaseItemUnitId] as String?,
      unitName: map[DatabaseTables.columnPurchaseItemUnitName] as String,
      quantity: (map[DatabaseTables.columnPurchaseItemQuantity] as num).toDouble(),
      conversionFactor: (map[DatabaseTables.columnPurchaseItemConversionFactor] as num?)?.toDouble() ?? 1.0,
      unitCost: (map[DatabaseTables.columnPurchaseItemUnitCost] as num).toDouble(),
      subtotal: (map[DatabaseTables.columnPurchaseItemSubtotal] as num).toDouble(),
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnPurchaseItemPurchaseId: purchaseId,
      DatabaseTables.columnPurchaseItemProductId: productId,
      DatabaseTables.columnPurchaseItemUnitId: unitId,
      DatabaseTables.columnPurchaseItemUnitName: unitName,
      DatabaseTables.columnPurchaseItemQuantity: quantity,
      DatabaseTables.columnPurchaseItemConversionFactor: conversionFactor,
      DatabaseTables.columnPurchaseItemUnitCost: unitCost,
      DatabaseTables.columnPurchaseItemSubtotal: subtotal,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  PurchaseItemModel copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? productName,
    String? unitId,
    String? unitName,
    double? quantity,
    double? conversionFactor,
    double? unitCost,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return PurchaseItemModel(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      quantity: quantity ?? this.quantity,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      unitCost: unitCost ?? this.unitCost,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
