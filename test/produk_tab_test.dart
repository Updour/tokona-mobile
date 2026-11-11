import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/dashboard/presentation/widgets/produk_tab_view.dart';

void main() {
  testWidgets('ProdukTabView renders cleanly without layout exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ProviderScope(
            child: ProdukTabView(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Master Produk'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
  });
}
