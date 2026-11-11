import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class CustomerFilterChipBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CustomerFilterChipBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('all', 'Semua'),
          _buildChip('kasbon', 'Ada Kasbon', isAlert: true),
          _buildChip('member', 'Member'),
          _buildChip('grosir', 'Grosir'),
          _buildChip('umum', 'Umum'),
        ],
      ),
    );
  }

  Widget _buildChip(String key, String label, {bool isAlert = false}) {
    final isSelected = selectedFilter == key;

    final selectedColor = isAlert ? AppColors.error : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(key),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : (isAlert ? AppColors.error : AppColors.textSecondary),
        ),
        selectedColor: selectedColor,
        backgroundColor: isAlert ? const Color(0xFFFEF2F2) : AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? selectedColor : (isAlert ? const Color(0xFFFCA5A5) : AppColors.border)),
        ),
        visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
