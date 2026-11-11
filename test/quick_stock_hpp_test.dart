import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_card_item.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/quick_stock_hpp_sheet.dart';

void main() {
  final now = DateTime.now();
  final dummyProduct = ProductModel(
    id: 'PRD-QUICK-1',
    storeId: 'STR-1',
    name: 'Teh Botol 250ml',
    sku: 'TEH026-2810-123A',
    baseUnit: 'Btl',
    stockBase: 50,
    minStockAlert: 10,
    baseCostPrice: 3000,
    baseSellingPrice: 4000,
    units: [
      ProductUnitModel(
        id: 'UNT-1',
        productId: 'PRD-QUICK-1',
        unitName: 'Karton',
        conversionFactor: 24,
        costPrice: 72000,
        sellingPrice: 90000,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );

  testWidgets('ProductDetailBottomSheet renders product info with direct SKU and truncated name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ProductDetailBottomSheet.show(
                context,
                product: dummyProduct,
              ),
              child: const Text('Open Detail'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Teh Botol 250ml'), findsOneWidget);
    expect(find.text('TEH026-2810-123A'), findsOneWidget);
    expect(find.text('Rincian Satuan Dasar'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('Rincian Satuan Dasar'), findsNothing);
  });

  testWidgets('QuickStockHppSheet Tab 1 updates HPP and selling price', (WidgetTester tester) async {
    double? savedCost;
    double? savedSell;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => QuickStockHppSheet.show(
                context,
                product: dummyProduct,
                initialTab: 1,
                onQuickEditPrice: (cost, sell) async {
                  savedCost = cost;
                  savedSell = sell;
                  return true;
                },
              ),
              child: const Text('Open Price Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Price Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('HPP Modal Satuan (Rp)'), findsOneWidget);
    expect(find.text('Harga Jual Satuan (Rp)'), findsOneWidget);
    expect(find.text('Simpan Ubah Harga'), findsOneWidget);

    await tester.tap(find.text('Simpan Ubah Harga'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    expect(savedCost, 3000.0);
    expect(savedSell, 4000.0);
  });

  testWidgets('QuickStockHppSheet Tab 0 adds stock without redundant choice chips', (WidgetTester tester) async {
    double? adjustedStock;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => QuickStockHppSheet.show(
                context,
                product: dummyProduct,
                initialTab: 0,
                onAdjustStock: (newStock) async {
                  adjustedStock = newStock;
                  return true;
                },
              ),
              child: const Text('Open Stock Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Stock Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Jumlah Tambahan Stok (Btl)'), findsOneWidget);
    expect(find.text('+ Tambah Stok'), findsNothing);
    expect(find.text('= Atur Total Stok'), findsNothing);
    expect(find.text('+5'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('Simpan Tambahan Stok'), findsOneWidget);

    await tester.tap(find.text('+10'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan Tambahan Stok'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    // Initial dummy stock 50 + 10 (default controller) + 10 (+10 chip) = 70
    expect(adjustedStock, 70.0);
  });

  testWidgets('ProductCardItem renders 3-dots menu and triggers actions from popup', (WidgetTester tester) async {
    bool quickAdjustTriggered = false;
    bool editTriggered = false;
    bool deleteTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProductCardItem(
            product: dummyProduct,
            onQuickAdjust: () => quickAdjustTriggered = true,
            onEdit: () => editTriggered = true,
            onDelete: () => deleteTriggered = true,
          ),
        ),
      ),
    );

    // Verify 3-dots menu button is visible
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

    // Test quick adjust action
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Atur Stok & Harga'), findsOneWidget);
    await tester.tap(find.text('Atur Stok & Harga'));
    await tester.pumpAndSettle();
    expect(quickAdjustTriggered, isTrue);

    // Test edit action
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Edit Lengkap'), findsOneWidget);
    await tester.tap(find.text('Edit Lengkap'));
    await tester.pumpAndSettle();
    expect(editTriggered, isTrue);

    // Test delete action
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Produk'), findsOneWidget);
    await tester.tap(find.text('Hapus Produk'));
    await tester.pumpAndSettle();
    expect(deleteTriggered, isTrue);
  });

  testWidgets('QuickStockHppSheet renders Ubah Harga tab without overflow on 320px screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => QuickStockHppSheet.show(
                context,
                product: dummyProduct,
                initialTab: 1,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Harga'), findsOneWidget);
    expect(find.text('Tambah Stok'), findsOneWidget);
    expect(find.text('Simpan Ubah Harga'), findsOneWidget);
  });
}
