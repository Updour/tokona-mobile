import 'package:tokona/features/report/domain/models/daily_trend_point.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/domain/models/report_summary_model.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';

class ReportState {
  final bool isLoading;
  final ReportFilterType selectedFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ReportSummaryModel summary;
  final List<TopProductModel> topProducts;
  final List<DailyTrendPoint> dailyTrends;
  final String? errorMessage;

  const ReportState({
    this.isLoading = false,
    this.selectedFilter = ReportFilterType.today,
    this.customStartDate,
    this.customEndDate,
    required this.summary,
    this.topProducts = const [],
    this.dailyTrends = const [],
    this.errorMessage,
  });

  factory ReportState.initial() {
    return ReportState(
      isLoading: false,
      selectedFilter: ReportFilterType.today,
      summary: ReportSummaryModel.empty(),
      topProducts: const [],
      dailyTrends: const [],
    );
  }

  bool get isCustomFilter => selectedFilter == ReportFilterType.custom;

  String get activeFilterLabel {
    if (selectedFilter == ReportFilterType.custom && customStartDate != null && customEndDate != null) {
      return '${customStartDate!.day}/${customStartDate!.month} - ${customEndDate!.day}/${customEndDate!.month}';
    }
    return selectedFilter.label;
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (selectedFilter) {
      case ReportFilterType.today:
        return DateTime(now.year, now.month, now.day, 0, 0, 0);
      case ReportFilterType.yesterday:
        final yest = now.subtract(const Duration(days: 1));
        return DateTime(yest.year, yest.month, yest.day, 0, 0, 0);
      case ReportFilterType.last7Days:
        return DateTime(now.year, now.month, now.day - 6, 0, 0, 0);
      case ReportFilterType.thisMonth:
        return DateTime(now.year, now.month, 1, 0, 0, 0);
      case ReportFilterType.lastMonth:
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateTime(lastMonthEnd.year, lastMonthEnd.month, 1, 0, 0, 0);
      case ReportFilterType.thisYear:
        return DateTime(now.year, 1, 1, 0, 0, 0);
      case ReportFilterType.custom:
        final s = customStartDate ?? DateTime(now.year, now.month, now.day);
        return DateTime(s.year, s.month, s.day, 0, 0, 0);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (selectedFilter) {
      case ReportFilterType.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      case ReportFilterType.yesterday:
        final yest = now.subtract(const Duration(days: 1));
        return DateTime(yest.year, yest.month, yest.day, 23, 59, 59, 999);
      case ReportFilterType.last7Days:
      case ReportFilterType.thisMonth:
      case ReportFilterType.thisYear:
        return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      case ReportFilterType.lastMonth:
        return DateTime(now.year, now.month, 0, 23, 59, 59, 999);
      case ReportFilterType.custom:
        final e = customEndDate ?? DateTime(now.year, now.month, now.day);
        return DateTime(e.year, e.month, e.day, 23, 59, 59, 999);
    }
  }

  ReportState copyWith({
    bool? isLoading,
    ReportFilterType? selectedFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    ReportSummaryModel? summary,
    List<TopProductModel>? topProducts,
    List<DailyTrendPoint>? dailyTrends,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      summary: summary ?? this.summary,
      topProducts: topProducts ?? this.topProducts,
      dailyTrends: dailyTrends ?? this.dailyTrends,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
