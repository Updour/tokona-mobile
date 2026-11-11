import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class PurchaseHppProjectionCard extends StatelessWidget {
  final ProductModel product;
  final ProductUnitModel? selectedUnit;
  final double quantity;
  final double unitCost;

  const PurchaseHppProjectionCard({
    super.key,
    required this.product,
    required this.selectedUnit,
    required this.quantity,
    required this.unitCost,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final factor = selectedUnit?.conversionFactor ?? 1.0;
    final addedBase = quantity * factor;
    final incomingBaseCost = factor > 0 ? unitCost / factor : unitCost;

    final newStock = product.stockBase + addedBase;
    double projectedHpp = product.baseCostPrice;
    if (newStock > 0 && addedBase > 0) {
      final existingValue = product.stockBase > 0 ? (product.stockBase * product.baseCostPrice) : 0.0;
      final incomingValue = addedBase * incomingBaseCost;
      projectedHpp = (existingValue + incomingValue) / newStock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HPP Modal Saat Ini',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  currency.format(product.baseCostPrice),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Estimasi HPP Baru',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  currency.format(projectedHpp),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
