import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/domain/models/purchase_state.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

final purchaseControllerProvider = StateNotifierProvider<PurchaseController, PurchaseState>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return PurchaseController(repository, ref);
});

class PurchaseController extends StateNotifier<PurchaseState> {
  final PurchaseRepository _repository;
  final Ref _ref;

  PurchaseController(this._repository, this._ref) : super(const PurchaseState());

  Future<void> loadPurchases(String storeId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final list = await _repository.getPurchases(storeId);
      state = state.copyWith(isLoading: false, purchases: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat riwayat pembelian: ${e.toString()}',
      );
    }
  }

  Future<PurchaseModel?> recordPurchase(CreatePurchaseDto dto) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final purchase = await _repository.recordPurchase(dto);
      final updatedList = [purchase, ...state.purchases];
      state = state.copyWith(
        isLoading: false,
        purchases: updatedList,
        successMessage: 'Pembelian barang berhasil disimpan. Stok dan HPP diperbarui.',
      );

      // Refresh product list state to reflect updated stock and HPP immediately
      await _ref.read(productListProvider.notifier).loadProducts(dto.storeId);
      _ref.read(reportControllerProvider.notifier).loadReport(dto.storeId);
      await _ref.read(paymentAccountListProvider.notifier).loadAccounts(dto.storeId);
      _ref.read(activeOrdersProvider.notifier).loadOrders(dto.storeId);
      return purchase;
    } catch (e, stack) {
      debugPrint('Error recording purchase: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mencatat pembelian: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool> updatePurchaseInvoiceAndSupplier({
    required String purchaseId,
    required String invoiceNumber,
    String? supplierName,
    String? notes,
    required String storeId,
  }) async {
    try {
      await _repository.updatePurchaseInvoiceAndSupplier(
        purchaseId: purchaseId,
        invoiceNumber: invoiceNumber,
        supplierName: supplierName,
        notes: notes,
      );
      await loadPurchases(storeId);
      await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
      return true;
    } catch (e) {
      debugPrint('Error updating purchase invoice/supplier: $e');
      return false;
    }
  }
}
