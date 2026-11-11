import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/payment/domain/models/store_capital_model.dart';

class StoreCapitalDao {
  const StoreCapitalDao();

  Future<void> insert(DatabaseExecutor db, StoreCapitalModel capital) async {
    await db.insert(
      DatabaseTables.storeCapitals,
      capital.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StoreCapitalModel>> getByStoreId(
    DatabaseExecutor db,
    String storeId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<String> whereClauses = ['${DatabaseTables.columnCapitalStoreId} = ?'];
    final List<dynamic> whereArgs = [storeId];

    if (type != null && type.isNotEmpty && type != 'ALL') {
      whereClauses.add('${DatabaseTables.columnCapitalType} = ?');
      whereArgs.add(type);
    }

    if (startDate != null) {
      whereClauses.add('${DatabaseTables.columnCapitalDate} >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('${DatabaseTables.columnCapitalDate} <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final rows = await db.query(
      DatabaseTables.storeCapitals,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '${DatabaseTables.columnCapitalDate} DESC',
    );
    return rows.map((r) => StoreCapitalModel.fromMap(r)).toList();
  }

  Future<void> delete(DatabaseExecutor db, String id) async {
    await db.delete(
      DatabaseTables.storeCapitals,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getSummary(DatabaseExecutor db, String storeId) async {
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN ${DatabaseTables.columnCapitalType} = 'MODAL_AWAL' THEN ${DatabaseTables.columnCapitalAmount} ELSE 0 END), 0) as initial_capital,
        COALESCE(SUM(CASE WHEN ${DatabaseTables.columnCapitalType} = 'TAMBAH_MODAL' THEN ${DatabaseTables.columnCapitalAmount} ELSE 0 END), 0) as added_capital,
        COALESCE(SUM(CASE WHEN ${DatabaseTables.columnCapitalType} = 'TARIK_MODAL' THEN ${DatabaseTables.columnCapitalAmount} ELSE 0 END), 0) as withdrawn_capital
      FROM ${DatabaseTables.storeCapitals}
      WHERE ${DatabaseTables.columnCapitalStoreId} = ?
    ''', [storeId]);

    if (rows.isEmpty) {
      return {'initial': 0.0, 'added': 0.0, 'withdrawn': 0.0, 'net': 0.0};
    }
    final r = rows.first;
    final initial = (r['initial_capital'] as num?)?.toDouble() ?? 0.0;
    final added = (r['added_capital'] as num?)?.toDouble() ?? 0.0;
    final withdrawn = (r['withdrawn_capital'] as num?)?.toDouble() ?? 0.0;
    final net = initial + added - withdrawn;

    return {
      'initial': initial,
      'added': added,
      'withdrawn': withdrawn,
      'net': net,
    };
  }
}
