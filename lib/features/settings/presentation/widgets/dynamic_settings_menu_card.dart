import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/settings/presentation/widgets/audit_log_sheet.dart';
import 'package:tokona/features/settings/presentation/widgets/dynamic_settings_sheet.dart';
import 'package:tokona/features/settings/presentation/widgets/rbac_management_sheet.dart';
import 'package:tokona/features/sync/presentation/widgets/sync_detail_bottom_sheet.dart';

class DynamicSettingsMenuCard extends StatelessWidget {
  const DynamicSettingsMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6), width: 0.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF334155), size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferensi Toko',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Pengingat, kurir, dan template pesan',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => DynamicSettingsSheet.show(context, initialTab: 0),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Buka',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(context, 'Log Audit', Icons.history_toggle_off_rounded, const Color(0xFFD97706), () => AuditLogSheet.show(context)),
                const SizedBox(width: 5),
                _buildChip(context, 'Izin RBAC', Icons.admin_panel_settings_rounded, const Color(0xFF0F766E), () => RbacManagementSheet.show(context)),
                const SizedBox(width: 5),
                _buildChip(context, 'Notif', Icons.notifications_active_rounded, const Color(0xFF0284C7), () => DynamicSettingsSheet.show(context, initialTab: 0)),
                const SizedBox(width: 5),
                _buildChip(context, 'J&T', Icons.local_shipping_rounded, const Color(0xFF0D9488), () => DynamicSettingsSheet.show(context, initialTab: 1)),
                const SizedBox(width: 5),
                _buildChip(context, 'Pesan WA', Icons.chat_rounded, const Color(0xFF4F46E5), () => DynamicSettingsSheet.show(context, initialTab: 2)),
                const SizedBox(width: 5),
                _buildChip(context, 'Sync Cloud', Icons.cloud_sync_rounded, const Color(0xFF16A34A), () => SyncDetailBottomSheet.show(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12.5, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
