import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';

class ProductQuickFilterBar extends StatelessWidget {
  final ProductFilterState filterState;
  final String? selectedCategory;
  final List<String> availableCategories;
  final ValueChanged<ProductStockFilter> onStockFilterChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onOpenFullFilter;

  const ProductQuickFilterBar({
    super.key,
    required this.filterState,
    required this.selectedCategory,
    required this.availableCategories,
    required this.onStockFilterChanged,
    required this.onCategoryChanged,
    required this.onOpenFullFilter,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = filterState.activeFilterCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ProductStockFilter.values.map((f) {
                    final isSelected = filterState.stockFilter == f;
                    Color activeColor = AppColors.primary;
                    if (f == ProductStockFilter.outOfStock) activeColor = AppColors.error;
                    if (f == ProductStockFilter.lowStock) activeColor = const Color(0xFFD97706);

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(f.label),
                        selected: isSelected,
                        onSelected: (_) => onStockFilterChanged(f),
                        selectedColor: activeColor.withValues(alpha: 0.15),
                        checkmarkColor: activeColor,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? activeColor : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? activeColor : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenFullFilter,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: activeCount > 0 ? AppColors.primaryContainer : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeCount > 0 ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 16,
                        color: activeCount > 0 ? AppColors.primary : AppColors.textSecondary,
                      ),
                      if (activeCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activeCount',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (availableCategories.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('Semua Kategori'),
                    selected: selectedCategory == null,
                    onSelected: (val) {
                      if (val) onCategoryChanged(null);
                    },
                    selectedColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: selectedCategory == null ? FontWeight.w700 : FontWeight.w500,
                      color: selectedCategory == null ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                ),
                ...availableCategories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        onCategoryChanged(val ? cat : null);
                      },
                      selectedColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

