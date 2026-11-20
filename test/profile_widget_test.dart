import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/dashboard/presentation/widgets/akun_tab_view.dart';

void main() {
  testWidgets('AkunTabView renders modern profile hero, store card, and menu items', (tester) async {
    final now = DateTime.now();
    final dummyStore = StoreModel(
      id: 'STR-TEST-1',
      name: 'Toko Berkah Mandiri',
      address: 'Jl. Merdeka No. 45',
      phone: '081234567890',
      createdAt: now,
      updatedAt: now,
    );
    final dummyUser = UserModel(
      id: 'USR-TEST-1',
      storeId: 'STR-TEST-1',
      username: 'budi_owner',
      passwordHash: 'dummy_hash',
      salt: 'dummy_salt',
      fullName: 'Budi Santoso',
      role: UserRole.owner,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AkunTabView(
              store: dummyStore,
              user: dummyUser,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.textContaining('@budi_owner'), findsOneWidget);
    expect(find.textContaining('Toko Berkah Mandiri'), findsOneWidget);
    expect(find.text('Data Pelanggan', skipOffstage: false), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Keluar dari Akun'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Keluar dari Akun'), findsOneWidget);
  });
}
