import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/domain/models/shortcut_menu_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/shortcut_controller.dart';
import 'package:tokona/features/dashboard/presentation/utils/shortcut_action_dispatcher.dart';

class AllMenusCategorySection extends ConsumerWidget {
  final String category;
  final List<ShortcutMenuItem> items;
  final List<String> pinnedIds;
  final bool isEditMode;
  final AlertNotificationState alerts;
  final int activeOrdersCount;
  final int heldOrdersCount;
  final ValueChanged<int>? onNavigateTab;

  const AllMenusCategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.pinnedIds,
    required this.isEditMode,
    required this.alerts,
    required this.activeOrdersCount,
    required this.heldOrdersCount,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildMenuItemTile(context, ref, items[i]),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 56, endIndent: 12, color: AppColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemTile(BuildContext context, WidgetRef ref, ShortcutMenuItem item) {
    final isPinned = pinnedIds.contains(item.id);
    int badge = 0;
    bool isErrorBadge = false;

    if (item.id == 'jadwal_wa') badge = heldOrdersCount;
    if (item.id == 'pesanan_masuk') badge = activeOrdersCount;
    if (item.id == 'jatuh_tempo') {
      badge = alerts.totalUrgentKasbon;
      isErrorBadge = alerts.hasOverdueKasbon;
    }
    if (item.id == 'katalog') {
      badge = alerts.totalUrgentStock;
      isErrorBadge = alerts.outOfStockCount > 0;
    }

    return ListTile(
      onTap: () {
        if (isEditMode) {
          HapticFeedback.selectionClick();
          ref.read(shortcutControllerProvider.notifier).togglePin(item.id);
        } else {
          Navigator.pop(context);
          ShortcutActionDispatcher.dispatch(context, ref, item.id, onNavigateTab: onNavigateTab);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: item.bgColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isErrorBadge ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
      subtitle: Text(
        item.description,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isEditMode
          ? Transform.scale(
              scale: 0.85,
              child: Switch(
                value: isPinned,
                activeColor: AppColors.primary,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  ref.read(shortcutControllerProvider.notifier).togglePin(item.id);
                },
              ),
            )
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
    );
  }
}

