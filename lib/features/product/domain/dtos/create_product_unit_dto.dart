class CreateProductUnitDto {
  final String unitName;
  final double conversionFactor;
  final double costPrice;
  final double sellingPrice;
  final String? barcode;

  const CreateProductUnitDto({
    required this.unitName,
    required this.conversionFactor,
    required this.costPrice,
    required this.sellingPrice,
    this.barcode,
  });

  String? validate() {
    if (unitName.trim().isEmpty) {
      return 'Nama satuan kemasan wajib diisi';
    }
    if (conversionFactor <= 1) {
      return 'Faktor konversi harus lebih dari 1 terhadap satuan dasar';
    }
    if (costPrice < 0) {
      return 'Harga modal HPP tidak boleh bernilai negatif';
    }
    if (sellingPrice < 0) {
      return 'Harga jual tidak boleh bernilai negatif';
    }
    return null;
  }
}
