import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PurchaseChannelSelector extends StatelessWidget {
  final String purchaseType;
  final String platform;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onPlatformChanged;

  const PurchaseChannelSelector({
    super.key,
    required this.purchaseType,
    required this.platform,
    required this.onTypeChanged,
    required this.onPlatformChanged,
  });

  static const List<String> defaultPlatforms = [
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
              child: _buildChannelPill(
                label: 'Distributor Offline',
                isSelected: purchaseType == 'offline',
                onTap: () => onTypeChanged('offline'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChannelPill(
                label: 'Marketplace Online',
                isSelected: purchaseType == 'online',
                onTap: () => onTypeChanged('online'),
              ),
            ),
          ],
        ),
        if (purchaseType == 'online') ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: defaultPlatforms.map((p) {
                final isSel = platform == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      p,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: const Color(0xFFF97316),
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                    ),
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

  Widget _buildChannelPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
