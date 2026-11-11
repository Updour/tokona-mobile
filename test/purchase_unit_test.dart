import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

void main() {
  group('Purchase DTO Validations', () {
    test('CreatePurchaseItemDto validates quantity and unit cost', () {
      const invalidItem = CreatePurchaseItemDto(
        productId: 'PRD-1',
        productName: 'Beras 5kg',
        unitName: 'Sak',
        quantity: 0,
        conversionFactor: 1,
        unitCost: -5000,
      );
      expect(invalidItem.validate(), isNotNull);

      const validItem = CreatePurchaseItemDto(
        productId: 'PRD-1',
        productName: 'Beras 5kg',
        unitName: 'Sak',
        quantity: 10,
        conversionFactor: 1,
        unitCost: 65000,
      );
      expect(validItem.validate(), isNull);
      expect(validItem.subtotal, 650000);
      expect(validItem.totalBaseQuantity, 10);
      expect(validItem.baseUnitCost, 65000);
    });

    test('CreatePurchaseItemDto handles packaging units conversion', () {
      const cartonItem = CreatePurchaseItemDto(
        productId: 'PRD-2',
        productName: 'Air Mineral 600ml',
        unitName: 'Karton',
        quantity: 5,
        conversionFactor: 24, // 24 bottles per carton
        unitCost: 48000, // Rp 48.000 per carton
      );
      expect(cartonItem.subtotal, 240000); // 5 * 48000
      expect(cartonItem.totalBaseQuantity, 120); // 5 * 24
      expect(cartonItem.baseUnitCost, 2000); // 48000 / 24 = 2000 per bottle
    });

    test('CreatePurchaseDto validates required store, user, and items', () {
      const emptyPurchase = CreatePurchaseDto(
        storeId: '',
        userId: 'USR-1',
        items: [],
      );
      expect(emptyPurchase.validate(), isNotNull);

      const validPurchase = CreatePurchaseDto(
        storeId: 'STR-1',
        userId: 'USR-1',
        supplierName: 'PT Sumber Makmur',
        items: [
          CreatePurchaseItemDto(
            productId: 'PRD-1',
            productName: 'Kopi Kapal Api',
            unitName: 'Dus',
            quantity: 2,
            conversionFactor: 20,
            unitCost: 30000,
          ),
          CreatePurchaseItemDto(
            productId: 'PRD-2',
            productName: 'Gula Pasir 1kg',
            unitName: 'Kg',
            quantity: 50,
            conversionFactor: 1,
            unitCost: 14000,
          ),
        ],
      );
      expect(validPurchase.validate(), isNull);
      // Subtotals: (2 * 30000 = 60000) + (50 * 14000 = 700000) = 760000
      expect(validPurchase.totalAmount, 760000);
    });
  });

  group('Moving Average HPP Logic', () {
    test('calculates accurate moving average HPP when adding stock at different cost', () {
      // Scenario:
      // Current: 100 Pcs @ Rp 2.000 (Current value = Rp 200.000)
      // Incoming: 50 Pcs @ Rp 2.600 (Incoming value = Rp 130.000)
      // Total units: 150 Pcs
      // Total value: Rp 330.000
      // Expected new HPP = 330.000 / 150 = Rp 2.200 per piece
      const double currentStock = 100;
      const double currentHpp = 2000;
      const double addedQty = 50;
      const double incomingCost = 2600;

      final double currentTotalVal = currentStock * currentHpp;
      final double incomingTotalVal = addedQty * incomingCost;
      final double newStock = currentStock + addedQty;
      final double newHpp = (currentTotalVal + incomingTotalVal) / newStock;

      expect(newStock, 150);
      expect(newHpp, 2200);
    });
  });

  group('PurchaseModel Serialization', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final model = PurchaseModel(
        id: 'PUR-1',
        storeId: 'STR-1',
        userId: 'USR-1',
        invoiceNumber: 'PO-20261028-A1B2',
        supplierName: 'Distributor Resmi',
        totalAmount: 500000,
        createdAt: now,
        updatedAt: now,
      );

      final map = model.toMap();
      final restored = PurchaseModel.fromMap(map);

      expect(restored.id, model.id);
      expect(restored.storeId, model.storeId);
      expect(restored.invoiceNumber, model.invoiceNumber);
      expect(restored.totalAmount, model.totalAmount);
      expect(restored.supplierName, model.supplierName);
    });

    test('PurchaseItemModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final item = PurchaseItemModel(
        id: 'PUI-1',
        purchaseId: 'PUR-1',
        productId: 'PRD-1',
        unitName: 'Dus',
        quantity: 4,
        conversionFactor: 12,
        unitCost: 120000,
        subtotal: 480000,
        createdAt: now,
      );

      final map = item.toMap();
      final restored = PurchaseItemModel.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.unitName, 'Dus');
      expect(restored.quantity, 4);
      expect(restored.conversionFactor, 12);
      expect(restored.subtotal, 480000);
      expect(restored.totalBaseQuantity, 48);
      expect(restored.baseUnitCost, 10000);
    });
  });
}
