import 'dart:math';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final double discountAmount;
  final double roundingAmount;
  final String? customerName;
  final String? customerPhone;

  const CartState({
    this.items = const [],
    this.discountAmount = 0.0,
    this.roundingAmount = 0.0,
    this.customerName,
    this.customerPhone,
  });

  int get totalItemCount => items.length;
  double get totalQuantity => items.fold(0.0, (acc, item) => acc + item.quantity);
  double get subtotal => items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get rawFinalAmount => max(0.0, subtotal - discountAmount);
  double get finalAmount => max(0.0, rawFinalAmount + roundingAmount);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  bool get hasStockIssue => items.any((item) => !item.hasEnoughStock);

  CartState copyWith({
    List<CartItemModel>? items,
    double? discountAmount,
    double? roundingAmount,
    String? customerName,
    String? customerPhone,
    bool clearCustomer = false,
  }) {
    return CartState(
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      roundingAmount: roundingAmount ?? this.roundingAmount,
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerPhone: clearCustomer ? null : (customerPhone ?? this.customerPhone),
    );
  }
}
