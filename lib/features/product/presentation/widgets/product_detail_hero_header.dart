import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';

class ProductDetailHeroHeader extends StatelessWidget {
  final ProductModel product;

  const ProductDetailHeroHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductThumbnailAvatar(
          imagePath: product.imagePath,
          productName: product.name,
          size: 52,
          borderRadius: 14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppTypography.headingSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    (product.sku != null && product.sku!.isNotEmpty)
                        ? product.sku!
                        : 'Tanpa Barcode/SKU',
                    style: AppTypography.bodySmall.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (product.category != null && product.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      product.productType,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  if (product.expiredAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isExpired
                            ? AppColors.errorContainer
                            : (product.isExpiringSoon ? const Color(0xFFFEF3C7) : AppColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: product.isExpired
                              ? AppColors.error.withValues(alpha: 0.3)
                              : (product.isExpiringSoon ? const Color(0xFFD97706).withValues(alpha: 0.3) : AppColors.border),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 11,
                            color: product.isExpired
                                ? AppColors.error
                                : (product.isExpiringSoon ? const Color(0xFFB45309) : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isExpired
                                ? 'Kadaluarsa: ${_formatDate(product.expiredAt!)}'
                                : (product.isExpiringSoon
                                    ? 'Segera Exp: ${_formatDate(product.expiredAt!)}'
                                    : 'Exp: ${_formatDate(product.expiredAt!)}'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: product.isExpired
                                  ? AppColors.error
                                  : (product.isExpiringSoon ? const Color(0xFFB45309) : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLow ? AppColors.errorContainer : AppColors.successContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isLow ? AppColors.error : AppColors.success).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stockBase.toStringAsFixed(0)} ${product.baseUnit}',
                style: TextStyle(
                  color: isLow ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                isLow ? 'Stok Rendah' : 'Stok Aman',
                style: TextStyle(
                  color: isLow ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
