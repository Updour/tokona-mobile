import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/payment/data/repositories/store_capital_repository.dart';
import 'package:tokona/features/payment/domain/models/store_capital_model.dart';
import 'package:tokona/features/payment/domain/models/store_capital_state.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';

final storeCapitalControllerProvider = StateNotifierProvider<StoreCapitalController, StoreCapitalState>((ref) {
  final repo = ref.watch(storeCapitalRepositoryProvider);
  return StoreCapitalController(repo, ref);
});

class StoreCapitalController extends StateNotifier<StoreCapitalState> {
  final StoreCapitalRepository _repository;
  final Ref _ref;

  StoreCapitalController(this._repository, this._ref) : super(const StoreCapitalState());

  Future<void> loadCapitals(String storeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getCapitals(
        storeId,
        type: state.selectedType,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final summary = await _repository.getSummary(storeId);

      state = state.copyWith(
        isLoading: false,
        capitals: items,
        initialCapital: summary['initial'] ?? 0.0,
        addedCapital: summary['added'] ?? 0.0,
        withdrawnCapital: summary['withdrawn'] ?? 0.0,
        netCapital: summary['net'] ?? 0.0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setTypeFilter(String type, String storeId) {
    state = state.copyWith(selectedType: type);
    loadCapitals(storeId);
  }

  void setDateRange(DateTime? start, DateTime? end, String storeId) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    loadCapitals(storeId);
  }

  Future<bool> addCapital(StoreCapitalModel capital) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.addCapital(capital);
      await _ref.read(paymentAccountListProvider.notifier).loadAccounts(capital.storeId);
      await loadCapitals(capital.storeId);
      state = state.copyWith(
        successMessage: 'Data modal toko berhasil dicatat',
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

  Future<bool> deleteCapital(StoreCapitalModel capital) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteCapital(capital);
      await _ref.read(paymentAccountListProvider.notifier).loadAccounts(capital.storeId);
      await loadCapitals(capital.storeId);
      state = state.copyWith(
        successMessage: 'Catatan modal berhasil dihapus',
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
