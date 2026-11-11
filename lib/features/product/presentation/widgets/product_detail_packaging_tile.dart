import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class ProductDetailPackagingTile extends StatelessWidget {
  final ProductUnitModel unit;
  final String baseUnit;
  final double stockBase;

  const ProductDetailPackagingTile({
    super.key,
    required this.unit,
    required this.baseUnit,
    this.stockBase = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cartonCount = unit.conversionFactor > 0 ? stockBase / unit.conversionFactor : 0.0;
    final cartonStr = cartonCount % 1 == 0 ? cartonCount.toInt().toString() : cartonCount.toStringAsFixed(1);
    final fullCartons = unit.conversionFactor > 0 ? (stockBase ~/ unit.conversionFactor) : 0;
    final remainder = unit.conversionFactor > 0 ? (stockBase % unit.conversionFactor).toInt() : 0;
    final totalStockRevenue = cartonCount * unit.sellingPrice;
    final totalStockProfit = cartonCount * unit.marginPerUnit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit.unitName,
                    style: AppTypography.headingSmall.copyWith(fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1 ${unit.unitName} = ${unit.conversionFactor.toStringAsFixed(0)} $baseUnit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRow('Harga Jual per ${unit.unitName}', CurrencyFormatter.format(unit.sellingPrice), isPrimary: true),
          const SizedBox(height: 6),
          _buildRow('Total HPP Modal per ${unit.unitName}', CurrencyFormatter.format(unit.costPrice)),
          const SizedBox(height: 6),
          _buildRow(
            'Laba Bersih per ${unit.unitName}',
            '+${unit.marginPercentage.toStringAsFixed(1)}% (${CurrencyFormatter.format(unit.marginPerUnit)})',
            subtitle: '${CurrencyFormatter.format(unit.sellingPrice)} - ${CurrencyFormatter.format(unit.costPrice)}',
            valueColor: AppColors.success,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimasi Stok Kemasan', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  remainder == 0
                      ? '$fullCartons ${unit.unitName}'
                      : '$fullCartons ${unit.unitName} + $remainder $baseUnit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (stockBase > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              'Total Potensi Jual (${unit.unitName})',
              CurrencyFormatter.format(totalStockRevenue),
              subtitle: '$cartonStr ${unit.unitName} × ${CurrencyFormatter.format(unit.sellingPrice)}',
            ),
            const SizedBox(height: 6),
            _buildRow(
              'Total Potensi Laba (${unit.unitName})',
              '+${CurrencyFormatter.format(totalStockProfit)}',
              subtitle: '$cartonStr ${unit.unitName} × ${CurrencyFormatter.format(unit.marginPerUnit)}',
              valueColor: AppColors.success,
              isBold: true,
            ),
          ],
          if (unit.barcode != null && unit.barcode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Barcode Kemasan: ${unit.barcode}',
              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    String? subtitle,
    Color? valueColor,
    bool isPrimary = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isPrimary ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isBold || isPrimary ? FontWeight.w700 : FontWeight.w600,
            fontSize: isPrimary ? 14 : 12,
          ),
        ),
      ],
    );
  }
}
