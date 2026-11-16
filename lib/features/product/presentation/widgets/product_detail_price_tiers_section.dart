import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class ProductDetailPriceTiersSection extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPriceTiersSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    if (product.priceTiers.isEmpty) return const SizedBox.shrink();

    final sortedTiers = [...product.priceTiers]..sort((a, b) => a.minQuantity.compareTo(b.minQuantity));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sell_outlined,
                    color: AppColors.secondary,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga Grosir Bertingkat',
                        style: AppTypography.labelMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Diskon kuantitas otomatis di kasir',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${product.priceTiers.length} Tingkat',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: sortedTiers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tier = sortedTiers[index];
              final unitLabel = tier.unitName?.isNotEmpty == true ? tier.unitName! : product.baseUnit;
              final qtyText = tier.minQuantity.toStringAsFixed(tier.minQuantity.truncateToDouble() == tier.minQuantity ? 0 : 1);
              final discount = product.baseSellingPrice > tier.price ? product.baseSellingPrice - tier.price : 0.0;
              final percent = product.baseSellingPrice > 0 ? ((discount / product.baseSellingPrice) * 100).round() : 0;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Beli ≥ $qtyText $unitLabel',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (discount > 0)
                            Text(
                              'Hemat ${CurrencyFormatter.format(discount)} ($percent%)',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            )
                          else
                            Text('Harga Khusus', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          Text(
                            'per $unitLabel',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(tier.price),
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
