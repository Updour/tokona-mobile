import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class SupplierTypeSelector extends StatelessWidget {
  final String selectedType;
  final String? selectedPlatform;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onPlatformChanged;

  const SupplierTypeSelector({
    super.key,
    required this.selectedType,
    required this.selectedPlatform,
    required this.onTypeChanged,
    required this.onPlatformChanged,
  });

  static const List<String> platforms = [
    'Shopee',
    'TikTok',
    'Tokopedia',
    'Lazada',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTypePill(
                label: 'Distributor Offline',
                icon: Icons.store_mall_directory_outlined,
                isSelected: selectedType == 'offline',
                onTap: () => onTypeChanged('offline'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTypePill(
                label: 'Marketplace Online',
                icon: Icons.shopping_bag_outlined,
                isSelected: selectedType == 'online',
                onTap: () => onTypeChanged('online'),
              ),
            ),
          ],
        ),
        if (selectedType == 'online') ...[
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: platforms.map((p) {
                final isSel = selectedPlatform == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) onPlatformChanged(p);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypePill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
