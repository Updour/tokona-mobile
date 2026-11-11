import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';

class SaleDetailItemTile extends StatelessWidget {
  final SaleItemModel item;

  const SaleDetailItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity.toStringAsFixed(0)}x',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Produk',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.format(item.sellingPrice)} / ${item.unitName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              if (item.totalProfit > 0)
                Text(
                  'Untung +${CurrencyFormatter.format(item.totalProfit)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

