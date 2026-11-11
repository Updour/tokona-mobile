import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_image_picker_widget.dart';
import 'package:tokona/features/product/presentation/widgets/product_image_viewer_dialog.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';

void main() {
  late File sampleTempFile;

  setUpAll(() async {
    sampleTempFile = File('${Directory.systemTemp.path}/tokona_test_image.png');
    // Minimal 1x1 PNG bytes
    await sampleTempFile.writeAsBytes([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);
  });

  tearDownAll(() async {
    if (await sampleTempFile.exists()) {
      await sampleTempFile.delete();
    }
  });

  group('ProductModel Image Support', () {
    test('serializes and deserializes imagePath correctly', () {
      final now = DateTime.now();
      final product = ProductModel(
        id: 'PRD-IMG-1',
        storeId: 'STR-1',
        name: 'Susu UHT',
        baseUnit: 'Kotak',
        stockBase: 10,
        minStockAlert: 2,
        baseCostPrice: 4000,
        baseSellingPrice: 5000,
        imagePath: '/data/user/0/com.tokona/files/product_images/susu.jpg',
        createdAt: now,
        updatedAt: now,
      );

      final map = product.toMap();
      expect(map['image_path'], '/data/user/0/com.tokona/files/product_images/susu.jpg');

      final fromMapProduct = ProductModel.fromMap(map);
      expect(fromMapProduct.imagePath, '/data/user/0/com.tokona/files/product_images/susu.jpg');

      final copied = product.copyWith(imagePath: '/new/path.png');
      expect(copied.imagePath, '/new/path.png');

      final updateDto = product.toUpdateDto();
      expect(updateDto.imagePath, '/data/user/0/com.tokona/files/product_images/susu.jpg');
      expect(updateDto.clearImage, isFalse);
    });

    test('CreateProductDto and UpdateProductDto retain imagePath and clearImage', () {
      const createDto = CreateProductDto(
        name: 'Kopi Susu',
        baseUnit: 'Gelas',
        initialStock: 20,
        minStockAlert: 3,
        baseCostPrice: 3000,
        baseSellingPrice: 5000,
        imagePath: '/images/kopi.jpg',
      );
      expect(createDto.imagePath, '/images/kopi.jpg');

      const updateDto = UpdateProductDto(
        name: 'Kopi Susu Panas',
        baseUnit: 'Gelas',
        stockBase: 20,
        minStockAlert: 3,
        baseCostPrice: 3000,
        baseSellingPrice: 6000,
        imagePath: null,
        clearImage: true,
      );
      expect(updateDto.imagePath, isNull);
      expect(updateDto.clearImage, isTrue);
    });
  });

  group('ProductThumbnailAvatar Widget', () {
    testWidgets('renders fallback icon when imagePath is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ProductThumbnailAvatar(
              imagePath: null,
              productName: 'Kopi Kapal Api',
              size: 46,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    });

    testWidgets('renders fallback icon gracefully for invalid path without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ProductThumbnailAvatar(
              imagePath: '/non_existent_folder/missing.jpg',
              productName: 'Barang Tes',
              size: 54,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    });

    testWidgets('renders image and opens viewer dialog on tap when valid image provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProductThumbnailAvatar(
              imagePath: sampleTempFile.path,
              productName: 'Susu Kotak',
              size: 54,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      await tester.tap(find.byType(ProductThumbnailAvatar));
      await tester.pumpAndSettle();

      expect(find.text('Susu Kotak'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });

  group('ProductImageViewerDialog Widget', () {
    testWidgets('renders dialog header and responds to close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ProductImageViewerDialog.show(
                  context,
                  imagePath: sampleTempFile.path,
                  productName: 'Biskuit Roma Kelapa',
                ),
                child: const Text('Buka Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Biskuit Roma Kelapa'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Biskuit Roma Kelapa'), findsNothing);
    });
  });

  group('ProductImagePickerWidget Widget', () {
    testWidgets('renders empty state when imagePath is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProductImagePickerWidget(
              imagePath: null,
              productName: 'Sabun Mandi',
              onImageSelected: (_) {},
              onImageRemoved: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tambah Foto Produk (Opsional)'), findsOneWidget);
      expect(find.text('Ambil foto dari kamera atau galeri'), findsOneWidget);
    });

    testWidgets('renders edit & delete actions when imagePath is present and triggers remove', (tester) async {
      bool removed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProductImagePickerWidget(
              imagePath: sampleTempFile.path,
              productName: 'Sabun Mandi',
              onImageSelected: (_) {},
              onImageRemoved: () {
                removed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Foto Produk Terpasang'), findsOneWidget);
      expect(find.byTooltip('Ganti Foto'), findsOneWidget);
      expect(find.byTooltip('Hapus Foto'), findsOneWidget);

      await tester.tap(find.byTooltip('Hapus Foto'));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });
  });
}
