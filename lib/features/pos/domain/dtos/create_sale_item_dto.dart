class CreateSaleItemDto {
  final String productId;
  final String? unitId;
  final String unitName;
  final double quantity;
  final double conversionFactor;
  final double sellingPrice;
  final double costPrice;

  const CreateSaleItemDto({
    required this.productId,
    this.unitId,
    required this.unitName,
    required this.quantity,
    required this.conversionFactor,
    required this.sellingPrice,
    required this.costPrice,
  });

  double get subtotal => quantity * sellingPrice;
  double get totalBaseQuantity => quantity * conversionFactor;

  String? validate() {
    if (productId.trim().isEmpty) return 'Produk tidak valid';
    if (quantity <= 0) return 'Jumlah item harus lebih dari 0';
    if (sellingPrice < 0) return 'Harga jual tidak boleh negatif';
    if (conversionFactor <= 0) return 'Faktor konversi tidak valid';
    return null;
  }
}
