import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';
import 'package:tokona/features/product/presentation/widgets/edit_product_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_info_dialog.dart';
import 'package:tokona/features/product/presentation/widgets/product_card_item.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_bottom_sheet.dart';

void main() {
  testWidgets('ProductDetailBottomSheet displays product details and packaging tiers', (WidgetTester tester) async {
    final now = DateTime.now();
    final dummyProduct = ProductModel(
      id: 'PRD-TEST-1',
      storeId: 'STR-TEST-1',
      name: 'Indomie Goreng Spesial',
      sku: '8998866110',
      baseUnit: 'Pcs',
      stockBase: 120,
      minStockAlert: 10,
      baseCostPrice: 2800,
      baseSellingPrice: 3500,
      units: [
        ProductUnitModel(
          id: 'UNT-1',
          productId: 'PRD-TEST-1',
          unitName: 'Dus',
          conversionFactor: 40,
          costPrice: 112000,
          sellingPrice: 135000,
          barcode: '8998866110DUS',
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

    expect(find.text('Indomie Goreng Spesial'), findsOneWidget);
    expect(find.text('8998866110'), findsOneWidget);
    expect(find.text('Rincian Satuan Dasar'), findsOneWidget);
    expect(find.text('Total Valuasi Stok Fisik'), findsOneWidget);
    expect(find.text('Total Modal (HPP Stok)'), findsOneWidget);
    expect(find.text('Satuan Kemasan Bertingkat'), findsOneWidget);
    expect(find.text('Dus'), findsOneWidget);
    expect(find.text('Estimasi Stok Kemasan'), findsOneWidget);
    expect(find.text('3 Dus'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);
  });

  testWidgets('PackagingInfoDialog opens and displays guide', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PackagingInfoDialog.show(context),
              child: const Text('Open Info'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Info'));
    await tester.pumpAndSettle();

    expect(find.text('Panduan Multi-Tier Packaging'), findsOneWidget);
    expect(find.text('MENGERTI'), findsOneWidget);
  });

  testWidgets('ProductCardItem onTap triggers callback', (WidgetTester tester) async {
    bool tapped = false;
    final now = DateTime.now();
    final dummyProduct = ProductModel(
      id: 'PRD-1',
      storeId: 'STR-1',
      name: 'Kopi Kapal Api',
      baseUnit: 'Bks',
      stockBase: 50,
      minStockAlert: 5,
      baseCostPrice: 1500,
      baseSellingPrice: 2000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProductCardItem(
            product: dummyProduct,
            onDelete: () {},
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kopi Kapal Api'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('EditProductBottomSheet renders pre-filled data and strict stock banner', (WidgetTester tester) async {
    final now = DateTime.now();
    final dummyProduct = ProductModel(
      id: 'PRD-2',
      storeId: 'STR-1',
      name: 'Teh Botol Sosro',
      sku: '8991234',
      baseUnit: 'Btl',
      stockBase: 24,
      minStockAlert: 5,
      baseCostPrice: 3000,
      baseSellingPrice: 4000,
      createdAt: now,
      updatedAt: now,
    );

    UpdateProductDto? submittedDto;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditProductBottomSheet.show(
                context,
                product: dummyProduct,
                onSubmit: (dto) async {
                  submittedDto = dto;
                  return true;
                },
                onRestock: () {},
              ),
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Master Produk'), findsOneWidget);
    expect(find.text('Stok Saat Ini: 24 Btl'), findsOneWidget);
    expect(find.text('BATAL'), findsOneWidget);
    expect(find.text('SIMPAN PERUBAHAN'), findsOneWidget);

    await tester.ensureVisible(find.text('SIMPAN PERUBAHAN'));
    await tester.tap(find.text('SIMPAN PERUBAHAN'));
    await tester.pumpAndSettle();

    expect(submittedDto, isNotNull);
    expect(submittedDto!.name, 'Teh Botol Sosro');
    expect(submittedDto!.baseSellingPrice, 4000);
    expect(submittedDto!.stockBase, 24);
  });

  testWidgets('EditProductBottomSheet with custom product type pre-fills custom type field', (WidgetTester tester) async {
    final now = DateTime.now();
    final customProduct = ProductModel(
      id: 'PRD-GOIB',
      storeId: 'STR-1',
      name: 'Keris Sakti',
      productType: 'tipe barang goib',
      baseUnit: 'Pcs',
      stockBase: 1,
      minStockAlert: 1,
      baseCostPrice: 50000,
      baseSellingPrice: 100000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditProductBottomSheet.show(
                context,
                product: customProduct,
                onSubmit: (_) async => true,
                onRestock: () {},
              ),
              child: const Text('Open Custom Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Custom Edit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nama Tipe', skipOffstage: false), findsOneWidget);
    expect(find.text('tipe barang goib', skipOffstage: false), findsOneWidget);
  });
}
