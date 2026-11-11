import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/data/repositories/classification_repository.dart';
import 'package:tokona/features/product/data/repositories/product_repository.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';
import 'package:tokona/features/product/domain/models/product_list_state.dart';
import 'package:tokona/features/product/presentation/controllers/classification_controller.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductRepository(db);
});

final productListProvider = StateNotifierProvider<ProductController, ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final classificationRepo = ref.watch(classificationRepositoryProvider);
  return ProductController(repository, classificationRepo);
});

class ProductController extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  final ClassificationRepository? _classificationRepo;

  ProductController(this._repository, [this._classificationRepo]) : super(const ProductListState());

  Future<void> loadProducts(String storeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filter = state.filterState;
      DateTime? startDate;
      DateTime? endDate;
      final now = DateTime.now();

      switch (filter.dateFilter) {
        case ProductDateFilter.allTime:
          break;
        case ProductDateFilter.today:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case ProductDateFilter.last7Days:
          startDate = now.subtract(const Duration(days: 7));
          endDate = now;
          break;
        case ProductDateFilter.last30Days:
          startDate = now.subtract(const Duration(days: 30));
          endDate = now;
          break;
        case ProductDateFilter.custom:
          startDate = filter.customStartDate;
          endDate = filter.customEndDate;
          break;
      }

      final items = await _repository.getProducts(
        storeId,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        deviceTag: state.selectedDeviceTag,
        stockFilter: filter.stockFilter,
        startDate: startDate,
        endDate: endDate,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        sortBy: filter.sortBy,
      );

      final valuation = await _repository.getValuation(storeId);
      final summaries = await _repository.getDeviceSummaries(storeId);

      state = state.copyWith(
        isLoading: false,
        products: items,
        valuation: valuation,
        deviceSummaries: summaries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> addProduct(String storeId, CreateProductDto dto) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true, searchQuery: null);
    try {
      await _repository.createProduct(storeId, dto);
      if (_classificationRepo != null) {
        if (dto.category != null && dto.category!.trim().isNotEmpty) {
          await _classificationRepo.ensureCategory(storeId, dto.category!);
        }
        if (dto.productType.trim().isNotEmpty) {
          await _classificationRepo.ensureProductType(storeId, dto.productType);
        }
      }
      await loadProducts(storeId);
      state = state.copyWith(
        searchQuery: null,
        successMessage: 'Produk berhasil ditambahkan',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateProduct(String productId, String storeId, UpdateProductDto dto) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repository.updateProduct(productId, dto);
      if (_classificationRepo != null) {
        if (dto.category != null && dto.category!.trim().isNotEmpty) {
          await _classificationRepo.ensureCategory(storeId, dto.category!);
        }
        if (dto.productType.trim().isNotEmpty) {
          await _classificationRepo.ensureProductType(storeId, dto.productType);
        }
      }
      await loadProducts(storeId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Produk berhasil diperbarui',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> adjustStock(String productId, String storeId, double newStock) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repository.updateStock(productId, newStock);
      await loadProducts(storeId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Stok berhasil diperbarui',
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

  Future<bool> updatePrices(String productId, String storeId, double baseCostPrice, double baseSellingPrice) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repository.updatePrices(productId, baseCostPrice, baseSellingPrice);
      await loadProducts(storeId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Harga & HPP berhasil diperbarui',
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

  Future<int> getTransactionCount(String productId) async {
    return await _repository.getTransactionCount(productId);
  }

  Future<bool> deleteProduct(String productId, String storeId, {bool force = false}) async {
    try {
      state = state.copyWith(clearError: true, clearSuccess: true);
      await _repository.deleteProduct(productId, force: force);
      await loadProducts(storeId);
      state = state.copyWith(successMessage: 'Produk berhasil dihapus');
      return true;
    } catch (e) {
      final rawError = e.toString().toLowerCase();
      final msg = rawError.contains('foreign key') || rawError.contains('constraint')
          ? 'Produk tidak dapat dihapus karena sudah memiliki riwayat transaksi pembelian atau penjualan.'
          : e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(errorMessage: msg);
      return false;
    }
  }

  void setSearchQuery(String query, String storeId) {
    state = state.copyWith(searchQuery: query);
    loadProducts(storeId);
  }

  void setCategory(String? category, String storeId) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    loadProducts(storeId);
  }

  void setDeviceTag(String? deviceTag, String storeId) {
    if (deviceTag == null) {
      state = state.copyWith(clearDeviceTag: true);
    } else {
      state = state.copyWith(selectedDeviceTag: deviceTag);
    }
    loadProducts(storeId);
  }

  void setStockFilter(String storeId, ProductStockFilter filter) {
    state = state.copyWith(
      filterState: state.filterState.copyWith(stockFilter: filter),
    );
    loadProducts(storeId);
  }

  void setSortBy(String storeId, ProductSortBy sortBy) {
    state = state.copyWith(
      filterState: state.filterState.copyWith(sortBy: sortBy),
    );
    loadProducts(storeId);
  }

  void setFilterState(String storeId, ProductFilterState filterState) {
    state = state.copyWith(filterState: filterState);
    loadProducts(storeId);
  }

  void resetFilters(String storeId) {
    state = state.copyWith(
      filterState: const ProductFilterState(),
      clearCategory: true,
      clearDeviceTag: true,
      searchQuery: '',
    );
    loadProducts(storeId);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
