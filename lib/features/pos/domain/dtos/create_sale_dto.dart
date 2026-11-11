import 'package:tokona/features/pos/domain/dtos/create_sale_item_dto.dart';

class CreateSaleDto {
  final String storeId;
  final String userId;
  final String? customerId;
  final String? customerName;
  final double discountAmount;
  final double cashPaid;
  final String paymentMethod;
  final String? notes;
  final DateTime? dueDate;
  final List<CreateSaleItemDto> items;

  const CreateSaleDto({
    required this.storeId,
    required this.userId,
    this.customerId,
    this.customerName,
    this.discountAmount = 0.0,
    required this.cashPaid,
    this.paymentMethod = 'CASH',
    this.notes,
    this.dueDate,
    required this.items,
  });

  double get totalAmount => items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get finalAmount => (totalAmount - discountAmount) < 0 ? 0 : (totalAmount - discountAmount);
  double get changeAmount => (cashPaid - finalAmount) < 0 ? 0 : (cashPaid - finalAmount);

  String? validate() {
    if (storeId.trim().isEmpty) return 'Toko tidak valid';
    if (userId.trim().isEmpty) return 'User tidak valid';
    if (items.isEmpty) return 'Keranjang belanja kasir masih kosong';

    final isKasbon = paymentMethod.toUpperCase() == 'KASBON';
    if (isKasbon) {
      if (customerId == null || customerId!.trim().isEmpty) {
        return 'Pilih pelanggan terlebih dahulu untuk transaksi Kasbon';
      }
    } else if (cashPaid < finalAmount) {
      return 'Uang pembayaran kurang dari total tagihan';
    }

    for (final item in items) {
      final err = item.validate();
      if (err != null) return err;
    }
    return null;
  }
}
