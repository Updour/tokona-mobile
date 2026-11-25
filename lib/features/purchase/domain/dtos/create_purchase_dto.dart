import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';

class CreatePurchaseDto {
  final String storeId;
  final String userId;
  final String? invoiceNumber;
  final String? supplierId;
  final String? supplierName;
  final String purchaseType;
  final String? platform;
  final String? deviceTag;
  final String? paymentAccount;
  final double serviceFee;
  final double shippingFee;
  final String status;
  final int? poDays;
  final DateTime? estimatedArrival;
  final DateTime? estimatedArrivalEnd;
  final String? notes;
  final String? imagePath;
  final String? trackingNumber;
  final int installmentMonths;
  final double monthlyInstallment;
  final String? coPartner;
  final double coProfit;
  final bool addToStock;
  final double shippingDiscount;
  final double voucherDiscount;
  final List<CreatePurchaseItemDto> items;

  const CreatePurchaseDto({
    required this.storeId,
    required this.userId,
    this.invoiceNumber,
    this.supplierId,
    this.supplierName,
    this.purchaseType = 'offline',
    this.platform,
    this.deviceTag,
    this.paymentAccount,
    this.serviceFee = 0.0,
    this.shippingFee = 0.0,
    this.status = 'received',
    this.poDays,
    this.estimatedArrival,
    this.estimatedArrivalEnd,
    this.notes,
    this.imagePath,
    this.trackingNumber,
    this.installmentMonths = 1,
    this.monthlyInstallment = 0.0,
    this.coPartner,
    this.coProfit = 0.0,
    this.addToStock = true,
    this.shippingDiscount = 0.0,
    this.voucherDiscount = 0.0,
    required this.items,
  });

  double get itemsSubtotal {
    return items.fold<double>(0.0, (acc, item) => acc + item.subtotal);
  }

  double get totalAmount => itemsSubtotal;

  double get totalDiscount => shippingDiscount + voucherDiscount;

  double get grandTotal {
    return (itemsSubtotal + serviceFee + shippingFee - shippingDiscount - voucherDiscount).clamp(0.0, double.infinity);
  }

  String? validate() {
    if (storeId.trim().isEmpty) return 'Toko tidak valid';
    if (userId.trim().isEmpty) return 'Pengguna tidak valid';
    if (items.isEmpty) return 'Paling sedikit harus ada 1 item barang yang dibeli';

    for (final item in items) {
      final err = item.validate();
      if (err != null) return err;
    }
    return null;
  }
}
