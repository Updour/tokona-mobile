class CreateProductPriceTierDto {
  final String? unitName;
  final double minQuantity;
  final double price;

  const CreateProductPriceTierDto({
    this.unitName,
    required this.minQuantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'unit_name': unitName,
      'min_quantity': minQuantity,
      'price': price,
    };
  }

  factory CreateProductPriceTierDto.fromMap(Map<String, dynamic> map) {
    return CreateProductPriceTierDto(
      unitName: map['unit_name'] as String?,
      minQuantity: (map['min_quantity'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
    );
  }
}
