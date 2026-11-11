import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/core/utils/sku_generator.dart';
import 'package:tokona/core/widgets/app_dialog.dart';

void main() {
  group('SkuGenerator', () {
    test('generate produces format SDPGRG-DDMM-RANDOM3NUM1LETTER for multi-word', () {
      final fixedDate = DateTime(2026, 10, 28);
      final sku = SkuGenerator.generate('misedap goreng', date: fixedDate);

      expect(sku, startsWith('SDPGRG-2810-'));
      expect(RegExp(r'^SDPGRG-2810-\d{3}[A-Z]$').hasMatch(sku), isTrue);
      expect(SkuGenerator.isGeneratedSku(sku), isTrue);
    });

    test('generate produces format MIE0YY-DDMM-RANDOM3NUM1LETTER for single word mie', () {
      final fixedDate = DateTime(2026, 10, 28);
      final sku = SkuGenerator.generate('mie', date: fixedDate);

      expect(sku, startsWith('MIE026-2810-'));
      expect(RegExp(r'^MIE026-2810-\d{3}[A-Z]$').hasMatch(sku), isTrue);
      expect(SkuGenerator.isGeneratedSku(sku), isTrue);
    });

    test('generate produces format SDPGRG-DDMM-RANDOM3NUM1LETTER for mie sedaap goreng', () {
      final fixedDate = DateTime(2026, 10, 28);
      final sku = SkuGenerator.generate('mie sedaap goreng', date: fixedDate);

      expect(sku, startsWith('SDPGRG-2810-'));
      expect(SkuGenerator.isGeneratedSku(sku), isTrue);
    });

    test('generate handles single word of 4 and 5 characters with year padding', () {
      final fixedDate = DateTime(2026, 10, 28);
      final skuKopi = SkuGenerator.generate('kopi', date: fixedDate);
      final skuRokok = SkuGenerator.generate('rokok', date: fixedDate);

      expect(skuKopi, startsWith('KOPI26-2810-'));
      expect(skuRokok, startsWith('ROKO26-2810-'));
      expect(SkuGenerator.isGeneratedSku(skuKopi), isTrue);
      expect(SkuGenerator.isGeneratedSku(skuRokok), isTrue);
    });

    test('generate produces PRD0YY prefix when name is empty', () {
      final fixedDate = DateTime(2026, 10, 28);
      final sku = SkuGenerator.generate('', date: fixedDate);

      expect(sku, startsWith('PRD026-2810-'));
      expect(SkuGenerator.isGeneratedSku(sku), isTrue);
    });

    test('isGeneratedSku correctly identifies new and legacy generated vs manual barcode', () {
      expect(SkuGenerator.isGeneratedSku('SDPGRG-2810-482A'), isTrue);
      expect(SkuGenerator.isGeneratedSku('MIE026-2810-719K'), isTrue);
      expect(SkuGenerator.isGeneratedSku('INDGOR-281026-1234'), isTrue);
      expect(SkuGenerator.isGeneratedSku('8992388123456'), isFalse);
      expect(SkuGenerator.isGeneratedSku('BARCODE-CUSTOM'), isFalse);
      expect(SkuGenerator.isGeneratedSku(''), isFalse);
    });
  });

  group('AppDialog', () {
    testWidgets('showConfirmation displays title, message, and returns user choice', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await AppDialog.showConfirmation(
                    context,
                    title: 'Konfirmasi Hapus',
                    message: 'Apakah Anda yakin ingin menghapus produk ini?',
                    confirmText: 'Ya, Hapus',
                    isDestructive: true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus produk ini?'), findsOneWidget);
      expect(find.text('Ya, Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      await tester.tap(find.text('Ya, Hapus'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });
  });
}
