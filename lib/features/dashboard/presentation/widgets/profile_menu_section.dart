import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_menu_builder.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_menu_data.dart';

class ProfileMenuSection extends ConsumerWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertNotificationProvider);
    final groups = buildProfileMenuGroups(context, alerts);

    return Column(
      children: groups.map((g) => _buildGroup(context, g)).toList(),
    );
  }

  Widget _buildGroup(BuildContext context, ProfileMenuGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: group.initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            childrenPadding: const EdgeInsets.only(bottom: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: group.iconBg, borderRadius: BorderRadius.circular(11)),
              child: Icon(group.icon, color: group.iconColor, size: 19),
            ),
            title: Text(
              group.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
              ...group.items.asMap().entries.map((entry) {
                return _buildTile(context, entry.value, entry.key == group.items.length - 1);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, ProfileMenuItem item, bool isLast) {
    return Column(
      children: [
        ListTile(
          onTap: item.onTap,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.color, size: 17),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.badgeText != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.badgeColor ?? AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badgeText!,
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
        ),
        if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16, color: AppColors.border),
      ],
    );
  }
}
