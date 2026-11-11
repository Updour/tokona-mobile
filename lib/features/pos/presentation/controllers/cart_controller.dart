import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/pos/domain/models/cart_state.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

final cartProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void addToCart(ProductModel product, {ProductUnitModel? unit, double qty = 1.0}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedUnit?.id == unit?.id,
    );

    if (existingIndex >= 0) {
      final currentItem = state.items[existingIndex];
      final updatedItem = currentItem.copyWith(quantity: currentItem.quantity + qty);
      final newItems = List<CartItemModel>.from(state.items);
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      final newItem = CartItemModel(
        product: product,
        selectedUnit: unit,
        quantity: qty,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void decrementFromCart(ProductModel product, {ProductUnitModel? unit, double qty = 1.0}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedUnit?.id == unit?.id,
    );
    if (existingIndex < 0) return;

    final currentItem = state.items[existingIndex];
    final remaining = currentItem.quantity - qty;
    if (remaining <= 0) {
      removeItem(existingIndex);
    } else {
      final updatedItem = currentItem.copyWith(quantity: remaining);
      final newItems = List<CartItemModel>.from(state.items);
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    }
  }

  void updateQuantity(int index, double newQty) {
    if (index < 0 || index >= state.items.length) return;
    if (newQty <= 0) {
      removeItem(index);
      return;
    }

    final newItems = List<CartItemModel>.from(state.items);
    newItems[index] = newItems[index].copyWith(quantity: newQty);
    state = state.copyWith(items: newItems);
  }

  void changeUnit(int index, ProductUnitModel? newUnit) {
    if (index < 0 || index >= state.items.length) return;

    final newItems = List<CartItemModel>.from(state.items);
    newItems[index] = newItems[index].copyWith(
      selectedUnit: newUnit,
      clearUnit: newUnit == null,
    );
    state = state.copyWith(items: newItems);
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<CartItemModel>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discountAmount: discount < 0 ? 0 : discount);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(customerName: name, clearCustomer: name == null || name.isEmpty);
  }

  void clearCart() {
    state = const CartState();
  }

  void restoreCart({
    required List<CartItemModel> items,
    double discountAmount = 0.0,
    String? customerName,
  }) {
    state = CartState(
      items: List.from(items),
      discountAmount: discountAmount,
      customerName: customerName,
    );
  }

  String? scanBarcodeToCart(String barcode, List<ProductModel> products) {
    for (final product in products) {
      if (product.sku == barcode) {
        addToCart(product);
        return product.name;
      }
      for (final unit in product.units) {
        if (unit.barcode == barcode) {
          addToCart(product, unit: unit);
          return '${product.name} (${unit.unitName})';
        }
      }
    }
    return null;
  }
}
