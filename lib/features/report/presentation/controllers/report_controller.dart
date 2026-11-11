import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/report/data/repositories/report_repository.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/domain/models/report_state.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportRepository(db);
});

final reportControllerProvider = StateNotifierProvider<ReportController, ReportState>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return ReportController(repo);
});

class ReportController extends StateNotifier<ReportState> {
  final ReportRepository _repo;

  ReportController(this._repo) : super(ReportState.initial());

  Future<void> loadReport(
    String storeId, {
    ReportFilterType? filter,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final activeFilter = filter ?? state.selectedFilter;
    final start = customStart ?? state.customStartDate;
    final end = customEnd ?? state.customEndDate;

    state = state.copyWith(
      isLoading: true,
      selectedFilter: activeFilter,
      customStartDate: start,
      customEndDate: end,
      clearError: true,
    );

    try {
      final summary = await _repo.getSummary(
        storeId,
        activeFilter,
        customStart: start,
        customEnd: end,
      );
      final topProducts = await _repo.getTopProducts(
        storeId,
        activeFilter,
        customStart: start,
        customEnd: end,
      );
      final dailyTrends = await _repo.getDailyTrend(
        storeId,
        activeFilter,
        customStart: start,
        customEnd: end,
      );

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        topProducts: topProducts,
        dailyTrends: dailyTrends,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat laporan: ${e.toString()}',
      );
    }
  }

  Future<void> changeFilter(
    String storeId,
    ReportFilterType filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    await loadReport(
      storeId,
      filter: filter,
      customStart: customStart,
      customEnd: customEnd,
    );
  }
}
