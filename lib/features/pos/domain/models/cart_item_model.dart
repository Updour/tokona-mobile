import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class CartItemModel {
  final ProductModel product;
  final ProductUnitModel? selectedUnit;
  final double quantity;

  const CartItemModel({
    required this.product,
    this.selectedUnit,
    required this.quantity,
  });

  String get productName => product.name;
  String get unitName => selectedUnit?.unitName ?? product.baseUnit;
  double get conversionFactor => selectedUnit?.conversionFactor ?? 1.0;
  double get standardUnitPrice => selectedUnit?.sellingPrice ?? product.baseSellingPrice;
  double get unitPrice => product.getEffectivePrice(quantity, unitName: unitName);
  bool get hasTierDiscount => unitPrice < standardUnitPrice;
  double get subtotal => quantity * unitPrice;
  double get totalBaseQuantity => quantity * conversionFactor;
  double get baseCostPrice => product.baseCostPrice;
  bool get hasEnoughStock => product.stockBase >= totalBaseQuantity;

  CartItemModel copyWith({
    ProductModel? product,
    ProductUnitModel? selectedUnit,
    bool clearUnit = false,
    double? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      selectedUnit: clearUnit ? null : (selectedUnit ?? this.selectedUnit),
      quantity: quantity ?? this.quantity,
    );
  }
}
