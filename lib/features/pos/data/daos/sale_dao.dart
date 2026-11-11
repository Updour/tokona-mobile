import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class SaleDao {
  const SaleDao();

  Future<void> insert(DatabaseExecutor db, SaleModel sale) async {
    await db.insert(
      DatabaseTables.sales,
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SaleModel?> getById(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      DatabaseTables.sales,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SaleModel.fromMap(rows.first);
  }

  Future<List<SaleModel>> getByStoreId(
    DatabaseExecutor db,
    String storeId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await db.query(
      DatabaseTables.sales,
      where: '${DatabaseTables.columnSaleStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => SaleModel.fromMap(r)).toList();
  }

  Future<List<SaleModel>> getByStoreIdWithFilters(
    DatabaseExecutor db,
    String storeId, {
    String? searchQuery,
    String? paymentMethod,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final List<String> whereClauses = ['${DatabaseTables.columnSaleStoreId} = ?'];
    final List<dynamic> whereArgs = [storeId];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add(
        '(${DatabaseTables.columnSaleInvoiceNumber} LIKE ? OR ${DatabaseTables.columnSaleCustomerName} LIKE ?)',
      );
      final pattern = '%${searchQuery.trim()}%';
      whereArgs.add(pattern);
      whereArgs.add(pattern);
    }

    if (paymentMethod != null && paymentMethod.trim().isNotEmpty && paymentMethod != 'ALL') {
      whereClauses.add('${DatabaseTables.columnSalePaymentMethod} = ?');
      whereArgs.add(paymentMethod.trim());
    }

    if (status != null && status.trim().isNotEmpty && status != 'ALL') {
      whereClauses.add('${DatabaseTables.columnSaleStatus} = ?');
      whereArgs.add(status.trim());
    }

    if (startDate != null) {
      whereClauses.add('${DatabaseTables.columnCreatedAt} >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('${DatabaseTables.columnCreatedAt} <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final rows = await db.query(
      DatabaseTables.sales,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => SaleModel.fromMap(r)).toList();
  }

  Future<void> voidSale(DatabaseExecutor db, String saleId) async {
    await db.update(
      DatabaseTables.sales,
      {
        DatabaseTables.columnSaleStatus: 'VOIDED',
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [saleId],
    );
  }

  Future<Map<String, double>> getSalesSummary(
    DatabaseExecutor db,
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<String> where = [
      '${DatabaseTables.columnSaleStoreId} = ?',
      "${DatabaseTables.columnSaleStatus} != 'VOIDED'",
    ];
    final List<dynamic> args = [storeId];

    if (startDate != null) {
      where.add('${DatabaseTables.columnCreatedAt} >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where.add('${DatabaseTables.columnCreatedAt} <= ?');
      args.add(endDate.toIso8601String());
    }

    final res = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(${DatabaseTables.columnSaleFinalAmount}), 0) as total_revenue
      FROM ${DatabaseTables.sales}
      WHERE ${where.join(' AND ')}
    ''', args);

    final r = res.first;
    return {
      'count': (r['count'] as num?)?.toDouble() ?? 0.0,
      'total_revenue': (r['total_revenue'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<double> getTodayTotalSales(DatabaseExecutor db, String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(${DatabaseTables.columnSaleFinalAmount}) as total
      FROM ${DatabaseTables.sales}
      WHERE ${DatabaseTables.columnSaleStoreId} = ?
        AND ${DatabaseTables.columnCreatedAt} >= ?
        AND ${DatabaseTables.columnCreatedAt} <= ?
        AND ${DatabaseTables.columnSaleStatus} != 'VOIDED'
    ''', [storeId, startOfDay, endOfDay]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTodayTransactionCount(DatabaseExecutor db, String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DatabaseTables.sales}
      WHERE ${DatabaseTables.columnSaleStoreId} = ?
        AND ${DatabaseTables.columnCreatedAt} >= ?
        AND ${DatabaseTables.columnCreatedAt} <= ?
        AND ${DatabaseTables.columnSaleStatus} != 'VOIDED'
    ''', [storeId, startOfDay, endOfDay]);

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
