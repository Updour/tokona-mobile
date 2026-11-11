import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';

class PurchaseProductPickerSheet extends StatefulWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductSelected;

  const PurchaseProductPickerSheet({
    super.key,
    required this.products,
    required this.onProductSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ProductModel> products,
    required ValueChanged<ProductModel> onProductSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseProductPickerSheet(products: products, onProductSelected: onProductSelected),
    );
  }

  @override
  State<PurchaseProductPickerSheet> createState() => _PurchaseProductPickerSheetState();
}

class _PurchaseProductPickerSheetState extends State<PurchaseProductPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final set = <String>{};
    for (final p in widget.products) {
      if (p.category != null && p.category!.trim().isNotEmpty) set.add(p.category!.trim());
    }
    return set.toList()..sort();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return widget.products.where((p) {
      if (_selectedCategory != null && p.category != _selectedCategory) return false;
      if (query.isEmpty) return true;
      final nameMatch = p.name.toLowerCase().contains(query);
      final skuMatch = p.sku != null && p.sku!.toLowerCase().contains(query);
      final barcodeMatch = p.units.any((u) => u.barcode != null && u.barcode!.toLowerCase().contains(query));
      return nameMatch || skuMatch || barcodeMatch;
    }).toList();
  }

  Future<void> _handleScanBarcode() async {
    final code = await CameraBarcodeScanner.scan(context, title: 'Pindai Barcode Produk');
    if (code == null || !mounted) return;
    for (final p in widget.products) {
      if (p.sku == code || p.units.any((u) => u.barcode == code)) {
        Navigator.of(context).pop();
        widget.onProductSelected(p);
        return;
      }
    }
    AppToast.showWarning(context, 'Barcode $code tidak ditemukan');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final categories = _categories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Center(
            child: Container(margin: const EdgeInsets.symmetric(vertical: 8), width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih Produk Belanja', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${filtered.length} produk siap dibeli', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama produk, SKU, barcode...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _handleScanBarcode,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryDark, size: 20),
                  ),
                ),
              ],
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCategoryChip('Semua', _selectedCategory == null, () => setState(() => _selectedCategory = null)),
                  ...categories.map((c) => _buildCategoryChip(c, _selectedCategory == c, () => setState(() => _selectedCategory = _selectedCategory == c ? null : c))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(_searchQuery.isNotEmpty ? 'Produk Tidak Ditemukan' : 'Belum Ada Master Produk', style: AppTypography.labelMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) => _buildProductItemCard(filtered[idx]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textSecondary),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border)),
        visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
      ),
    );
  }

  Widget _buildProductItemCard(ProductModel p) {
    final isOutOfStock = p.stockBase <= 0;
    final isLow = p.isLowStock && !isOutOfStock;
    final stockColor = isOutOfStock ? AppColors.error : (isLow ? const Color(0xFFD97706) : AppColors.textSecondary);
    final stockBg = isOutOfStock ? const Color(0xFFFEE2E2) : (isLow ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9));

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            widget.onProductSelected(p);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ProductThumbnailAvatar(imagePath: p.imagePath, productName: p.name, size: 42, borderRadius: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: AppTypography.labelMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (p.sku != null && p.sku!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                              child: Text(p.sku!, style: const TextStyle(fontSize: 9.5, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                            ),
                          if (p.category != null && p.category!.isNotEmpty)
                            Text(p.category!, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: stockBg, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              isOutOfStock ? 'Stok Habis' : 'Stok: ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit}',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: stockColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('HPP: ', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          Text(
                            CurrencyFormatter.format(p.baseCostPrice),
                            style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                          if (p.units.isNotEmpty) Text('• ${p.units.length + 1} satuan', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Pilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
