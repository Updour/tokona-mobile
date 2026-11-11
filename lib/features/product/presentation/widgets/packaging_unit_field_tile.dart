import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';

class PackagingUnitFieldTile extends StatelessWidget {
  final int index;
  final CreateProductUnitDto unit;
  final VoidCallback onRemove;

  const PackagingUnitFieldTile({
    super.key,
    required this.index,
    required this.unit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unit.unitName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primaryDark,
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
                  '1 ${unit.unitName} = ${unit.conversionFactor.toStringAsFixed(0)} Unit Dasar',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'HPP: Rp ${unit.costPrice.toStringAsFixed(0)} • Jual: Rp ${unit.sellingPrice.toStringAsFixed(0)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (unit.barcode != null && unit.barcode!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Barcode: ${unit.barcode}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
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
            tooltip: 'Hapus Satuan',
          ),
        ],
      ),
    );
  }
}
