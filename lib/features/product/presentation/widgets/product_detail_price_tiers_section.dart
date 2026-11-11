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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harga Grosir / Kuantitas', style: AppTypography.labelMedium),
                    const SizedBox(height: 2),
                    Text('Berlaku otomatis di kasir sesuai jumlah pembelian', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sortedTiers.map((tier) {
            final unitLabel = tier.unitName?.isNotEmpty == true ? tier.unitName! : product.baseUnit;
            final qtyText = tier.minQuantity.toStringAsFixed(tier.minQuantity.truncateToDouble() == tier.minQuantity ? 0 : 1);
            final discount = product.baseSellingPrice > tier.price ? product.baseSellingPrice - tier.price : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '≥ $qtyText $unitLabel',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Hemat ${CurrencyFormatter.format(discount)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${CurrencyFormatter.format(tier.price)} / $unitLabel',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
