import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';
import 'package:tokona/features/report/domain/models/report_summary_model.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';

class ReportDao {
  const ReportDao();

  Future<ReportSummaryModel> getSummary(
    DatabaseExecutor db, {
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();

    final salesResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(${DatabaseTables.columnId}) as tx_count,
        COALESCE(SUM(${DatabaseTables.columnSaleFinalAmount}), 0.0) as total_revenue
      FROM ${DatabaseTables.sales}
      WHERE ${DatabaseTables.columnSaleStoreId} = ?
        AND UPPER(${DatabaseTables.columnSaleStatus}) != 'VOIDED'
        AND ${DatabaseTables.columnCreatedAt} >= ?
        AND ${DatabaseTables.columnCreatedAt} <= ?
      ''',
      [storeId, startIso, endIso],
    );

    final txCount = (salesResult.first['tx_count'] as num?)?.toInt() ?? 0;
    final totalRevenue = (salesResult.first['total_revenue'] as num?)?.toDouble() ?? 0.0;

    final cogsResult = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(si.${DatabaseTables.columnSaleItemQuantity} * si.${DatabaseTables.columnSaleItemCostPrice}), 0.0) as total_cogs
      FROM ${DatabaseTables.saleItems} si
      INNER JOIN ${DatabaseTables.sales} s ON si.${DatabaseTables.columnSaleItemSaleId} = s.${DatabaseTables.columnId}
      WHERE s.${DatabaseTables.columnSaleStoreId} = ?
        AND UPPER(s.${DatabaseTables.columnSaleStatus}) != 'VOIDED'
        AND s.${DatabaseTables.columnCreatedAt} >= ?
        AND s.${DatabaseTables.columnCreatedAt} <= ?
      ''',
      [storeId, startIso, endIso],
    );

    final totalCogs = (cogsResult.first['total_cogs'] as num?)?.toDouble() ?? 0.0;

    final purchaseResult = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(${DatabaseTables.columnPurchaseTotalAmount} + ${DatabaseTables.columnPurchaseServiceFee} + ${DatabaseTables.columnPurchaseShippingFee}), 0.0) as total_purchase
      FROM ${DatabaseTables.purchases}
      WHERE ${DatabaseTables.columnPurchaseStoreId} = ?
        AND ${DatabaseTables.columnPurchaseStatus} != 'cancelled'
        AND ${DatabaseTables.columnCreatedAt} >= ?
        AND ${DatabaseTables.columnCreatedAt} <= ?
      ''',
      [storeId, startIso, endIso],
    );

    final totalPurchaseSpend = (purchaseResult.first['total_purchase'] as num?)?.toDouble() ?? 0.0;

    final refundResult = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(${DatabaseTables.columnPurchaseTotalAmount} + ${DatabaseTables.columnPurchaseServiceFee} + ${DatabaseTables.columnPurchaseShippingFee}), 0.0) as pending_refund
      FROM ${DatabaseTables.purchases}
      WHERE ${DatabaseTables.columnPurchaseStoreId} = ?
        AND ${DatabaseTables.columnPurchaseRefundStatus} IN ('pending_refund', 'pending')
      ''',
      [storeId],
    );

    final totalPendingRefund = (refundResult.first['pending_refund'] as num?)?.toDouble() ?? 0.0;

    final grossProfit = totalRevenue - totalCogs;
    final profitMargin = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0.0;
    final averageBasket = txCount > 0 ? totalRevenue / txCount : 0.0;

    return ReportSummaryModel(
      totalRevenue: totalRevenue,
      totalCogs: totalCogs,
      grossProfit: grossProfit,
      profitMargin: profitMargin,
      transactionCount: txCount,
      averageBasket: averageBasket,
      totalPurchaseSpend: totalPurchaseSpend,
      totalPendingRefund: totalPendingRefund,
    );
  }

  Future<List<TopProductModel>> getTopProducts(
    DatabaseExecutor db, {
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT 
        si.${DatabaseTables.columnSaleItemProductId} as product_id,
        p.${DatabaseTables.columnProductName} as product_name,
        p.${DatabaseTables.columnProductCategory} as product_category,
        COALESCE(SUM(si.${DatabaseTables.columnSaleItemQuantity}), 0.0) as qty_sold,
        COALESCE(SUM(si.${DatabaseTables.columnSaleItemSubtotal}), 0.0) as total_revenue,
        COALESCE(SUM(si.${DatabaseTables.columnSaleItemSubtotal} - (si.${DatabaseTables.columnSaleItemQuantity} * si.${DatabaseTables.columnSaleItemCostPrice})), 0.0) as total_profit
      FROM ${DatabaseTables.saleItems} si
      INNER JOIN ${DatabaseTables.sales} s ON si.${DatabaseTables.columnSaleItemSaleId} = s.${DatabaseTables.columnId}
      INNER JOIN ${DatabaseTables.products} p ON si.${DatabaseTables.columnSaleItemProductId} = p.${DatabaseTables.columnId}
      WHERE s.${DatabaseTables.columnSaleStoreId} = ?
        AND UPPER(s.${DatabaseTables.columnSaleStatus}) != 'VOIDED'
        AND s.${DatabaseTables.columnCreatedAt} >= ?
        AND s.${DatabaseTables.columnCreatedAt} <= ?
      GROUP BY si.${DatabaseTables.columnSaleItemProductId}, p.${DatabaseTables.columnProductName}, p.${DatabaseTables.columnProductCategory}
      ORDER BY qty_sold DESC
      LIMIT ?
      ''',
      [storeId, startIso, endIso, limit],
    );

    return result.map((row) {
      return TopProductModel(
        productId: row['product_id'] as String,
        productName: row['product_name'] as String,
        category: row['product_category'] as String?,
        quantitySold: (row['qty_sold'] as num).toDouble(),
        revenue: (row['total_revenue'] as num).toDouble(),
        profit: (row['total_profit'] as num).toDouble(),
      );
    }).toList();
  }

  Future<List<DailyTrendPoint>> getDailyTrend(
    DatabaseExecutor db, {
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT 
        s.sale_date,
        s.daily_revenue,
        COALESCE(c.daily_cogs, 0.0) as daily_cogs
      FROM (
        SELECT 
          substr(${DatabaseTables.columnCreatedAt}, 1, 10) as sale_date,
          COALESCE(SUM(${DatabaseTables.columnSaleFinalAmount}), 0.0) as daily_revenue
        FROM ${DatabaseTables.sales}
        WHERE ${DatabaseTables.columnSaleStoreId} = ?
          AND UPPER(${DatabaseTables.columnSaleStatus}) != 'VOIDED'
          AND ${DatabaseTables.columnCreatedAt} >= ?
          AND ${DatabaseTables.columnCreatedAt} <= ?
        GROUP BY sale_date
      ) s
      LEFT JOIN (
        SELECT 
          substr(s2.${DatabaseTables.columnCreatedAt}, 1, 10) as sale_date,
          COALESCE(SUM(si.${DatabaseTables.columnSaleItemQuantity} * si.${DatabaseTables.columnSaleItemCostPrice}), 0.0) as daily_cogs
        FROM ${DatabaseTables.saleItems} si
        INNER JOIN ${DatabaseTables.sales} s2 ON si.${DatabaseTables.columnSaleItemSaleId} = s2.${DatabaseTables.columnId}
        WHERE s2.${DatabaseTables.columnSaleStoreId} = ?
          AND UPPER(s2.${DatabaseTables.columnSaleStatus}) != 'VOIDED'
          AND s2.${DatabaseTables.columnCreatedAt} >= ?
          AND s2.${DatabaseTables.columnCreatedAt} <= ?
        GROUP BY sale_date
      ) c ON s.sale_date = c.sale_date
      ORDER BY s.sale_date ASC
      ''',
      [storeId, startIso, endIso, storeId, startIso, endIso],
    );

    return result.map((row) {
      final revenue = (row['daily_revenue'] as num).toDouble();
      final cogs = (row['daily_cogs'] as num).toDouble();
      return DailyTrendPoint(
        dateString: row['sale_date'] as String,
        revenue: revenue,
        profit: revenue - cogs,
      );
    }).toList();
  }
}
