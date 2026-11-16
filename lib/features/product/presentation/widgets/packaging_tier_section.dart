import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_info_dialog.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_tier_form_card.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_unit_field_tile.dart';

class PackagingTierSection extends StatefulWidget {
  final List<CreateProductUnitDto> packagingUnits;
  final double baseCostPrice;
  final ValueChanged<CreateProductUnitDto> onAddUnit;
  final ValueChanged<int> onRemoveUnit;

  const PackagingTierSection({
    super.key,
    required this.packagingUnits,
    required this.baseCostPrice,
    required this.onAddUnit,
    required this.onRemoveUnit,
  });

  @override
  State<PackagingTierSection> createState() => _PackagingTierSectionState();
}

class _PackagingTierSectionState extends State<PackagingTierSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.packagingUnits.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.packagingUnits.length;

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
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Kemasan Bertingkat',
                              style: AppTypography.labelMedium.copyWith(fontSize: 13.5),
                            ),
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count Kemasan',
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          count > 0 ? '$count opsi kemasan aktif' : 'Jual eceran & dus/slop dalam 1 produk',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
                    tooltip: 'Panduan Kemasan',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => PackagingInfoDialog.show(context),
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
                  if (widget.packagingUnits.isNotEmpty) ...[
                    ...widget.packagingUnits.asMap().entries.map(
                          (entry) => PackagingUnitFieldTile(
                            index: entry.key,
                            unit: entry.value,
                            onRemove: () => widget.onRemoveUnit(entry.key),
                          ),
                        ),
                    const SizedBox(height: 12),
                  ],
                  PackagingTierFormCard(
                    baseCostPrice: widget.baseCostPrice,
                    onAddUnit: widget.onAddUnit,
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
