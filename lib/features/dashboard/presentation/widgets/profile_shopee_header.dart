import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_avatar_picker.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_settings_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';

class ProfileShopeeHeader extends ConsumerWidget {
  final StoreModel? store;
  final UserModel? user;

  const ProfileShopeeHeader({
    super.key,
    required this.store,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = user?.isOwner ?? false;
    final alerts = ref.watch(alertNotificationProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfileAvatarPicker(user: user, size: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user?.fullName ?? 'Pengguna',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: isOwner ? const Color(0xFFF59E0B) : AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                '@${user?.username ?? "user"} • ${store?.name ?? "Tokona Store"}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isOwner ? const Color(0xFFFEF3C7) : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOwner
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOwner ? Icons.workspace_premium_rounded : Icons.badge_outlined,
                      size: 11,
                      color: isOwner ? const Color(0xFFB45309) : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      user?.role.label ?? 'Pengguna',
                      style: TextStyle(
                        color: isOwner ? const Color(0xFF92400E) : AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: Icons.event_note_rounded,
              color: alerts.hasOverdueKasbon ? const Color(0xFFDC2626) : const Color(0xFFD97706),
              tooltip: 'Jatuh Tempo Kasbon',
              badgeCount: alerts.totalUrgentKasbon,
              isError: alerts.hasOverdueKasbon,
              onTap: () => KasbonDueMonitorSheet.show(context),
            ),
            const SizedBox(width: 6),
            _buildActionIcon(
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF4F46E5),
              tooltip: 'Riwayat Penjualan',
              onTap: () => SalesHistorySheet.show(context),
            ),
            const SizedBox(width: 6),
            _buildActionIcon(
              icon: Icons.settings_outlined,
              color: AppColors.textPrimary,
              tooltip: 'Pengaturan Sistem',
              onTap: () => ProfileSettingsSheet.show(context, store: store, user: user),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
    int badgeCount = 0,
    bool isError = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: color, size: 18),
            tooltip: tooltip,
            onPressed: onTap,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isError ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

