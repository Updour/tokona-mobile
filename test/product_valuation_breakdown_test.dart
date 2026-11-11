import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_bottom_sheet.dart';

void main() {
  testWidgets('ProductDetailBottomSheet displays clear valuation breakdown and formulas', (WidgetTester tester) async {
    final now = DateTime.now();
    final dummyProduct = ProductModel(
      id: 'PRD-MIE-1',
      storeId: 'STR-TEST-1',
      name: 'Mie Goreng Spesial',
      sku: 'MIE001',
      baseUnit: 'Pcs',
      stockBase: 5,
      minStockAlert: 2,
      baseCostPrice: 101000,
      baseSellingPrice: 106000,
      units: [
        ProductUnitModel(
          id: 'UNT-DUS-1',
          productId: 'PRD-MIE-1',
          unitName: 'Dus',
          conversionFactor: 5,
          costPrice: 505000,
          sellingPrice: 530000,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ProductDetailBottomSheet.show(
                context,
                product: dummyProduct,
                onRestock: () {},
              ),
              child: const Text('Open Detail'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Detail'));
    await tester.pumpAndSettle();

    // Verify per-item basic unit pricing
    expect(find.text('Harga Jual Satuan'), findsOneWidget);
    expect(find.text('Rp 106.000'), findsOneWidget);
    expect(find.text('Pendapatan per Pcs'), findsOneWidget);

    expect(find.text('HPP Modal Satuan'), findsOneWidget);
    expect(find.text('Rp 101.000'), findsOneWidget);
    expect(find.text('Beban modal per Pcs'), findsOneWidget);

    expect(find.text('Laba Bersih per Pcs'), findsOneWidget);
    expect(find.text('+Rp 5.000'), findsOneWidget);
    expect(find.text('Rp 106.000 - Rp 101.000'), findsOneWidget);

    // Verify stock physical valuation and formula breakdown
    expect(find.text('Total Valuasi Stok Fisik'), findsOneWidget);
    expect(find.text('5 Pcs'), findsNWidgets(2));

    expect(find.text('Total Modal (HPP Stok)'), findsOneWidget);
    expect(find.text('5 Pcs × Rp 101.000 (modal)'), findsOneWidget);
    expect(find.text('Rp 505.000'), findsNWidgets(2));

    expect(find.text('Total Potensi Omzet'), findsOneWidget);
    expect(find.text('5 Pcs × Rp 106.000 (jual)'), findsOneWidget);
    expect(find.text('Rp 530.000'), findsNWidgets(3));

    expect(find.text('Total Potensi Keuntungan'), findsOneWidget);
    expect(find.text('5 Pcs × Rp 5.000 (+5.0%)'), findsOneWidget);
    expect(find.text('+Rp 25.000'), findsNWidgets(2));

    // Verify packaging tier formula subtitle
    expect(find.text('1 Dus × Rp 530.000'), findsOneWidget);
    expect(find.text('1 Dus × Rp 25.000'), findsOneWidget);
  });
}
