import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tokona smoke test renders registration when no store in database', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TokonaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tokona POS'), findsOneWidget);
    expect(find.text('BUKA TOKO BARU'), findsOneWidget);
    expect(find.text('Nama Toko'), findsOneWidget);
  });
}
