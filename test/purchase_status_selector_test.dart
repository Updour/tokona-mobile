import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_status_selector.dart';

void main() {
  testWidgets('PurchaseStatusSelector renders without overflow on narrow 320px screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String selectedStatus = 'pre_order';
    int selectedDays = 3;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: PurchaseStatusSelector(
                  status: selectedStatus,
                  poDays: selectedDays,
                  onStatusChanged: (val) => setState(() => selectedStatus = val),
                  onPoDaysChanged: (val) => setState(() => selectedDays = val),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Status Pengadaan Barang'), findsOneWidget);
    expect(find.text('Diterima'), findsOneWidget);
    expect(find.text('PO (1-7 Hari)'), findsOneWidget);
    expect(find.text('Dikirim'), findsOneWidget);
    expect(find.text('Pilih Durasi Pre-Order (PO):'), findsOneWidget);
    expect(find.textContaining('Estimasi:'), findsOneWidget);

    // Switch to 5 days
    await tester.ensureVisible(find.text('5 Hari'));
    await tester.tap(find.text('5 Hari'));
    await tester.pumpAndSettle();
    expect(selectedDays, 5);

    // Switch to 'received'
    await tester.tap(find.text('Diterima'));
    await tester.pumpAndSettle();
    expect(selectedStatus, 'received');
    expect(find.text('Pilih Durasi Pre-Order (PO):'), findsNothing);
  });
}
