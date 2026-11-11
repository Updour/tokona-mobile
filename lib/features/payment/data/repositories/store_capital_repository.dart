import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/data/daos/store_capital_dao.dart';
import 'package:tokona/features/payment/domain/models/store_capital_model.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';

final storeCapitalRepositoryProvider = Provider<StoreCapitalRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return StoreCapitalRepository(
    appDatabase: appDb,
    capitalDao: const StoreCapitalDao(),
    paymentAccountDao: const PaymentAccountDao(),
  );
});

class StoreCapitalRepository {
  final AppDatabase appDatabase;
  final StoreCapitalDao capitalDao;
  final PaymentAccountDao paymentAccountDao;

  const StoreCapitalRepository({
    required this.appDatabase,
    required this.capitalDao,
    required this.paymentAccountDao,
  });

  Future<void> addCapital(StoreCapitalModel capital) async {
    final db = await appDatabase.database;
    await db.transaction((txn) async {
      await capitalDao.insert(txn, capital);

      if (capital.accountId != null && capital.accountId!.isNotEmpty) {
        final double delta = capital.isWithdrawal ? -capital.amount : capital.amount;
        await paymentAccountDao.adjustBalance(
          txn,
          storeId: capital.storeId,
          accountNameOrId: capital.accountId!,
          deltaAmount: delta,
        );
      }
    });
  }

  Future<List<StoreCapitalModel>> getCapitals(
    String storeId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await appDatabase.database;
    return await capitalDao.getByStoreId(
      db,
      storeId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> deleteCapital(StoreCapitalModel capital) async {
    final db = await appDatabase.database;
    await db.transaction((txn) async {
      await capitalDao.delete(txn, capital.id);

      if (capital.accountId != null && capital.accountId!.isNotEmpty) {
        final double reverseDelta = capital.isWithdrawal ? capital.amount : -capital.amount;
        await paymentAccountDao.adjustBalance(
          txn,
          storeId: capital.storeId,
          accountNameOrId: capital.accountId!,
          deltaAmount: reverseDelta,
        );
      }
    });
  }

  Future<Map<String, double>> getSummary(String storeId) async {
    final db = await appDatabase.database;
    return await capitalDao.getSummary(db, storeId);
  }
}
