import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/supplier/data/repositories/supplier_repository.dart';
import 'package:tokona/features/supplier/domain/dtos/create_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/dtos/update_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return SupplierRepository(appDb);
});

class SupplierState {
  final List<SupplierModel> suppliers;
  final bool isLoading;
  final String? error;
  final String selectedType;

  const SupplierState({
    this.suppliers = const [],
    this.isLoading = false,
    this.error,
    this.selectedType = 'all',
  });

  SupplierState copyWith({
    List<SupplierModel>? suppliers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedType,
  }) {
    return SupplierState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class SupplierController extends StateNotifier<SupplierState> {
  final SupplierRepository _repository;

  SupplierController(this._repository) : super(const SupplierState());

  Future<void> loadSuppliers(String storeId, {String? type, String? searchQuery}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getSuppliers(
        storeId,
        type: type ?? state.selectedType,
        searchQuery: searchQuery,
      );
      state = state.copyWith(suppliers: list, isLoading: false, selectedType: type ?? state.selectedType);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createSupplier(String storeId, CreateSupplierDto dto) async {
    try {
      final created = await _repository.createSupplier(storeId, dto);
      state = state.copyWith(suppliers: [...state.suppliers, created]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateSupplier(String id, UpdateSupplierDto dto) async {
    try {
      final updated = await _repository.updateSupplier(id, dto);
      final list = state.suppliers.map((s) => s.id == id ? updated : s).toList();
      state = state.copyWith(suppliers: list);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      await _repository.deleteSupplier(id);
      final list = state.suppliers.where((s) => s.id != id).toList();
      state = state.copyWith(suppliers: list);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final supplierListProvider = StateNotifierProvider<SupplierController, SupplierState>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return SupplierController(repo);
});
