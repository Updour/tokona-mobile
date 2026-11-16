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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Untuk harga 1 $baseUnit sudah diatur di form utama atas (Harga Jual Dasar). Di sini khusus potongan harga saat beli ≥ 2 $baseUnit dst.',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
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
                    Text('Harga Grosir / Kuantitas Bertingkat', style: AppTypography.labelMedium),
                    const SizedBox(height: 2),
                    Text('Diskon otomatis saat pelanggan beli banyak (≥ 2, ≥ 5 $baseUnit, dst)', style: AppTypography.bodySmall),
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
