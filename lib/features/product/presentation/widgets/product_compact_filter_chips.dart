import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';

class ProductCompactFilterChips extends StatelessWidget {
  final ProductFilterState filterState;
  final String? selectedCategory;
  final List<String> availableCategories;
  final ValueChanged<ProductStockFilter> onStockFilterChanged;
  final ValueChanged<String?> onCategoryChanged;

  const ProductCompactFilterChips({
    super.key,
    required this.filterState,
    required this.selectedCategory,
    required this.availableCategories,
    required this.onStockFilterChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStockChip(ProductStockFilter.all, 'Semua Stok'),
          const SizedBox(width: 6),
          _buildStockChip(ProductStockFilter.lowStock, 'Stok Menipis', color: const Color(0xFFD97706)),
          const SizedBox(width: 6),
          _buildStockChip(ProductStockFilter.outOfStock, 'Stok Habis', color: AppColors.error),
          if (availableCategories.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              width: 1,
              color: AppColors.border,
            ),
            ...availableCategories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) => onCategoryChanged(val ? cat : null),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStockChip(ProductStockFilter f, String label, {Color color = AppColors.primary}) {
    final isSelected = filterState.stockFilter == f;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onStockFilterChanged(f),
      selectedColor: color,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}

