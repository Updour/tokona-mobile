import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class BerandaTopProductsCard extends ConsumerWidget {
  final VoidCallback? onNavigateToProducts;

  const BerandaTopProductsCard({super.key, this.onNavigateToProducts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportControllerProvider);
    final topProducts = reportState.topProducts;
    final maxQty = topProducts.isEmpty
        ? 1.0
        : topProducts.map((p) => p.quantitySold).reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(topProducts.length),
          const SizedBox(height: 12),
          if (topProducts.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: topProducts.take(5).toList().asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final item = entry.value;
                final ratio = maxQty > 0 ? (item.quantitySold / maxQty).clamp(0.08, 1.0) : 0.08;
                return _buildProductRankTile(item, rank, ratio);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Produk Terlaris', style: AppTypography.headingSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(5)),
                      child: const Text('TOP 5', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                    ),
                  ],
                ),
                Text('Berdasarkan kuantitas penjualan kasir', style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        if (count > 0 && onNavigateToProducts != null)
          InkWell(
            onTap: onNavigateToProducts,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text('Katalog >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.surfaceElevated.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 26, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 5),
          Text('Belum ada data barang terjual', style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildProductRankTile(TopProductModel item, int rank, double ratio) {
    final isFirst = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFFFFFBEB) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isFirst
              ? const Color(0xFFFCD34D)
              : (rank == 2 ? const Color(0xFFCBD5E1) : (rank == 3 ? const Color(0xFFFDBA74).withValues(alpha: 0.5) : AppColors.border)),
          width: isFirst ? 1.3 : 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildRankBadge(rank),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: isFirst ? const Color(0xFF92400E) : AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          '${item.quantitySold.toStringAsFixed(0)} item terjual',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        if (item.category != null && item.category!.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                            child: Text(item.category!, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(item.revenue),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                  ),
                  Text(
                    '+${CurrencyFormatter.format(item.profit)}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 4.5, width: double.infinity, color: AppColors.border.withValues(alpha: 0.3)),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 4.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: rank == 1
                            ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                            : (rank == 2
                                ? [const Color(0xFF64748B), const Color(0xFF475569)]
                                : (rank == 3
                                    ? [const Color(0xFFFB923C), const Color(0xFFEA580C)]
                                    : [const Color(0xFF0D9488), const Color(0xFF0F766E)])),
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.35), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: const Center(
          child: Icon(Icons.workspace_premium_rounded, size: 17, color: Colors.white),
        ),
      );
    }

    if (rank == 2) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('2', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      );
    }

    if (rank == 3) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFB923C), Color(0xFFD97706)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('3', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Text('#$rank', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
    );
  }
}
