import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/held_orders_bottom_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class KasirHeaderBar extends StatelessWidget {
  final List<ProductModel> products;
  final int count;
  final bool isSearchExpanded;
  final TextEditingController searchController;
  final ValueChanged<bool> onSearchExpandedChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final VoidCallback onScanBarcode;

  const KasirHeaderBar({
    super.key,
    required this.products,
    required this.count,
    required this.isSearchExpanded,
    required this.searchController,
    required this.onSearchExpandedChanged,
    required this.onSearchQueryChanged,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearchExpanded) {
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                onChanged: onSearchQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Cari nama produk / SKU...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.normal),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            if (searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  searchController.clear();
                  onSearchQueryChanged('');
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 13, color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                searchController.clear();
                onSearchExpandedChanged(false);
                onSearchQueryChanged('');
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kasir Tokona', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
              Text('$count barang tersedia', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
        _buildActionPill(
          icon: Icons.search_rounded,
          color: AppColors.textPrimary,
          tooltip: 'Cari Barang',
          onTap: () => onSearchExpandedChanged(true),
        ),
        const SizedBox(width: 6),
        _buildActionPill(
          icon: Icons.qr_code_scanner_rounded,
          color: AppColors.primary,
          tooltip: 'Scan Barcode',
          onTap: onScanBarcode,
        ),
        const SizedBox(width: 6),
        Consumer(
          builder: (context, ref, _) {
            final heldOrders = ref.watch(heldCartProvider);
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildActionPill(
                  icon: Icons.pause_circle_outline_rounded,
                  color: const Color(0xFFD97706),
                  tooltip: 'Pesanan Tertahan',
                  onTap: () => HeldOrdersBottomSheet.show(context),
                ),
                if (heldOrders.isNotEmpty)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        '${heldOrders.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 6),
        _buildActionPill(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF4F46E5),
          tooltip: 'Riwayat Penjualan',
          onTap: () => SalesHistorySheet.show(context),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color, size: 19),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

