import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/classification_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/product/presentation/widgets/add_product_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/edit_product_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/product_card_item.dart';
import 'package:tokona/features/product/presentation/widgets/product_category_filter_bar.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/product_device_filter_bar.dart';
import 'package:tokona/features/product/presentation/widgets/product_empty_state.dart';
import 'package:tokona/features/product/presentation/widgets/product_filter_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/product_minimal_header.dart';
import 'package:tokona/features/product/presentation/widgets/quick_stock_hpp_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/stock_adjustment_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/stock_card_history_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_bottom_sheet.dart';

class ProdukTabView extends ConsumerStatefulWidget {
  const ProdukTabView({super.key});

  @override
  ConsumerState<ProdukTabView> createState() => _ProdukTabViewState();
}

class _ProdukTabViewState extends ConsumerState<ProdukTabView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        ref.read(productListProvider.notifier).loadProducts(store.id);
        ref.read(classificationProvider.notifier).load(store.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddProductModal(String storeId) {
    _searchController.clear();
    final classification = ref.read(classificationProvider);
    AddProductBottomSheet.show(
      context,
      availableCategories: classification.categories,
      availableProductTypes: classification.productTypes,
      onSubmit: (dto) async {
        final ok = await ref.read(productListProvider.notifier).addProduct(storeId, dto);
        if (ok) ref.read(classificationProvider.notifier).load(storeId);
        return ok;
      },
    );
  }

  void _openEditProductModal(ProductModel product, String storeId) {
    final classification = ref.read(classificationProvider);
    EditProductBottomSheet.show(
      context,
      product: product,
      availableCategories: classification.categories,
      availableProductTypes: classification.productTypes,
      onSubmit: (dto) async {
        final ok = await ref.read(productListProvider.notifier).updateProduct(product.id, storeId, dto);
        if (ok) ref.read(classificationProvider.notifier).load(storeId);
        return ok;
      },
      onRestock: () => AddPurchaseBottomSheet.show(context),
    );
  }

  Future<bool> _handleDelete(ProductModel product, String? storeId) async {
    if (storeId == null) return false;
    final notifier = ref.read(productListProvider.notifier);
    final txCount = await notifier.getTransactionCount(product.id);
    if (!mounted) return false;
    final isForce = txCount > 0;
    final confirm = await AppDialog.showConfirmation(
      context,
      title: isForce ? 'Hapus Produk & Transaksi' : 'Hapus Produk',
      message: isForce
          ? '${product.name} memiliki $txCount transaksi. Hapus permanen produk beserta riwayatnya?'
          : 'Yakin ingin menghapus ${product.name}? Data kemasan dan harga akan ikut terhapus.',
      confirmText: isForce ? 'Hapus Permanen' : 'Hapus Produk',
      isDestructive: true, icon: isForce ? Icons.warning_amber_rounded : Icons.delete_outline_rounded,
    );
    if (confirm != true || !mounted) return false;
    return await notifier.deleteProduct(product.id, storeId, force: isForce);
  }

  Future<void> _handleBarcodeScan(String? storeId) async {
    final code = await CameraBarcodeScanner.scan(
      context,
      title: 'Cari Produk via Barcode',
    );
    if (code != null && mounted) {
      setState(() {
        _isSearching = true;
        _searchController.text = code;
      });
      if (storeId != null) ref.read(productListProvider.notifier).setSearchQuery(code, storeId);
    }
  }

  void _openFilterSheet(String storeId) {
    ProductFilterBottomSheet.show(
      context,
      initialFilter: ref.read(productListProvider).filterState,
      onApply: (filter) => ref.read(productListProvider.notifier).setFilterState(storeId, filter),
      onReset: () => ref.read(productListProvider.notifier).resetFilters(storeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final productState = ref.watch(productListProvider);
    final productNotifier = ref.read(productListProvider.notifier);

    ref.listen(productListProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) AppToast.showError(context, next.errorMessage!);
      if (next.successMessage != null && next.successMessage != prev?.successMessage) AppToast.showSuccess(context, next.successMessage!);
    });

    final hasActiveFilter = productState.filterState.hasActiveCustomFilters ||
        productState.selectedCategory != null ||
        productState.selectedDeviceTag != null;
    final activeFilterCount = productState.filterState.activeFilterCount +
        (productState.selectedCategory != null ? 1 : 0) +
        (productState.selectedDeviceTag != null ? 1 : 0);

    final classification = ref.watch(classificationProvider);
    final Set<String> catSet = {
      for (final c in classification.categories)
        if (c.trim().isNotEmpty) c.trim(),
      for (final p in productState.products)
        if (p.category != null && p.category!.trim().isNotEmpty) p.category!.trim(),
    };
    final categories = ['Semua', ...catSet];

    return RefreshIndicator(
      onRefresh: () async {
        if (store == null) return;
        await Future.wait([productNotifier.loadProducts(store.id), ref.read(classificationProvider.notifier).load(store.id)]);
      },
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          ProductMinimalHeader(
            productCount: productState.products.length,
            isSearching: _isSearching,
            searchController: _searchController,
            onSearchToggled: (searching) {
              setState(() => _isSearching = searching);
              if (!searching && store != null) productNotifier.setSearchQuery('', store.id);
            },
            onSearchChanged: (val) { if (store != null) productNotifier.setSearchQuery(val, store.id); },
            onBarcodeScan: () => _handleBarcodeScan(store?.id),
            onOpenFilter: () { if (store != null) _openFilterSheet(store.id); },
            activeFilterCount: activeFilterCount,
            onAddProduct: store == null ? null : () => _openAddProductModal(store.id),
          ),
          const SizedBox(height: 8),
          ProductCategoryFilterBar(
            categories: categories,
            selectedCategory: productState.selectedCategory,
            onSelectCategory: (cat) {
              if (store != null) productNotifier.setCategory(cat, store.id);
            },
          ),
          if (categories.length > 1) const SizedBox(height: 8),
          ProductDeviceFilterBar(
            deviceSummaries: productState.deviceSummaries,
            selectedDevice: productState.selectedDeviceTag,
            onSelectDevice: (dev) {
              if (store != null) productNotifier.setDeviceTag(dev, store.id);
            },
          ),
          const SizedBox(height: 8),
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Filter aktif ($activeFilterCount)${productState.selectedDeviceTag != null ? ' • 📱 ${productState.selectedDeviceTag}' : ''}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        if (store != null) productNotifier.resetFilters(store.id);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restart_alt_rounded, size: 12, color: Color(0xFFDC2626)),
                            SizedBox(width: 3),
                            Text('Reset', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 10.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (productState.isLoading && productState.products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (productState.products.isEmpty)
            const ProductEmptyState()
          else
            ...productState.products.map(
              (p) => ProductCardItem(
                product: p,
                onTap: () => ProductDetailBottomSheet.show(context, product: p),
                onAdjustStock: () => StockAdjustmentSheet.show(context, product: p),
                onStockCard: () => StockCardHistorySheet.show(context, product: p),
                onRestock: () => AddPurchaseBottomSheet.show(context),
                onQuickAdjust: store == null
                    ? null
                    : () => QuickStockHppSheet.show(context, product: p, initialTab: 0,
                          onAdjustStock: (s) => productNotifier.adjustStock(p.id, store.id, s),
                          onQuickEditPrice: (c, s) => productNotifier.updatePrices(p.id, store.id, c, s)),
                onEdit: store == null ? null : () => _openEditProductModal(p, store.id),
                onDelete: () => _handleDelete(p, store?.id),
              ),
            ),
        ],
      ),
    );
  }
}
