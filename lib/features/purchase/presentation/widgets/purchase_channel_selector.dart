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
                icon: Icons.storefront_outlined,
                label: 'Offline',
                sublabel: 'Distributor',
                isSelected: purchaseType == 'offline',
                onTap: () => onTypeChanged('offline'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildChannelPill(
                icon: Icons.shopping_bag_outlined,
                label: 'Online',
                sublabel: 'Marketplace',
                isSelected: purchaseType == 'online',
                onTap: () => onTypeChanged('online'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildChannelPill(
                icon: Icons.handshake_outlined,
                label: 'Co-Order',
                sublabel: 'Mitra/Teman',
                isSelected: purchaseType == 'co_order',
                onTap: () => onTypeChanged('co_order'),
                isHighlight: true,
              ),
            ),
          ],
        ),
        if (purchaseType == 'online') ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
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
    required IconData icon,
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    final activeColor = isHighlight ? const Color(0xFFD97706) : AppColors.primary;
    final activeBg = isHighlight ? const Color(0xFFFEF3C7) : AppColors.primaryContainer;
    final activeBorder = isHighlight ? const Color(0xFFF59E0B) : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeBorder : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? activeColor : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? (isHighlight ? const Color(0xFF92400E) : AppColors.primaryDark) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: isSelected ? (isHighlight ? const Color(0xFFB45309) : AppColors.primary) : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
