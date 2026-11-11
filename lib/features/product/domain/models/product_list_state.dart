import 'package:tokona/features/product/domain/models/device_stock_summary.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_valuation_model.dart';

class ProductListState {
  final bool isLoading;
  final List<ProductModel> products;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedDeviceTag;
  final List<DeviceStockSummary> deviceSummaries;
  final ProductFilterState filterState;
  final ProductValuationModel valuation;
  final String? errorMessage;
  final String? successMessage;

  const ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedDeviceTag,
    this.deviceSummaries = const [],
    this.filterState = const ProductFilterState(),
    this.valuation = const ProductValuationModel(),
    this.errorMessage,
    this.successMessage,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    String? searchQuery,
    String? selectedCategory,
    String? selectedDeviceTag,
    List<DeviceStockSummary>? deviceSummaries,
    ProductFilterState? filterState,
    ProductValuationModel? valuation,
    String? errorMessage,
    String? successMessage,
    bool clearCategory = false,
    bool clearDeviceTag = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDeviceTag: clearDeviceTag ? null : (selectedDeviceTag ?? this.selectedDeviceTag),
      deviceSummaries: deviceSummaries ?? this.deviceSummaries,
      filterState: filterState ?? this.filterState,
      valuation: valuation ?? this.valuation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
