import 'package:tokona/features/pos/domain/models/sale_model.dart';

enum SaleDateFilter {
  all,
  today,
  last7Days,
  thisMonth,
  custom,
}

extension SaleDateFilterX on SaleDateFilter {
  String get label {
    switch (this) {
      case SaleDateFilter.all:
        return 'Semua';
      case SaleDateFilter.today:
        return 'Hari Ini';
      case SaleDateFilter.last7Days:
        return '7 Hari';
      case SaleDateFilter.thisMonth:
        return 'Bulan Ini';
      case SaleDateFilter.custom:
        return 'Pilih Tanggal';
    }
  }
}

class SaleHistoryState {
  final bool isLoading;
  final List<SaleModel> sales;
  final String searchQuery;
  final SaleDateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String paymentMethodFilter;
  final String statusFilter;
  final double totalRevenue;
  final int totalCount;
  final String? errorMessage;
  final String? successMessage;

  const SaleHistoryState({
    this.isLoading = false,
    this.sales = const [],
    this.searchQuery = '',
    this.dateFilter = SaleDateFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.paymentMethodFilter = 'ALL',
    this.statusFilter = 'ALL',
    this.totalRevenue = 0,
    this.totalCount = 0,
    this.errorMessage,
    this.successMessage,
  });

  SaleHistoryState copyWith({
    bool? isLoading,
    List<SaleModel>? sales,
    String? searchQuery,
    SaleDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? paymentMethodFilter,
    String? statusFilter,
    double? totalRevenue,
    int? totalCount,
    String? errorMessage,
    String? successMessage,
    bool clearDates = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SaleHistoryState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: clearDates ? null : (customStartDate ?? this.customStartDate),
      customEndDate: clearDates ? null : (customEndDate ?? this.customEndDate),
      paymentMethodFilter: paymentMethodFilter ?? this.paymentMethodFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

