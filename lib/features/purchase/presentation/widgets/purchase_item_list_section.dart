import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/widgets/edit_purchase_item_dialog.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_item_tile.dart';

class PurchaseItemListSection extends StatelessWidget {
  final List<CreatePurchaseItemDto> items;
  final void Function(int index, CreatePurchaseItemDto updated) onEditItem;
  final void Function(int index) onRemoveItem;

  const PurchaseItemListSection({
    super.key,
    required this.items,
    required this.onEditItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final totalAmount = items.fold(0.0, (acc, item) => acc + item.subtotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'Daftar Belanja',
                  style: AppTypography.labelMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${items.length} Item',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              CurrencyFormatter.format(totalAmount),
              style: AppTypography.labelMedium.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.asMap().entries.map(
              (entry) => PurchaseItemTile(
                index: entry.key,
                item: entry.value,
                onEdit: () async {
                  final updated = await EditPurchaseItemDialog.show(
                    context,
                    item: entry.value,
                  );
                  if (updated != null) {
                    onEditItem(entry.key, updated);
                  }
                },
                onRemove: () => onRemoveItem(entry.key),
              ),
            ),
      ],
    );
  }
}
