import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_field_tile.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_form_card.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_info_dialog.dart';

class PriceTierSection extends StatefulWidget {
  final List<CreateProductPriceTierDto> priceTiers;
  final String baseUnit;
  final double baseCostPrice;
  final double baseSellingPrice;
  final ValueChanged<CreateProductPriceTierDto> onAddTier;
  final ValueChanged<int> onRemoveTier;

  const PriceTierSection({
    super.key,
    required this.priceTiers,
    required this.baseUnit,
    required this.baseCostPrice,
    required this.baseSellingPrice,
    required this.onAddTier,
    required this.onRemoveTier,
  });

  @override
  State<PriceTierSection> createState() => _PriceTierSectionState();
}

class _PriceTierSectionState extends State<PriceTierSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.priceTiers.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.priceTiers.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.price_change_outlined,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Harga Grosir / Kuantitas', style: AppTypography.labelMedium),
                            if (count > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count Tingkat',
                                  style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          count > 0 ? '$count level diskon grosir' : 'Diskon otomatis saat beli banyak',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: AppColors.secondary, size: 20),
                    tooltip: 'Panduan Harga Grosir',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => PriceTierInfoDialog.show(context),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.priceTiers.isNotEmpty) ...[
                    ...widget.priceTiers.asMap().entries.map(
                          (entry) => PriceTierFieldTile(
                            index: entry.key,
                            tier: entry.value,
                            baseUnit: widget.baseUnit,
                            baseSellingPrice: widget.baseSellingPrice,
                            onRemove: () => widget.onRemoveTier(entry.key),
                          ),
                        ),
                    const SizedBox(height: 12),
                  ],
                  PriceTierFormCard(
                    baseUnit: widget.baseUnit,
                    baseCostPrice: widget.baseCostPrice,
                    baseSellingPrice: widget.baseSellingPrice,
                    onAddTier: widget.onAddTier,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
