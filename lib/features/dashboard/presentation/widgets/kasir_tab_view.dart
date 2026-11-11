import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/dashboard/presentation/widgets/kasir_header_bar.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_bottom_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_dock.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_product_card.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class KasirTabView extends ConsumerStatefulWidget {
  const KasirTabView({super.key});

  @override
  ConsumerState<KasirTabView> createState() => _KasirTabViewState();
}

class _KasirTabViewState extends ConsumerState<KasirTabView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeScan(List<ProductModel> products) async {
    final code = await CameraBarcodeScanner.scan(
      context,
      title: 'Scan Barcode Kasir',
    );
    if (code == null || !mounted) return;

    final matchedName = ref.read(cartProvider.notifier).scanBarcodeToCart(code, products);
    if (!mounted) return;

    if (matchedName != null) {
      HapticFeedback.lightImpact();
      AppToast.showSuccess(context, '$matchedName masuk keranjang');
    } else {
      AppToast.showWarning(context, 'Barcode $code tidak terdaftar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final cart = ref.watch(cartProvider);
    final allProducts = productState.products;

    final categories = ['Semua', ...{
      for (final p in allProducts)
        if (p.category != null && p.category!.trim().isNotEmpty) p.category!.trim()
    }];

    final query = _searchController.text.trim().toLowerCase();
    final filtered = allProducts.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          (p.sku != null && p.sku!.toLowerCase().contains(query));
      final matchesCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: KasirHeaderBar(
                products: allProducts,
                count: filtered.length,
                isSearchExpanded: _isSearchExpanded,
                searchController: _searchController,
                onSearchExpandedChanged: (val) => setState(() => _isSearchExpanded = val),
                onSearchQueryChanged: (_) => setState(() {}),
                onScanBarcode: () => _handleBarcodeScan(allProducts),
              ),
            ),
            if (categories.length > 1)
              _buildCategoryChips(categories),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final inCartQty = cart.items
                            .where((it) => it.product.id == product.id)
                            .fold(0.0, (acc, it) => acc + it.quantity);

                        return PosProductCard(
                          product: product,
                          inCartQty: inCartQty,
                          onAddToCart: (p, unit) {
                            HapticFeedback.lightImpact();
                            ref.read(cartProvider.notifier).addToCart(p, unit: unit);
                          },
                          onDecrement: (p, unit) {
                            HapticFeedback.lightImpact();
                            ref.read(cartProvider.notifier).decrementFromCart(p, unit: unit);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PosCartDock(
            cart: cart,
            onTap: () => PosCartBottomSheet.show(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text('Tidak ada produk yang cocok', style: AppTypography.labelMedium),
          const SizedBox(height: 3),
          Text('Coba gunakan kata kunci lain atau scan barcode', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
