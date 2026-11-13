import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

final activeOrdersProvider = StateNotifierProvider<ActiveOrdersController, List<PurchaseModel>>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return ActiveOrdersController(repo, ref);
});

class ActiveOrdersController extends StateNotifier<List<PurchaseModel>> {
  final PurchaseRepository _repository;
  final Ref _ref;

  ActiveOrdersController(this._repository, this._ref) : super(const []);

  Future<void> loadOrders(String storeId) async {
    try {
      final list = await _repository.getActiveOrders(storeId);
      state = list;
    } catch (_) {}
  }

  Future<void> confirmReceived(String purchaseId, String storeId) async {
    await _repository.confirmReceived(purchaseId);
    await loadOrders(storeId);
    _ref.read(productListProvider.notifier).loadProducts(storeId);
    _ref.read(reportControllerProvider.notifier).loadReport(storeId);
    _ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
  }

  Future<void> markAsShipped(String purchaseId, String storeId, {String? trackingNumber}) async {
    await _repository.markAsShipped(purchaseId, trackingNumber: trackingNumber);
    await loadOrders(storeId);
  }

  Future<void> updateTrackingNumber(String purchaseId, String storeId, String trackingNumber) async {
    await _repository.updateTrackingNumber(purchaseId, trackingNumber);
    await loadOrders(storeId);
  }

  Future<void> cancelOrder(String purchaseId, String storeId) async {
    await _repository.cancelPurchase(purchaseId);
    await loadOrders(storeId);
  }
}

