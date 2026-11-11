import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_valuation_model.dart';

class ProductValuationCard extends StatefulWidget {
  final ProductValuationModel valuation;

  const ProductValuationCard({super.key, required this.valuation});

  @override
  State<ProductValuationCard> createState() => _ProductValuationCardState();
}

class _ProductValuationCardState extends State<ProductValuationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.valuation;
    if (v.totalSku == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0284C7), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valuasi Modal Aset Stok',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(v.totalAssetCost),
                          style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (v.outOfStockCount > 0 || v.lowStockCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: v.outOfStockCount > 0 ? AppColors.errorContainer : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        v.outOfStockCount > 0
                            ? '${v.outOfStockCount} Habis'
                            : '${v.lowStockCount} Menipis',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: v.outOfStockCount > 0 ? AppColors.error : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildMetricRow(
                    label: 'Estimasi Omzet Jual',
                    value: CurrencyFormatter.format(v.totalPotentialRevenue),
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    label: 'Estimasi Total Laba',
                    value: '${CurrencyFormatter.format(v.potentialProfit)} (${v.profitMarginPercentage.toStringAsFixed(1)}%)',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    label: 'Total Fisik Barang',
                    value: '${v.totalPhysicalStock.toStringAsFixed(0)} item (${v.totalSku} SKU)',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF6366F1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

