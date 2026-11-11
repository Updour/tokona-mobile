import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';

class CustomFloatingBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFCCFBF1),
    ),
    _NavItemData(
      label: 'Produk',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      color: Color(0xFF6366F1),
      bgColor: Color(0xFFEEF2FF),
    ),
    _NavItemData(
      label: 'Kasir',
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    _NavItemData(
      label: 'Laporan',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    _NavItemData(
      label: 'Akun',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      color: Color(0xFFE11D48),
      bgColor: Color(0xFFFFE4E6),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertNotificationProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = currentIndex == index;

          bool hasBadge = false;
          if (index == 1 && alerts.hasUrgentStock) {
            hasBadge = true;
          } else if (index == 4 && alerts.hasUrgentKasbon) {
            hasBadge = true;
          }

          return _NavTabButton(
            item: item,
            isSelected: isSelected,
            hasBadge: hasBadge,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(index);
            },
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final Color bgColor;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.bgColor,
  });
}

class _NavTabButton extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.item,
    required this.isSelected,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? item.bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: AnimatedSlide(
                    offset: isSelected ? const Offset(0, -0.06) : Offset.zero,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? item.color : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
