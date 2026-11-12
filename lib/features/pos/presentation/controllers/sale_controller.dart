import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/pos/data/repositories/sale_repository.dart';
import 'package:tokona/features/pos/domain/dtos/create_sale_dto.dart';
import 'package:tokona/features/pos/domain/dtos/create_sale_item_dto.dart';
import 'package:tokona/features/pos/domain/models/cart_state.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class SaleState {
  final bool isProcessing;
  final String? errorMessage;
  final SaleModel? lastCompletedSale;

  const SaleState({
    this.isProcessing = false,
    this.errorMessage,
    this.lastCompletedSale,
  });

  SaleState copyWith({
    bool? isProcessing,
    String? errorMessage,
    SaleModel? lastCompletedSale,
    bool clearError = false,
  }) {
    return SaleState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCompletedSale: lastCompletedSale ?? this.lastCompletedSale,
    );
  }
}

final saleControllerProvider = StateNotifierProvider<SaleController, SaleState>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return SaleController(repository, ref);
});

class SaleController extends StateNotifier<SaleState> {
  final SaleRepository _repository;
  final Ref _ref;

  SaleController(this._repository, this._ref) : super(const SaleState());

  Future<SaleModel?> checkout({
    required String storeId,
    required String userId,
    String? customerId,
    required CartState cart,
    required double cashPaid,
    String paymentMethod = 'CASH',
    String? notes,
    String? imagePath,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final items = cart.items.map((item) {
        return CreateSaleItemDto(
          productId: item.product.id,
          unitId: item.selectedUnit?.id,
          unitName: item.unitName,
          quantity: item.quantity,
          conversionFactor: item.conversionFactor,
          sellingPrice: item.unitPrice,
          costPrice: item.product.baseCostPrice,
        );
      }).toList();

      final dto = CreateSaleDto(
        storeId: storeId,
        userId: userId,
        customerId: customerId,
        customerName: cart.customerName,
        discountAmount: cart.discountAmount,
        cashPaid: cashPaid,
        paymentMethod: paymentMethod,
        notes: notes,
        imagePath: imagePath,
        dueDate: dueDate,
        items: items,
      );

      final sale = await _repository.recordSale(dto);

      _ref.read(cartProvider.notifier).clearCart();
      await _ref.read(productListProvider.notifier).loadProducts(storeId);
      _ref.read(reportControllerProvider.notifier).loadReport(storeId);
      await _ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
      if (customerId != null) {
        _ref.read(customerListProvider.notifier).loadCustomers(storeId);
      }

      state = state.copyWith(isProcessing: false, lastCompletedSale: sale);
      return sale;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', ''),
      );
      return null;
    }
  }

  void resetSaleState() {
    state = const SaleState();
  }
}
