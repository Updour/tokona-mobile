import 'dart:math';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';

class HeldCartModel {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final String? note;
  final String deliveryMethod; // 'pickup' (Ambil di Rumah/Toko) or 'delivery' (Dianterin)
  final DateTime? plannedDate;
  final DateTime heldAt;
  final List<CartItemModel> items;
  final double discountAmount;
  final double? manualAmount;
  final String waStatus; // 'MENUNGGU', 'TERKIRIM', 'GAGAL'
  final DateTime? waSentAt;
  final String? waLogMessage;

  const HeldCartModel({
    required this.id,
    this.customerName,
    this.customerPhone,
    this.note,
    this.deliveryMethod = 'pickup',
    this.plannedDate,
    required this.heldAt,
    required this.items,
    this.discountAmount = 0.0,
    this.manualAmount,
    this.waStatus = 'MENUNGGU',
    this.waSentAt,
    this.waLogMessage,
  });

  bool get isDelivery => deliveryMethod == 'delivery';
  String get deliveryMethodLabel => isDelivery ? 'Dianterin' : 'Diambil di Rumah/Toko';

  bool get isWaSent => waStatus == 'TERKIRIM';
  bool get isWaFailed => waStatus == 'GAGAL';
  bool get isWaPending => waStatus == 'MENUNGGU';

  int get totalItemCount => items.isEmpty && (note != null || manualAmount != null) ? 1 : items.length;
  double get totalQuantity => items.fold(0.0, (acc, item) => acc + item.quantity);
  double get subtotal => manualAmount ?? items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get finalAmount => max(0.0, subtotal - discountAmount);

  HeldCartModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? note,
    String? deliveryMethod,
    DateTime? plannedDate,
    DateTime? heldAt,
    List<CartItemModel>? items,
    double? discountAmount,
    double? manualAmount,
    String? waStatus,
    DateTime? waSentAt,
    String? waLogMessage,
  }) {
    return HeldCartModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      note: note ?? this.note,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      plannedDate: plannedDate ?? this.plannedDate,
      heldAt: heldAt ?? this.heldAt,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      manualAmount: manualAmount ?? this.manualAmount,
      waStatus: waStatus ?? this.waStatus,
      waSentAt: waSentAt ?? this.waSentAt,
      waLogMessage: waLogMessage ?? this.waLogMessage,
    );
  }
}
