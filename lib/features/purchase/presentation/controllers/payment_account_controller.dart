import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart' as p;
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';

export 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart'
    show paymentAccountDaoProvider;

final paymentAccountListProvider =
    StateNotifierProvider<PaymentAccountLegacyController, List<String>>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  final dao = ref.watch(p.paymentAccountDaoProvider);
  return PaymentAccountLegacyController(appDb, dao, ref);
});

class PaymentAccountLegacyController extends StateNotifier<List<String>> {
  final dynamic _appDb;
  final PaymentAccountDao _dao;
  final Ref _ref;

  PaymentAccountLegacyController(this._appDb, this._dao, this._ref) : super(const []);

  Future<void> loadAccounts(String storeId) async {
    final db = await _appDb.database;
    final list = await _dao.getAccountNames(db, storeId);
    state = list;
    _ref.read(p.paymentAccountListProvider.notifier).loadAccounts(storeId);
  }

  Future<String?> addAccount(
    String storeId,
    String name, {
    String type = 'bank',
    String? accountNumber,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final db = await _appDb.database;
    final id = IdGenerator.generateId(prefix: 'ACC');
    await _dao.insert(
      db,
      id: id,
      storeId: storeId,
      name: trimmed,
      type: type,
      accountNumber: accountNumber,
      createdAt: DateTime.now(),
    );
    await loadAccounts(storeId);
    return trimmed;
  }
}
