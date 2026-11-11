import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/features/pos/domain/dtos/create_sale_dto.dart';
import 'package:tokona/features/pos/domain/dtos/create_sale_item_dto.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

void main() {
  final now = DateTime.now();

  final dummyProduct = ProductModel(
    id: 'PRD-TEST-1',
    storeId: 'STR-TEST-1',
    sku: '899990901',
    name: 'Teh Botol Sosro 250ml',
    baseUnit: 'Btl',
    stockBase: 100, // 100 bottles
    minStockAlert: 10,
    baseCostPrice: 2500,
    baseSellingPrice: 3500,
    units: [
      ProductUnitModel(
        id: 'UNT-TEST-1',
        productId: 'PRD-TEST-1',
        unitName: 'Karton',
        conversionFactor: 24, // 24 bottles per carton
        costPrice: 60000,
        sellingPrice: 80000,
        barcode: '899990999',
        createdAt: now,
        updatedAt: now,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );

  group('CartItemModel Multi-Unit Logic', () {
    test('calculates correct subtotal and total base quantity for base unit', () {
      final item = CartItemModel(
        product: dummyProduct,
        quantity: 3,
      );

      expect(item.unitName, 'Btl');
      expect(item.unitPrice, 3500);
      expect(item.subtotal, 10500); // 3 * 3500
      expect(item.totalBaseQuantity, 3);
      expect(item.hasEnoughStock, isTrue);
    });

    test('calculates correct subtotal and base stock deduction for packaging unit', () {
      final item = CartItemModel(
        product: dummyProduct,
        selectedUnit: dummyProduct.units.first,
        quantity: 2, // 2 Karton
      );

      expect(item.unitName, 'Karton');
      expect(item.unitPrice, 80000);
      expect(item.subtotal, 160000); // 2 * 80000
      expect(item.totalBaseQuantity, 48); // 2 * 24 = 48 Btl
      expect(item.hasEnoughStock, isTrue); // 100 >= 48
    });

    test('detects out of stock condition accurately', () {
      final item = CartItemModel(
        product: dummyProduct,
        selectedUnit: dummyProduct.units.first,
        quantity: 5, // 5 Karton = 120 Btl > 100 in stock
      );

      expect(item.totalBaseQuantity, 120);
      expect(item.hasEnoughStock, isFalse);
    });
  });

  group('CartController Operations', () {
    test('adds base unit and increments quantity when added again', () {
      final controller = CartController();

      controller.addToCart(dummyProduct, qty: 1);
      expect(controller.state.items.length, 1);
      expect(controller.state.items.first.quantity, 1);

      controller.addToCart(dummyProduct, qty: 2);
      expect(controller.state.items.length, 1);
      expect(controller.state.items.first.quantity, 3);
      expect(controller.state.subtotal, 10500);
    });

    test('handles barcode scanning into cart with packaging unit matching', () {
      final controller = CartController();

      // Scan Karton barcode
      final matched = controller.scanBarcodeToCart('899990999', [dummyProduct]);
      expect(matched, 'Teh Botol Sosro 250ml (Karton)');
      expect(controller.state.items.length, 1);
      expect(controller.state.items.first.unitName, 'Karton');
      expect(controller.state.subtotal, 80000);
    });

    test('applies discount correctly to final amount', () {
      final controller = CartController();
      controller.addToCart(dummyProduct, qty: 10); // 10 * 3500 = 35000
      controller.setDiscount(5000);

      expect(controller.state.subtotal, 35000);
      expect(controller.state.discountAmount, 5000);
      expect(controller.state.finalAmount, 30000);
    });
  });

  group('CreateSaleDto Validations', () {
    test('validates insufficient cash payment', () {
      final dto = CreateSaleDto(
        storeId: 'STR-1',
        userId: 'USR-1',
        cashPaid: 20000,
        discountAmount: 0,
        items: [
          CreateSaleItemDto(
            productId: 'PRD-1',
            unitName: 'Btl',
            quantity: 10,
            conversionFactor: 1,
            sellingPrice: 3500, // Total = 35000
            costPrice: 2500,
          ),
        ],
      );

      expect(dto.validate(), contains('kurang'));
      expect(dto.finalAmount, 35000);
    });

    test('validates valid cash payment and change calculation', () {
      final dto = CreateSaleDto(
        storeId: 'STR-1',
        userId: 'USR-1',
        cashPaid: 50000,
        discountAmount: 5000,
        items: [
          CreateSaleItemDto(
            productId: 'PRD-1',
            unitName: 'Btl',
            quantity: 10,
            conversionFactor: 1,
            sellingPrice: 3500, // Subtotal = 35000, Final = 30000
            costPrice: 2500,
          ),
        ],
      );

      expect(dto.validate(), isNull);
      expect(dto.finalAmount, 30000);
      expect(dto.changeAmount, 20000); // 50000 - 30000
    });
  });

  group('Sale Serialization', () {
    test('serializes and deserializes SaleModel correctly', () {
      final sale = SaleModel(
        id: 'INV-1',
        storeId: 'STR-1',
        userId: 'USR-1',
        invoiceNumber: 'INV-20261028-9999',
        totalAmount: 100000,
        discountAmount: 10000,
        finalAmount: 90000,
        cashPaid: 100000,
        changeAmount: 10000,
        createdAt: now,
        updatedAt: now,
      );

      final map = sale.toMap();
      final restored = SaleModel.fromMap(map);

      expect(restored.id, sale.id);
      expect(restored.finalAmount, 90000);
      expect(restored.changeAmount, 10000);
    });

    test('serializes and deserializes SaleItemModel correctly', () {
      final item = SaleItemModel(
        id: 'SLI-1',
        saleId: 'INV-1',
        productId: 'PRD-1',
        unitName: 'Karton',
        quantity: 2,
        conversionFactor: 24,
        sellingPrice: 80000,
        costPrice: 60000,
        subtotal: 160000,
        createdAt: now,
      );

      final map = item.toMap();
      final restored = SaleItemModel.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.unitName, 'Karton');
      expect(restored.subtotal, 160000);
      expect(restored.totalBaseQuantity, 48);
    });
  });
}
