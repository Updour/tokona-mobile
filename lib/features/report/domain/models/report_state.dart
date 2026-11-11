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
