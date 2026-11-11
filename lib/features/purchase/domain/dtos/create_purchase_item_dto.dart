class CreatePurchaseItemDto {
  final String productId;
  final String productName;
  final String? unitId;
  final String unitName;
  final double quantity;
  final double conversionFactor;
  final double unitCost;

  const CreatePurchaseItemDto({
    required this.productId,
    required this.productName,
    this.unitId,
    required this.unitName,
    required this.quantity,
    required this.conversionFactor,
    required this.unitCost,
  });

  double get subtotal => quantity * unitCost;
  double get totalBaseQuantity => quantity * conversionFactor;
  double get baseUnitCost => conversionFactor > 0 ? unitCost / conversionFactor : unitCost;

  CreatePurchaseItemDto copyWith({
    String? productId,
    String? productName,
    String? unitId,
    String? unitName,
    double? quantity,
    double? conversionFactor,
    double? unitCost,
  }) {
    return CreatePurchaseItemDto(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      quantity: quantity ?? this.quantity,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  String? validate() {
    if (productId.trim().isEmpty) return 'Produk wajib dipilih';
    if (quantity <= 0) return 'Jumlah pembelian harus lebih dari 0';
    if (conversionFactor <= 0) return 'Faktor konversi tidak valid';
    if (unitCost < 0) return 'Harga beli tidak boleh negatif';
    return null;
  }
}
