import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_info_dialog.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_tier_form_card.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_unit_field_tile.dart';

class PackagingTierSection extends StatelessWidget {
  final List<CreateProductUnitDto> packagingUnits;
  final double baseCostPrice;
  final ValueChanged<CreateProductUnitDto> onAddUnit;
  final ValueChanged<int> onRemoveUnit;

  const PackagingTierSection({
    super.key,
    required this.packagingUnits,
    required this.baseCostPrice,
    required this.onAddUnit,
    required this.onRemoveUnit,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Satuan Kemasan Bertingkat', style: AppTypography.labelMedium),
                    const SizedBox(height: 2),
                    Text('Eceran & grosir dalam 1 master barang', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                tooltip: 'Panduan Satuan Bertingkat',
                onPressed: () => PackagingInfoDialog.show(context),
              ),
            ],
          ),
          if (packagingUnits.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...packagingUnits.asMap().entries.map(
                  (entry) => PackagingUnitFieldTile(
                    index: entry.key,
                    unit: entry.value,
                    onRemove: () => onRemoveUnit(entry.key),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          PackagingTierFormCard(
            baseCostPrice: baseCostPrice,
            onAddUnit: onAddUnit,
          ),
        ],
      ),
    );
  }
}
