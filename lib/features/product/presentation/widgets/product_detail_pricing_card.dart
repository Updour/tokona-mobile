import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_valuation_row.dart';

class ProductDetailPricingCard extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPricingCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final totalCost = product.stockBase * product.baseCostPrice;
    final totalRevenue = product.stockBase * product.baseSellingPrice;
    final totalProfit = product.stockBase * product.marginPerBaseUnit;
    final stockStr = product.stockBase % 1 == 0
        ? product.stockBase.toInt().toString()
        : product.stockBase.toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
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
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 8),
                  Text('Rincian Satuan Dasar', style: AppTypography.labelMedium.copyWith(fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Per ${product.baseUnit}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga Jual Satuan', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(product.baseSellingPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pendapatan per ${product.baseUnit}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HPP Modal Satuan', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(product.baseCostPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Beban modal per ${product.baseUnit}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Laba Bersih per ${product.baseUnit}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      '+${CurrencyFormatter.format(product.marginPerBaseUnit)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.format(product.baseSellingPrice)} - ${CurrencyFormatter.format(product.baseCostPrice)}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Margin +${product.marginPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Total Valuasi Stok Fisik', style: AppTypography.labelMedium),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$stockStr ${product.baseUnit}',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProductDetailValuationRow(
            label: 'Total Modal (HPP Stok)',
            formula: '$stockStr ${product.baseUnit} × ${CurrencyFormatter.format(product.baseCostPrice)} (modal)',
            value: CurrencyFormatter.format(totalCost),
          ),
          const SizedBox(height: 8),
          ProductDetailValuationRow(
            label: 'Total Potensi Omzet',
            formula: '$stockStr ${product.baseUnit} × ${CurrencyFormatter.format(product.baseSellingPrice)} (jual)',
            value: CurrencyFormatter.format(totalRevenue),
          ),
          const SizedBox(height: 8),
          ProductDetailValuationRow(
            label: 'Total Potensi Keuntungan',
            formula: '$stockStr ${product.baseUnit} × ${CurrencyFormatter.format(product.marginPerBaseUnit)} (+${product.marginPercentage.toStringAsFixed(1)}%)',
            value: '+${CurrencyFormatter.format(totalProfit)}',
            valueColor: AppColors.success,
            isBold: true,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }
}
