class ProductUnitModel {
  final String id;
  final String productId;
  final String unitName;
  final double conversionFactor;
  final double costPrice;
  final double sellingPrice;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const ProductUnitModel({
    required this.id,
    required this.productId,
    required this.unitName,
    required this.conversionFactor,
    required this.costPrice,
    required this.sellingPrice,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  double get marginPerUnit => sellingPrice - costPrice;

  double get marginPercentage {
    if (costPrice <= 0) return 0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'unit_name': unitName,
      'conversion_factor': conversionFactor,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory ProductUnitModel.fromMap(Map<String, dynamic> map) {
    return ProductUnitModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      unitName: map['unit_name'] as String,
      conversionFactor: (map['conversion_factor'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }

  ProductUnitModel copyWith({
    String? id,
    String? productId,
    String? unitName,
    double? conversionFactor,
    double? costPrice,
    double? sellingPrice,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return ProductUnitModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      unitName: unitName ?? this.unitName,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
