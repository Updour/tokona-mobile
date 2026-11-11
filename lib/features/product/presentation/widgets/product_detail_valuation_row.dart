import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class ProductDetailValuationRow extends StatelessWidget {
  final String label;
  final String formula;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final bool isHighlighted;

  const ProductDetailValuationRow({
    super.key,
    required this.label,
    required this.formula,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isHighlighted ? const EdgeInsets.all(10) : const EdgeInsets.symmetric(vertical: 2),
      decoration: isHighlighted
          ? BoxDecoration(
              color: AppColors.successContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                    color: isHighlighted ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formula,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              fontSize: isBold ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
