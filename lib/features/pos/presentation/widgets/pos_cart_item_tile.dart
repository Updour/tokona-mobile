import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class PosCartItemTile extends StatelessWidget {
  final int index;
  final CartItemModel item;
  final ValueChanged<double> onUpdateQty;
  final ValueChanged<ProductUnitModel?> onChangeUnit;
  final VoidCallback onRemove;

  const PosCartItemTile({
    super.key,
    required this.index,
    required this.item,
    required this.onUpdateQty,
    required this.onChangeUnit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final p = item.product;
    final hasEnoughStock = item.hasEnoughStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasEnoughStock ? AppColors.border : AppColors.error,
          width: hasEnoughStock ? 1.0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: AppTypography.labelMedium.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.format(item.unitPrice)} / ${item.unitName}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (p.units.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildUnitSwitcher(p),
          ],
          if (!hasEnoughStock) ...[
            const SizedBox(height: 6),
            Text(
              'Stok kurang (sisa ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit})',
              style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQtyStepper(),
              Text(
                currency.format(item.subtotal),
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            icon: Icons.remove,
            onTap: () => onUpdateQty(item.quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.quantity.toStringAsFixed(0),
              style: AppTypography.labelMedium.copyWith(fontSize: 13),
            ),
          ),
          _stepperButton(
            icon: Icons.add,
            onTap: () => onUpdateQty(item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildUnitSwitcher(dynamic p) {
    return Wrap(
      spacing: 6,
      children: [
        _unitChip(
          label: p.baseUnit,
          isSelected: item.selectedUnit == null,
          onTap: () => onChangeUnit(null),
        ),
        ...item.product.units.map(
          (u) => _unitChip(
            label: u.unitName,
            isSelected: item.selectedUnit?.id == u.id,
            onTap: () => onChangeUnit(u),
          ),
        ),
      ],
    );
  }

  Widget _unitChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
