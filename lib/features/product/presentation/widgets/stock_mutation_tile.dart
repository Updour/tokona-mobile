import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';

class StockMutationTile extends StatelessWidget {
  final StockMutationModel mutation;
  final String baseUnit;

  const StockMutationTile({
    super.key,
    required this.mutation,
    required this.baseUnit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    final formattedDate = dateFormat.format(mutation.createdAt);
    final isIn = mutation.isIn;
    final qtyStr = mutation.quantity % 1 == 0
        ? mutation.quantity.toInt().toString()
        : mutation.quantity.toStringAsFixed(1);
    final prevStr = mutation.previousStock % 1 == 0
        ? mutation.previousStock.toInt().toString()
        : mutation.previousStock.toStringAsFixed(1);
    final currStr = mutation.currentStock % 1 == 0
        ? mutation.currentStock.toInt().toString()
        : mutation.currentStock.toStringAsFixed(1);

    final color = isIn ? const Color(0xFF15803D) : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 13,
              color: color,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mutation.readableReason,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($prevStr -> $currStr)',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate + (mutation.notes != null && mutation.notes!.trim().isNotEmpty ? ' • ${mutation.notes}' : ''),
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIn ? "+" : "-"}$qtyStr $baseUnit',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
