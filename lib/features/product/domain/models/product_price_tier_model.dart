class ProductPriceTierModel {
  final String id;
  final String productId;
  final String? unitName;
  final double minQuantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const ProductPriceTierModel({
    required this.id,
    required this.productId,
    this.unitName,
    required this.minQuantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'unit_name': unitName,
      'min_quantity': minQuantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory ProductPriceTierModel.fromMap(Map<String, dynamic> map) {
    return ProductPriceTierModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      unitName: map['unit_name'] as String?,
      minQuantity: (map['min_quantity'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }

  ProductPriceTierModel copyWith({
    String? id,
    String? productId,
    String? unitName,
    double? minQuantity,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return ProductPriceTierModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      unitName: unitName ?? this.unitName,
      minQuantity: minQuantity ?? this.minQuantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
