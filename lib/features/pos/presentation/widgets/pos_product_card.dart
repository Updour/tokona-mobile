import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_product_image_header.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class PosProductCard extends StatefulWidget {
  final ProductModel product;
  final double inCartQty;
  final void Function(ProductModel product, ProductUnitModel? unit) onAddToCart;
  final void Function(ProductModel product, ProductUnitModel? unit) onDecrement;

  const PosProductCard({
    super.key,
    required this.product,
    required this.inCartQty,
    required this.onAddToCart,
    required this.onDecrement,
  });

  @override
  State<PosProductCard> createState() => _PosProductCardState();
}

class _PosProductCardState extends State<PosProductCard> {
  ProductUnitModel? _selectedUnit;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final p = widget.product;
    final isBase = _selectedUnit == null;
    final activePrice = isBase ? p.baseSellingPrice : _selectedUnit!.sellingPrice;
    final activeUnitName = isBase ? p.baseUnit : _selectedUnit!.unitName;
    final isOutOfStock = p.stockBase <= 0;
    final isInCart = widget.inCartQty > 0;

    return AnimatedScale(
      scale: _isPressed && !isOutOfStock ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: isOutOfStock ? null : (_) => setState(() => _isPressed = true),
          onTapUp: isOutOfStock
              ? null
              : (_) {
                  setState(() => _isPressed = false);
                  HapticFeedback.lightImpact();
                  widget.onAddToCart(p, _selectedUnit);
                },
          onTapCancel: isOutOfStock ? null : () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isInCart ? AppColors.primary : AppColors.border,
                width: isInCart ? 1.6 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isInCart
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isInCart ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Opacity(
              opacity: isOutOfStock ? 0.58 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PosProductImageHeader(
                      product: p,
                      inCartQty: widget.inCartQty,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.units.isNotEmpty) ...[
                          _buildUnitSelectorRow(p),
                          const SizedBox(height: 5),
                        ],
                        Text(
                          p.name,
                          style: AppTypography.labelMedium.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currency.format(activePrice),
                                    style: AppTypography.headingSmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'per $activeUnitName',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 9.5,
                                      color: AppColors.textMuted,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isInCart)
                              _buildStepper(p, isOutOfStock)
                            else
                              _buildAddIndicator(isOutOfStock),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelectorRow(ProductModel p) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildUnitPill(
            label: p.baseUnit,
            isSelected: _selectedUnit == null,
            onTap: () => setState(() => _selectedUnit = null),
          ),
          ...p.units.map((u) {
            return _buildUnitPill(
              label: u.unitName,
              isSelected: _selectedUnit?.id == u.id,
              onTap: () => setState(() => _selectedUnit = u),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUnitPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(ProductModel p, bool isOutOfStock) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onDecrement(p, _selectedUnit);
            },
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: const SizedBox(
              width: 25,
              height: 28,
              child: Icon(Icons.remove_rounded, size: 14, color: AppColors.primaryDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.inCartQty.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          InkWell(
            onTap: isOutOfStock
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    widget.onAddToCart(p, _selectedUnit);
                  },
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            child: const SizedBox(
              width: 25,
              height: 28,
              child: Icon(Icons.add_rounded, size: 14, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddIndicator(bool isOutOfStock) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isOutOfStock ? AppColors.border : AppColors.primary,
        borderRadius: BorderRadius.circular(9),
        boxShadow: isOutOfStock
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Icon(
        Icons.add_rounded,
        size: 18,
        color: isOutOfStock ? AppColors.textMuted : Colors.white,
      ),
    );
  }
}
