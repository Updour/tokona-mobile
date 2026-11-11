import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_hero_header.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_inventory_info_card.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_packaging_tile.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_price_tiers_section.dart';
import 'package:tokona/features/product/presentation/widgets/product_detail_pricing_card.dart';

class ProductDetailBottomSheet extends StatelessWidget {
  final ProductModel product;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductModel product,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailBottomSheet(
        product: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductDetailHeroHeader(product: product),
                    const SizedBox(height: 16),
                    ProductDetailPricingCard(product: product),
                    const SizedBox(height: 16),
                    ProductDetailInventoryInfoCard(product: product),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Satuan Kemasan Bertingkat', style: AppTypography.labelMedium.copyWith(fontSize: 14)),
                        if (product.units.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${product.units.length} Opsi',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (product.units.isEmpty)
                      _buildNoPackagingBanner()
                    else
                      ...product.units.map(
                        (u) => ProductDetailPackagingTile(
                          unit: u,
                          baseUnit: product.baseUnit,
                          stockBase: product.stockBase,
                        ),
                      ),
                    if (product.priceTiers.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ProductDetailPriceTiersSection(product: product),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPackagingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Barang ini hanya dijual dalam satuan dasar (${product.baseUnit}). Belum ada kemasan bertingkat.',
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
