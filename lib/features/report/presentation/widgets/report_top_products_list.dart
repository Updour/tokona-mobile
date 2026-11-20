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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 28),
            const SizedBox(height: 6),
            Text(
              'Belum Ada Penjualan Produk',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'Produk terlaris akan tampil otomatis setelah ada transaksi kasir.',
              style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: const Color(0xFF94A3B8)),
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
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Produk Terlaris', style: AppTypography.labelMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${items.length} Item', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            final ratio = (product.quantitySold / maxQty).clamp(0.05, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRankBadge(index + 1),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product.category != null && product.category!.isNotEmpty)
                              Text(
                                product.category!,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.quantitySold.toStringAsFixed(0)} Terjual',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Color(0xFF0D9488)),
                          ),
                          Text(
                            CurrencyFormatter.format(product.revenue),
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        index == 0 ? const Color(0xFF0D9488) : const Color(0xFF6366F1),
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
    Color bg = const Color(0xFFF8FAFC);
    Color fg = const Color(0xFF64748B);
    Color border = const Color(0xFFE2E8F0);

    if (rank == 1) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      border = const Color(0xFFFDE68A);
    } else if (rank == 2) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
      border = const Color(0xFFCBD5E1);
    } else if (rank == 3) {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFC2410C);
      border = const Color(0xFFFED7AA);
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border, width: 0.8),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}
