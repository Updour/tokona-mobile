import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/auth/domain/models/auth_state.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DashboardScreen renders all tabs and navigates without error', (WidgetTester tester) async {
    final now = DateTime.now();
    final dummyStore = StoreModel(
      id: 'STR-TEST-1',
      name: 'Toko Berkah Mandiri',
      address: 'Jl. Pemuda No. 12',
      createdAt: now,
      updatedAt: now,
    );
    final dummyUser = UserModel(
      id: 'USR-TEST-1',
      storeId: 'STR-TEST-1',
      username: 'owner',
      fullName: 'Ahmad Owner',
      passwordHash: 'dummyhash',
      salt: 'dummysalt',
      role: UserRole.owner,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _MockAuthController(dummyStore, dummyUser)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toko Berkah Mandiri'), findsOneWidget);

    // Tap on Produk tab in bottom navigation bar
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();

    expect(find.text('Master Produk'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);

    // Tap on Kasir tab
    await tester.tap(find.text('Kasir'));
    await tester.pumpAndSettle();

    expect(find.text('Cari barang kasir...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
  });
}

class _MockAuthController extends StateNotifier<AuthState> implements AuthController {
  _MockAuthController(StoreModel store, UserModel user)
      : super(AuthState(
          isInitialized: true,
          isAuthenticated: true,
          hasRegisteredStore: true,
          currentStore: store,
          currentUser: user,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
