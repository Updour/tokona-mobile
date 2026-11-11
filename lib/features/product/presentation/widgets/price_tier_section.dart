import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_field_tile.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_form_card.dart';

class PriceTierSection extends StatelessWidget {
  final List<CreateProductPriceTierDto> priceTiers;
  final String baseUnit;
  final double baseCostPrice;
  final double baseSellingPrice;
  final ValueChanged<CreateProductPriceTierDto> onAddTier;
  final ValueChanged<int> onRemoveTier;

  const PriceTierSection({
    super.key,
    required this.priceTiers,
    required this.baseUnit,
    required this.baseCostPrice,
    required this.baseSellingPrice,
    required this.onAddTier,
    required this.onRemoveTier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
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
                  Icons.price_change_outlined,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harga Grosir Bertingkat', style: AppTypography.labelMedium),
                    const SizedBox(height: 2),
                    Text('Diskon otomatis saat beli kuantitas banyak', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (priceTiers.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...priceTiers.asMap().entries.map(
                  (entry) => PriceTierFieldTile(
                    index: entry.key,
                    tier: entry.value,
                    baseUnit: baseUnit,
                    baseSellingPrice: baseSellingPrice,
                    onRemove: () => onRemoveTier(entry.key),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          PriceTierFormCard(
            baseUnit: baseUnit,
            baseCostPrice: baseCostPrice,
            baseSellingPrice: baseSellingPrice,
            onAddTier: onAddTier,
          ),
        ],
      ),
    );
  }
}
