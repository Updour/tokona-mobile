import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';

final paymentAccountDaoProvider = Provider<PaymentAccountDao>((ref) {
  return const PaymentAccountDao();
});

final paymentAccountListProvider =
    StateNotifierProvider<PaymentAccountController, List<PaymentAccountModel>>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  final dao = ref.watch(paymentAccountDaoProvider);
  return PaymentAccountController(appDb, dao);
});

final paymentAccountNamesProvider = Provider<List<String>>((ref) {
  final list = ref.watch(paymentAccountListProvider);
  return list.where((a) => a.isActive).map((a) => a.name).toList();
});

final totalStoreBalanceProvider = Provider<double>((ref) {
  final list = ref.watch(paymentAccountListProvider);
  return list.where((a) => a.isActive).fold(0.0, (acc, item) => acc + item.currentBalance);
});

class PaymentAccountController extends StateNotifier<List<PaymentAccountModel>> {
  final dynamic _appDb;
  final PaymentAccountDao _dao;

  PaymentAccountController(this._appDb, this._dao) : super(const []);

  Future<void> loadAccounts(String storeId) async {
    try {
      final db = await _appDb.database;
      final list = await _dao.getAll(db, storeId);
      state = list;
    } catch (_) {}
  }

  Future<PaymentAccountModel?> addAccount(
    String storeId, {
    required String name,
    String type = 'bank',
    String? accountNumber,
    String? holderName,
    double initialBalance = 0.0,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final db = await _appDb.database;
    final id = IdGenerator.generateId(prefix: 'ACC');
    final now = DateTime.now();
    final model = PaymentAccountModel(
      id: id,
      storeId: storeId,
      name: trimmed,
      type: type,
      accountNumber: accountNumber?.trim().isEmpty == true ? null : accountNumber?.trim(),
      holderName: holderName?.trim().isEmpty == true ? null : holderName?.trim(),
      initialBalance: initialBalance,
      currentBalance: initialBalance,
      isActive: true,
      createdAt: now,
    );

    await _dao.insert(
      db,
      id: id,
      storeId: storeId,
      name: trimmed,
      type: type,
      accountNumber: model.accountNumber,
      holderName: model.holderName,
      initialBalance: initialBalance,
      currentBalance: initialBalance,
      isActive: true,
      createdAt: now,
    );

    await loadAccounts(storeId);
    return model;
  }

  Future<void> updateAccount(PaymentAccountModel account) async {
    final db = await _appDb.database;
    await _dao.updateAccount(db, account);
    await loadAccounts(account.storeId);
  }

  Future<void> adjustBalance(String storeId, String accountNameOrId, double deltaAmount) async {
    final db = await _appDb.database;
    await _dao.adjustBalance(db, storeId: storeId, accountNameOrId: accountNameOrId, deltaAmount: deltaAmount);
    await loadAccounts(storeId);
  }

  Future<void> deleteAccount(String storeId, String id) async {
    final db = await _appDb.database;
    await _dao.delete(db, id);
    await loadAccounts(storeId);
  }
}
