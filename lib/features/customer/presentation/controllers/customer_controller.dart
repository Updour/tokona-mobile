import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/data/repositories/customer_repository.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
import 'package:tokona/features/customer/domain/dtos/update_customer_dto.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return CustomerRepository(appDb);
});

class CustomerState {
  final List<CustomerModel> customers;
  final bool isLoading;
  final String? error;
  final String selectedType;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.selectedType = 'all',
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedType,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class CustomerController extends StateNotifier<CustomerState> {
  final CustomerRepository _repository;

  CustomerController(this._repository) : super(const CustomerState());

  Future<void> loadCustomers(String storeId, {String? type, String? searchQuery}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getCustomers(
        storeId,
        type: type ?? state.selectedType,
        searchQuery: searchQuery,
      );
      state = state.copyWith(
        customers: list,
        isLoading: false,
        selectedType: type ?? state.selectedType,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<CustomerModel?> createCustomer(String storeId, CreateCustomerDto dto) async {
    try {
      final created = await _repository.createCustomer(storeId, dto);
      await loadCustomers(storeId);
      return created;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> updateCustomer(String id, UpdateCustomerDto dto) async {
    try {
      await _repository.updateCustomer(id, dto);
      final currentList = state.customers;
      if (currentList.isNotEmpty) {
        final storeId = currentList.first.storeId;
        await loadCustomers(storeId);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      state = state.copyWith(
        customers: state.customers.where((c) => c.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> adjustReceivable(String customerId, double deltaAmount) async {
    try {
      await _repository.adjustReceivable(customerId, deltaAmount);
      final currentList = state.customers;
      if (currentList.isNotEmpty) {
        final storeId = currentList.first.storeId;
        await loadCustomers(storeId);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> payKasbon(CustomerReceivablePaymentModel payment) async {
    try {
      await _repository.recordReceivablePayment(payment);
      await loadCustomers(payment.storeId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<CustomerReceivablePaymentModel>> getReceivablePayments(String customerId) async {
    return await _repository.getReceivablePayments(customerId);
  }

  Future<List<SaleModel>> getCustomerReceivableSales(String customerId) async {
    return await _repository.getCustomerReceivableSales(customerId);
  }
}

final customerListProvider = StateNotifierProvider<CustomerController, CustomerState>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerController(repo);
});
