import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';

class PurchaseDetailItemTile extends StatelessWidget {
  final PurchaseItemModel item;

  const PurchaseDetailItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity;
    final totalBase = item.totalBaseQuantity % 1 == 0 ? item.totalBaseQuantity.toInt() : item.totalBaseQuantity;
    final hasConversion = item.conversionFactor > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Produk',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '$qty ${item.unitName} @ ${CurrencyFormatter.format(item.unitCost)}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
                if (hasConversion)
                  Text(
                    'Total setara: $totalBase Pcs',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.subtotal),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

