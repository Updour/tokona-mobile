import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/report/data/daos/report_dao.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/domain/models/report_summary_model.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';

class ReportRepository {
  final AppDatabase _appDatabase;
  final ReportDao _dao;

  ReportRepository(this._appDatabase, [this._dao = const ReportDao()]);

  DateTimeRange getDateRange(
    ReportFilterType filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    switch (filter) {
      case ReportFilterType.today:
        final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case ReportFilterType.yesterday:
        final yest = now.subtract(const Duration(days: 1));
        final start = DateTime(yest.year, yest.month, yest.day, 0, 0, 0);
        final end = DateTime(yest.year, yest.month, yest.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case ReportFilterType.last7Days:
        final start = DateTime(now.year, now.month, now.day - 6, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case ReportFilterType.thisMonth:
        final start = DateTime(now.year, now.month, 1, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case ReportFilterType.lastMonth:
        final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        final lastMonthStart = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1, 0, 0, 0);
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case ReportFilterType.thisYear:
        final start = DateTime(now.year, 1, 1, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case ReportFilterType.custom:
        final s = customStart ?? DateTime(now.year, now.month, now.day, 0, 0, 0);
        final e = customEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        final start = DateTime(s.year, s.month, s.day, 0, 0, 0);
        final end = DateTime(e.year, e.month, e.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
    }
  }

  Future<ReportSummaryModel> getSummary(
    String storeId,
    ReportFilterType filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final db = await _appDatabase.database;
    final range = getDateRange(filter, customStart: customStart, customEnd: customEnd);
    return _dao.getSummary(
      db,
      storeId: storeId,
      startDate: range.start,
      endDate: range.end,
    );
  }

  Future<List<TopProductModel>> getTopProducts(
    String storeId,
    ReportFilterType filter, {
    DateTime? customStart,
    DateTime? customEnd,
    int limit = 5,
  }) async {
    final db = await _appDatabase.database;
    final range = getDateRange(filter, customStart: customStart, customEnd: customEnd);
    return _dao.getTopProducts(
      db,
      storeId: storeId,
      startDate: range.start,
      endDate: range.end,
      limit: limit,
    );
  }

  Future<List<DailyTrendPoint>> getDailyTrend(
    String storeId,
    ReportFilterType filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final db = await _appDatabase.database;
    final range = getDateRange(filter, customStart: customStart, customEnd: customEnd);
    return _dao.getDailyTrend(
      db,
      storeId: storeId,
      startDate: range.start,
      endDate: range.end,
    );
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}
