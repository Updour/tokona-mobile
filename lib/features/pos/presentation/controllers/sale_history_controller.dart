import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/pos/data/repositories/sale_repository.dart';
import 'package:tokona/features/pos/domain/models/sale_history_state.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

final saleHistoryControllerProvider = StateNotifierProvider<SaleHistoryController, SaleHistoryState>((ref) {
  final repo = ref.watch(saleRepositoryProvider);
  return SaleHistoryController(repo, ref);
});

class SaleHistoryController extends StateNotifier<SaleHistoryState> {
  final SaleRepository _repository;
  final Ref _ref;

  SaleHistoryController(this._repository, this._ref) : super(const SaleHistoryState());

  Future<void> loadSales(String storeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      DateTime? start;
      DateTime? end;
      final now = DateTime.now();

      switch (state.dateFilter) {
        case SaleDateFilter.all:
          break;
        case SaleDateFilter.today:
          start = DateTime(now.year, now.month, now.day);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case SaleDateFilter.last7Days:
          start = now.subtract(const Duration(days: 7));
          end = now;
          break;
        case SaleDateFilter.thisMonth:
          start = DateTime(now.year, now.month, 1);
          end = now;
          break;
        case SaleDateFilter.custom:
          start = state.customStartDate;
          end = state.customEndDate;
          break;
      }

      final items = await _repository.getSales(
        storeId,
        searchQuery: state.searchQuery,
        paymentMethod: state.paymentMethodFilter,
        status: state.statusFilter,
        startDate: start,
        endDate: end,
      );

      final summary = await _repository.getSalesSummary(storeId, startDate: start, endDate: end);

      state = state.copyWith(
        isLoading: false,
        sales: items,
        totalRevenue: summary['total_revenue'] ?? 0.0,
        totalCount: (summary['count'] ?? 0.0).toInt(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setSearchQuery(String query, String storeId) {
    state = state.copyWith(searchQuery: query);
    loadSales(storeId);
  }

  void setDateFilter(SaleDateFilter filter, String storeId, {DateTime? customStart, DateTime? customEnd}) {
    state = state.copyWith(
      dateFilter: filter,
      customStartDate: customStart,
      customEndDate: customEnd,
      clearDates: filter != SaleDateFilter.custom,
    );
    loadSales(storeId);
  }

  void setPaymentMethodFilter(String method, String storeId) {
    state = state.copyWith(paymentMethodFilter: method);
    loadSales(storeId);
  }

  void setStatusFilter(String status, String storeId) {
    state = state.copyWith(statusFilter: status);
    loadSales(storeId);
  }

  Future<bool> voidSale(String saleId, String storeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.voidSale(saleId, storeId);
      await _ref.read(productListProvider.notifier).loadProducts(storeId);
      await loadSales(storeId);
      state = state.copyWith(
        successMessage: 'Transaksi penjualan berhasil dibatalkan dan stok dikembalikan',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

