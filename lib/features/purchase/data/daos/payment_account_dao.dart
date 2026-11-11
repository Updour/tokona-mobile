import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';

class PaymentAccountDao {
  const PaymentAccountDao();

  static const List<Map<String, String>> defaultPresets = [
    {'name': 'Kas Tunai', 'type': 'cash', 'holder': 'Kasir Tokona'},
    {'name': 'Bank BCA', 'type': 'bank', 'holder': 'Toko Tokona'},
    {'name': 'SeaBank', 'type': 'bank', 'holder': 'Toko Tokona'},
    {'name': 'ShopeePay', 'type': 'ewallet', 'holder': 'Toko Tokona'},
  ];

  Future<void> insert(
    DatabaseExecutor db, {
    required String id,
    required String storeId,
    required String name,
    String type = 'bank',
    String? accountNumber,
    String? holderName,
    double initialBalance = 0.0,
    double currentBalance = 0.0,
    bool isActive = true,
    required DateTime createdAt,
  }) async {
    await db.insert(
      DatabaseTables.paymentAccounts,
      {
        DatabaseTables.columnId: id,
        DatabaseTables.columnAccountStoreId: storeId,
        DatabaseTables.columnAccountName: name,
        DatabaseTables.columnAccountType: type,
        DatabaseTables.columnAccountNumber: accountNumber,
        DatabaseTables.columnAccountHolderName: holderName,
        DatabaseTables.columnAccountInitialBalance: initialBalance,
        DatabaseTables.columnAccountCurrentBalance: currentBalance,
        DatabaseTables.columnAccountIsActive: isActive ? 1 : 0,
        DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAccount(DatabaseExecutor db, PaymentAccountModel account) async {
    await db.update(
      DatabaseTables.paymentAccounts,
      account.toMap(),
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> delete(DatabaseExecutor db, String id) async {
    await db.delete(
      DatabaseTables.paymentAccounts,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<PaymentAccountModel>> getAll(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.paymentAccounts,
      where: '${DatabaseTables.columnAccountStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnCreatedAt} ASC',
    );

    if (rows.isEmpty) {
      final now = DateTime.now();
      final List<PaymentAccountModel> created = [];
      for (final p in defaultPresets) {
        final id = IdGenerator.generateId(prefix: 'ACC');
        final model = PaymentAccountModel(
          id: id,
          storeId: storeId,
          name: p['name']!,
          type: p['type']!,
          holderName: p['holder'],
          initialBalance: 0.0,
          currentBalance: 0.0,
          isActive: true,
          createdAt: now,
        );
        await db.insert(
          DatabaseTables.paymentAccounts,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        created.add(model);
      }
      return created;
    }

    return rows.map((r) => PaymentAccountModel.fromMap(r)).toList();
  }

  Future<List<String>> getAccountNames(DatabaseExecutor db, String storeId) async {
    final accounts = await getAll(db, storeId);
    return accounts.where((a) => a.isActive).map((a) => a.name).toList();
  }

  Future<void> adjustBalance(
    DatabaseExecutor db, {
    required String storeId,
    required String accountNameOrId,
    required double deltaAmount,
  }) async {
    final trimmed = accountNameOrId.trim();
    if (trimmed.isEmpty) return;

    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseTables.paymentAccounts} WHERE ${DatabaseTables.columnAccountStoreId} = ?',
      [storeId],
    )) ?? 0;
    if (count == 0) {
      await getAll(db, storeId);
    }

    var rows = await db.query(
      DatabaseTables.paymentAccounts,
      where: '${DatabaseTables.columnAccountStoreId} = ? AND (${DatabaseTables.columnId} = ? OR LOWER(${DatabaseTables.columnAccountName}) = ?)',
      whereArgs: [storeId, trimmed, trimmed.toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) {
      final lower = trimmed.toLowerCase();
      String condition;
      List<dynamic> args;

      if (lower == 'cash' || lower == 'tunai' || lower == 'kas') {
        condition = '${DatabaseTables.columnAccountStoreId} = ? AND (${DatabaseTables.columnAccountType} = ? OR LOWER(${DatabaseTables.columnAccountName}) LIKE ?)';
        args = [storeId, 'cash', '%tunai%'];
      } else {
        condition = '${DatabaseTables.columnAccountStoreId} = ? AND LOWER(${DatabaseTables.columnAccountName}) LIKE ?';
        args = [storeId, '%$lower%'];
      }

      rows = await db.query(
        DatabaseTables.paymentAccounts,
        where: condition,
        whereArgs: args,
        limit: 1,
      );
    }

    if (rows.isNotEmpty) {
      final current = (rows.first[DatabaseTables.columnAccountCurrentBalance] as num?)?.toDouble() ?? 0.0;
      final newBalance = current + deltaAmount;
      await db.update(
        DatabaseTables.paymentAccounts,
        {DatabaseTables.columnAccountCurrentBalance: newBalance},
        where: '${DatabaseTables.columnId} = ?',
        whereArgs: [rows.first[DatabaseTables.columnId]],
      );
    } else {
      final id = IdGenerator.generateId(prefix: 'ACC');
      final isCash = trimmed.toLowerCase().contains('tunai') || trimmed.toLowerCase() == 'cash';
      await insert(
        db,
        id: id,
        storeId: storeId,
        name: trimmed,
        type: isCash ? 'cash' : 'bank',
        currentBalance: deltaAmount,
        createdAt: DateTime.now(),
      );
    }
  }
}
