class CreateStockAdjustmentDto {
  final String storeId;
  final String productId;
  final double adjustmentQty;
  final String type;
  final String reason;
  final String? notes;

  const CreateStockAdjustmentDto({
    required this.storeId,
    required this.productId,
    required this.adjustmentQty,
    required this.type,
    required this.reason,
    this.notes,
  });

  bool get isIn => type.toLowerCase() == 'in';
  bool get isOut => type.toLowerCase() == 'out';

  String? validate() {
    if (storeId.trim().isEmpty) return 'Toko tidak valid';
    if (productId.trim().isEmpty) return 'Produk wajib dipilih';
    if (adjustmentQty <= 0) return 'Jumlah penyesuaian harus lebih dari 0';
    if (type != 'in' && type != 'out') return 'Tipe mutasi harus masuk atau keluar';
    return null;
  }
}

