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

  bool addToCart(ProductModel product, {ProductUnitModel? unit, double qty = 1.0}) {
    final factor = unit?.conversionFactor ?? 1.0;
    final totalBaseNeeded = qty * factor;

    // Hitung total base qty yang sudah ada di cart untuk produk ini
    final currentBaseInCart = state.items
        .where((item) => item.product.id == product.id)
        .fold(0.0, (acc, item) => acc + item.totalBaseQuantity);

    if (currentBaseInCart + totalBaseNeeded > product.stockBase) {
      return false; // Stok tidak mencukupi
    }

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
    return true;
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

  bool setItemQuantity(ProductModel product, {ProductUnitModel? unit, required double qty}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedUnit?.id == unit?.id,
    );
    if (existingIndex >= 0) {
      return updateQuantity(existingIndex, qty);
    }
    if (qty <= 0) return true;
    return addToCart(product, unit: unit, qty: qty);
  }

  bool updateQuantity(int index, double newQty) {
    if (index < 0 || index >= state.items.length) return false;
    if (newQty <= 0) {
      removeItem(index);
      return true;
    }

    final targetItem = state.items[index];
    final factor = targetItem.conversionFactor;
    final otherBaseInCart = state.items
        .asMap()
        .entries
        .where((e) => e.key != index && e.value.product.id == targetItem.product.id)
        .fold(0.0, (acc, e) => acc + e.value.totalBaseQuantity);

    if (otherBaseInCart + (newQty * factor) > targetItem.product.stockBase) {
      return false; // Melebihi stok yang tersedia
    }

    final newItems = List<CartItemModel>.from(state.items);
    newItems[index] = newItems[index].copyWith(quantity: newQty);
    state = state.copyWith(items: newItems);
    return true;
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

  void setCustomerName(String? name, [String? phone]) {
    final cleanName = name?.trim().isEmpty == true ? null : name?.trim();
    final cleanPhone = phone?.trim().isEmpty == true ? null : phone?.trim();
    state = state.copyWith(
      customerName: cleanName,
      customerPhone: cleanPhone,
      clearCustomer: cleanName == null && cleanPhone == null,
    );
  }

  void clearCart() {
    state = const CartState();
  }

  void restoreCart({
    required List<CartItemModel> items,
    double discountAmount = 0.0,
    String? customerName,
    String? customerPhone,
  }) {
    state = CartState(
      items: List.from(items),
      discountAmount: discountAmount,
      customerName: customerName,
      customerPhone: customerPhone,
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
