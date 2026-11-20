import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/data/services/purchase_modifier_service.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/domain/models/purchase_state.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

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
      final autoCount = await _repository.checkAndAutoReceiveExpiredOrders(storeId);
      if (autoCount > 0) {
        _ref.read(productListProvider.notifier).loadProducts(storeId);
        _ref.read(reportControllerProvider.notifier).loadReport(storeId);
      }
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

      final itemSummary = purchase.items.map((e) => '${e.productName ?? "Barang"} (+${e.quantity.toInt()} ${e.unitName})').join(', ');
      AuditLogService.log(
        storeId: dto.storeId,
        userId: dto.userId,
        userName: 'Staf Pengadaan',
        userRole: 'manager',
        actionType: AuditActionType.inventory,
        title: 'Restok Masuk #${purchase.invoiceNumber}',
        description: 'Tambah stok: $itemSummary • Supplier: ${purchase.supplierName ?? "-"}',
        deviceTag: purchase.deviceTag,
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

  Future<bool> updatePurchaseItemsAndDetails({
    required String purchaseId,
    required String invoiceNumber,
    String? supplierName,
    String? notes,
    double? serviceFee,
    double? shippingFee,
    required List<CreatePurchaseItemDto> newItems,
    required String storeId,
  }) async {
    try {
      final modifierService = _ref.read(purchaseModifierServiceProvider);
      await modifierService.updatePurchaseItemsAndDetails(
        purchaseId: purchaseId,
        invoiceNumber: invoiceNumber,
        supplierName: supplierName,
        notes: notes,
        serviceFee: serviceFee,
        shippingFee: shippingFee,
        newItems: newItems,
      );
      await loadPurchases(storeId);
      await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
      await _ref.read(productListProvider.notifier).loadProducts(storeId);
      _ref.read(reportControllerProvider.notifier).loadReport(storeId);
      await _ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
      return true;
    } catch (e) {
      debugPrint('Error updating purchase items: $e');
      return false;
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

  Future<bool> revertToShipping(String purchaseId, String storeId) async {
    try {
      final modifierService = _ref.read(purchaseModifierServiceProvider);
      await modifierService.revertReceivedToShipping(purchaseId);
      await loadPurchases(storeId);
      await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
      await _ref.read(productListProvider.notifier).loadProducts(storeId);
      _ref.read(reportControllerProvider.notifier).loadReport(storeId);
      return true;
    } catch (e) {
      debugPrint('Error reverting purchase status: $e');
      return false;
    }
  }
}
