import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';

class PriceTierFieldTile extends StatelessWidget {
  final int index;
  final CreateProductPriceTierDto tier;
  final String baseUnit;
  final double baseSellingPrice;
  final VoidCallback onRemove;

  const PriceTierFieldTile({
    super.key,
    required this.index,
    required this.tier,
    required this.baseUnit,
    required this.baseSellingPrice,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabel = tier.unitName?.isNotEmpty == true ? tier.unitName! : baseUnit;
    final qtyText = tier.minQuantity.toStringAsFixed(tier.minQuantity.truncateToDouble() == tier.minQuantity ? 0 : 1);
    final discountPerUnit = baseSellingPrice > tier.price ? baseSellingPrice - tier.price : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '≥ $qtyText $unitLabel',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CurrencyFormatter.format(tier.price)} / $unitLabel',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                ),
                if (discountPerUnit > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Hemat ${CurrencyFormatter.format(discountPerUnit)} per $unitLabel',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
            onPressed: onRemove,
            tooltip: 'Hapus Tingkatan',
          ),
        ],
      ),
    );
  }
}
