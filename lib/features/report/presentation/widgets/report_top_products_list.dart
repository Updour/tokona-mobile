import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';

class ReportTopProductsList extends StatelessWidget {
  final List<TopProductModel> items;

  const ReportTopProductsList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 32),
            const SizedBox(height: 8),
            Text(
              'Belum Ada Penjualan Produk',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              'Produk terlaris akan tampil otomatis setelah ada transaksi kasir.',
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final maxQty = items.first.quantitySold > 0 ? items.first.quantitySold : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Produk Terlaris', style: AppTypography.labelMedium.copyWith(fontSize: 14)),
              Text('${items.length} Item', style: AppTypography.bodySmall.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            final ratio = (product.quantitySold / maxQty).clamp(0.05, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRankBadge(index + 1),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product.category != null && product.category!.isNotEmpty)
                              Text(
                                product.category!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.quantitySold.toStringAsFixed(0)} Terjual',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
                          ),
                          Text(
                            CurrencyFormatter.format(product.revenue),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        index == 0 ? AppColors.primary : const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color bg = AppColors.surfaceElevated;
    Color fg = AppColors.textSecondary;

    if (rank == 1) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (rank == 2) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
    } else if (rank == 3) {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFC2410C);
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
