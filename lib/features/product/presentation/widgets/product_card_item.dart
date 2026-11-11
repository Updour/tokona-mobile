import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_card_options_menu.dart';
import 'package:tokona/features/product/presentation/widgets/product_device_tags_row.dart';
import 'package:tokona/features/product/presentation/widgets/product_stock_badge.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';

class ProductCardItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjustStock;
  final VoidCallback? onStockCard;
  final VoidCallback? onRestock;
  final VoidCallback? onQuickAdjust;
  final VoidCallback? onTap;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onDelete,
    this.onEdit,
    this.onAdjustStock,
    this.onStockCard,
    this.onRestock,
    this.onQuickAdjust,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductThumbnailAvatar(
                      imagePath: product.imagePath,
                      productName: product.name,
                      size: 40,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              if (product.sku != null && product.sku!.isNotEmpty)
                                Text(
                                  product.sku!,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                                ),
                              if (product.sku != null && product.sku!.isNotEmpty && product.expiredAt != null)
                                const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              if (product.expiredAt != null)
                                Text(
                                  product.isExpired
                                      ? 'Kadaluarsa'
                                      : (product.isExpiringSoon ? 'Exp segera' : 'Exp ${_formatDate(product.expiredAt!)}'),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: product.isExpired || product.isExpiringSoon ? FontWeight.w700 : FontWeight.w500,
                                    color: product.isExpired
                                        ? AppColors.error
                                        : (product.isExpiringSoon ? const Color(0xFFD97706) : AppColors.textMuted),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ProductStockBadge(product: product),
                    const SizedBox(width: 4),
                    ProductCardOptionsMenu(
                      onAdjustStock: onAdjustStock,
                      onStockCard: onStockCard,
                      onRestock: onRestock,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                ProductDeviceTagsRow(product: product),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga Jual',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(product.baseSellingPrice),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HPP Modal',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(product.baseCostPrice),
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Margin', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '+${product.marginPercentage.toStringAsFixed(1)}%',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (product.units.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: product.units.map((unit) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${unit.unitName} (${unit.conversionFactor.toStringAsFixed(0)} ${product.baseUnit}) • ${CurrencyFormatter.format(unit.sellingPrice)}',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (product.priceTiers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: product.priceTiers.map((tier) {
                      final qtyText = tier.minQuantity.toStringAsFixed(tier.minQuantity.truncateToDouble() == tier.minQuantity ? 0 : 1);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                        ),
                        child: Text(
                          'Grosir ≥ $qtyText: ${CurrencyFormatter.format(tier.price)}',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
