import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/core/utils/product_name_formatter.dart';
import 'package:tokona/features/product/presentation/widgets/add_product_base_form.dart';

void main() {
  group('ProductNameFormatter Unit Tests', () {
    test('converts lowercase text to Title Case', () {
      expect(
        ProductNameFormatter.format('indomie goreng spesial'),
        'Indomie Goreng Spesial',
      );
      expect(
        ProductNameFormatter.format('teh botol sosro 250ml'),
        'Teh Botol Sosro 250ml',
      );
    });

    test('cleans double and multiple spaces between words', () {
      expect(
        ProductNameFormatter.format('mie    sedap   goreng'),
        'Mie Sedap Goreng',
      );
      expect(
        ProductNameFormatter.clean('   kopi   kapal   api   '),
        'Kopi Kapal Api',
      );
    });

    test('preserves single trailing space when typing subsequent words', () {
      expect(
        ProductNameFormatter.format('mie ', preserveTrailingSpace: true),
        'Mie ',
      );
      expect(
        ProductNameFormatter.format('indomie  ', preserveTrailingSpace: true),
        'Indomie ',
      );
    });

    test('handles hyphenated and slashed product names correctly', () {
      expect(
        ProductNameFormatter.format('coca-cola dingin'),
        'Coca-Cola Dingin',
      );
      expect(
        ProductNameFormatter.format('paket hemat/bundling'),
        'Paket Hemat/Bundling',
      );
    });

    test('preserves short acronyms like UHT, DUS, PCS, and KG', () {
      expect(
        ProductNameFormatter.format('susu UHT cokelat 1L'),
        'Susu UHT Cokelat 1L',
      );
    });

    test('handles empty or whitespace-only strings gracefully', () {
      expect(ProductNameFormatter.format(''), '');
      expect(ProductNameFormatter.format('   '), '');
      expect(ProductNameFormatter.clean(''), '');
      expect(ProductNameFormatter.clean('   '), '');
    });
  });

  group('ProductNameInputFormatter Unit Tests', () {
    final formatter = ProductNameInputFormatter();

    test('disallows leading space on empty input', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: ' ',
        selection: TextSelection.collapsed(offset: 1),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('formats live keystrokes to Title Case and positions cursor correctly', () {
      const oldValue = TextEditingValue(
        text: 'Mie',
        selection: TextSelection.collapsed(offset: 3),
      );
      const newValue = TextEditingValue(
        text: 'Mie s',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'Mie S');
      expect(result.selection.baseOffset, 5);
    });

    test('collapses duplicate space on typing and adjusts cursor', () {
      const oldValue = TextEditingValue(
        text: 'Mie ',
        selection: TextSelection.collapsed(offset: 4),
      );
      const newValue = TextEditingValue(
        text: 'Mie  ',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'Mie ');
      expect(result.selection.baseOffset, 4);
    });

    test('formats pasted text with multiple spaces and mixed case', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '  biskuit   roma   kelapa  ',
        selection: TextSelection.collapsed(offset: 27),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'Biskuit Roma Kelapa ');
    });
  });

  group('AddProductBaseForm Name Formatting Widget Test', () {
    testWidgets('formats entered product name to Title Case and removes double spaces', (tester) async {
      final nameCtrl = TextEditingController();
      final skuCtrl = TextEditingController();
      final unitCtrl = TextEditingController(text: 'Pcs');
      final stockCtrl = TextEditingController(text: '10');
      final costCtrl = TextEditingController(text: '1000');
      final sellCtrl = TextEditingController(text: '2000');
      final minStockCtrl = TextEditingController(text: '2');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddProductBaseForm(
                nameController: nameCtrl,
                skuController: skuCtrl,
                baseUnitController: unitCtrl,
                stockController: stockCtrl,
                costPriceController: costCtrl,
                sellingPriceController: sellCtrl,
                minStockAlertController: minStockCtrl,
                selectedCategory: 'Makanan',
                onCategoryChanged: (_) {},
                selectedProductType: 'Fisik',
                onProductTypeChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final nameField = find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.controller == nameCtrl,
      );
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'indomie   goreng   pedas');
      await tester.pumpAndSettle();

      expect(nameCtrl.text, 'Indomie Goreng Pedas');
    });
  });
}
