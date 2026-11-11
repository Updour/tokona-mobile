import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

void main() {
  group('Product and Packaging DTO Validations', () {
    test('CreateProductUnitDto validates conversion factor and prices', () {
      const invalidUnit = CreateProductUnitDto(
        unitName: '',
        conversionFactor: 1, // Must be > 1
        costPrice: -100,
        sellingPrice: -500,
      );
      expect(invalidUnit.validate(), isNotNull);

      const validUnit = CreateProductUnitDto(
        unitName: 'Dus',
        conversionFactor: 24,
        costPrice: 48000,
        sellingPrice: 55000,
      );
      expect(validUnit.validate(), isNull);
    });

    test('CreateProductDto validates required fields and nested units', () {
      const emptyNameProduct = CreateProductDto(
        name: '',
        baseUnit: 'Pcs',
        baseCostPrice: 1000,
        baseSellingPrice: 2000,
      );
      expect(emptyNameProduct.validate(), 'Nama barang wajib diisi');

      const shortNameProduct = CreateProductDto(
        name: 'ab',
        baseUnit: 'Pcs',
        baseCostPrice: 1000,
        baseSellingPrice: 2000,
      );
      expect(shortNameProduct.validate(), 'Nama barang minimal 3 huruf');

      const invalidProduct = CreateProductDto(
        name: '',
        baseUnit: '',
        baseCostPrice: -10,
        baseSellingPrice: 0,
      );
      expect(invalidProduct.validate(), isNotNull);

      const validProduct = CreateProductDto(
        name: 'Kopi Susu 250ml',
        baseUnit: 'Btl',
        initialStock: 50,
        baseCostPrice: 6000,
        baseSellingPrice: 8000,
        packagingUnits: [
          CreateProductUnitDto(
            unitName: 'Karton',
            conversionFactor: 24,
            costPrice: 144000,
            sellingPrice: 180000,
          ),
        ],
      );
      expect(validProduct.validate(), isNull);
    });
  });

  group('ProductModel Calculations', () {
    test('accurately calculates HPP margin and stock in packaging units', () {
      final now = DateTime.now();
      final product = ProductModel(
        id: 'PRD-001',
        storeId: 'STR-001',
        name: 'Minyak Goreng 1L',
        baseUnit: 'Pcs',
        stockBase: 120, // 120 Pcs
        minStockAlert: 10,
        baseCostPrice: 14000,
        baseSellingPrice: 16000,
        units: [
          ProductUnitModel(
            id: 'UNT-001',
            productId: 'PRD-001',
            unitName: 'Karton',
            conversionFactor: 12, // 1 Karton = 12 Pcs
            costPrice: 168000,
            sellingPrice: 190000,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      // Margin per base unit: 16000 - 14000 = 2000
      expect(product.marginPerBaseUnit, 2000);
      // Margin percentage: (2000 / 14000) * 100 = 14.2857%
      expect(product.marginPercentage, closeTo(14.28, 0.01));
      // Stock in Karton: 120 / 12 = 10 Karton
      expect(product.stockInUnit(12), 10.0);
      // Low stock check
      expect(product.isLowStock, isFalse);
    });
  });
}
