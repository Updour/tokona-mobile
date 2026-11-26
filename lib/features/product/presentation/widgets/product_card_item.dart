import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_card_options_menu.dart';
import 'package:tokona/features/product/presentation/widgets/product_device_tags_row.dart';
import 'package:tokona/features/product/presentation/widgets/product_stock_badge.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';
import 'package:tokona/features/settings/domain/models/app_permission.dart';
import 'package:tokona/features/settings/presentation/controllers/rbac_controller.dart';

class ProductCardItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final rbac = ref.watch(rbacProvider.notifier);
    final canViewHpp = rbac.hasPermission(user, AppPermission.viewHppCost);
    final canManage = rbac.hasPermission(user, AppPermission.manageProducts);
    final canDelete = rbac.hasPermission(user, AppPermission.deleteProducts);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.055), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                      onAdjustStock: canManage ? onAdjustStock : null,
                      onStockCard: onStockCard,
                      onRestock: canManage ? onRestock : null,
                      onEdit: canManage ? onEdit : null,
                      onDelete: canDelete ? onDelete : null,
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
                              canViewHpp ? CurrencyFormatter.format(product.baseCostPrice) : '••••••',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: canViewHpp ? AppColors.textPrimary : AppColors.textMuted,
                              ),
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
                            canViewHpp ? '+${product.marginPercentage.toStringAsFixed(1)}%' : '••••',
                            style: AppTypography.bodySmall.copyWith(
                              color: canViewHpp ? AppColors.success : AppColors.textMuted,
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.units.length} Kemasan',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
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
