enum ProductStockFilter {
  all,
  lowStock,
  outOfStock,
  inStock,
}

enum ProductDateFilter {
  allTime,
  today,
  last7Days,
  last30Days,
  custom,
}

enum ProductSortBy {
  nameAsc,
  nameDesc,
  newest,
  oldest,
  stockAsc,
  stockDesc,
  priceAsc,
  priceDesc,
  marginDesc,
}

extension ProductStockFilterX on ProductStockFilter {
  String get label {
    switch (this) {
      case ProductStockFilter.all:
        return 'Semua Stok';
      case ProductStockFilter.lowStock:
        return 'Stok Menipis';
      case ProductStockFilter.outOfStock:
        return 'Stok Habis';
      case ProductStockFilter.inStock:
        return 'Stok Tersedia';
    }
  }
}

extension ProductDateFilterX on ProductDateFilter {
  String get label {
    switch (this) {
      case ProductDateFilter.allTime:
        return 'Semua Waktu';
      case ProductDateFilter.today:
        return 'Hari Ini';
      case ProductDateFilter.last7Days:
        return '7 Hari Terakhir';
      case ProductDateFilter.last30Days:
        return '30 Hari Terakhir';
      case ProductDateFilter.custom:
        return 'Pilih Tanggal';
    }
  }
}

extension ProductSortByX on ProductSortBy {
  String get label {
    switch (this) {
      case ProductSortBy.nameAsc:
        return 'Nama (A-Z)';
      case ProductSortBy.nameDesc:
        return 'Nama (Z-A)';
      case ProductSortBy.newest:
        return 'Terbaru Ditambahkan';
      case ProductSortBy.oldest:
        return 'Terlama Ditambahkan';
      case ProductSortBy.stockAsc:
        return 'Stok Terendah';
      case ProductSortBy.stockDesc:
        return 'Stok Tertinggi';
      case ProductSortBy.priceAsc:
        return 'Harga Termurah';
      case ProductSortBy.priceDesc:
        return 'Harga Termahal';
      case ProductSortBy.marginDesc:
        return 'Margin Laba Tertinggi';
    }
  }
}

class ProductFilterState {
  final ProductStockFilter stockFilter;
  final ProductDateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ProductSortBy sortBy;
  final double? minPrice;
  final double? maxPrice;

  const ProductFilterState({
    this.stockFilter = ProductStockFilter.all,
    this.dateFilter = ProductDateFilter.allTime,
    this.customStartDate,
    this.customEndDate,
    this.sortBy = ProductSortBy.nameAsc,
    this.minPrice,
    this.maxPrice,
  });

  bool get hasActiveCustomFilters {
    return stockFilter != ProductStockFilter.all ||
        dateFilter != ProductDateFilter.allTime ||
        sortBy != ProductSortBy.nameAsc ||
        minPrice != null ||
        maxPrice != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (stockFilter != ProductStockFilter.all) count++;
    if (dateFilter != ProductDateFilter.allTime) count++;
    if (sortBy != ProductSortBy.nameAsc) count++;
    if (minPrice != null || maxPrice != null) count++;
    return count;
  }

  ProductFilterState copyWith({
    ProductStockFilter? stockFilter,
    ProductDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    ProductSortBy? sortBy,
    double? minPrice,
    double? maxPrice,
    bool clearCustomDates = false,
    bool clearPriceRange = false,
  }) {
    return ProductFilterState(
      stockFilter: stockFilter ?? this.stockFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: clearCustomDates ? null : (customStartDate ?? this.customStartDate),
      customEndDate: clearCustomDates ? null : (customEndDate ?? this.customEndDate),
      sortBy: sortBy ?? this.sortBy,
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
    );
  }
}

