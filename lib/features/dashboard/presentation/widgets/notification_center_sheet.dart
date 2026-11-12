import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/in_app_notification_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/notification_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';

class NotificationCenterSheet extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const NotificationCenterSheet({super.key, this.onNavigateTab});

  static Future<void> show(BuildContext context, {ValueChanged<int>? onNavigateTab}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => NotificationCenterSheet(onNavigateTab: onNavigateTab),
    );
  }

  @override
  ConsumerState<NotificationCenterSheet> createState() => _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends ConsumerState<NotificationCenterSheet> {
  String _selectedFilter = 'Semua';

  void _handleNotificationTap(AppNotificationItem item) {
    ref.read(readNotificationIdsProvider.notifier).markAsRead(item.id);
    Navigator.of(context).pop();
    if (item.targetPayload == 'kasbon') KasbonDueMonitorSheet.show(context);
    if (item.targetPayload == 'stock') widget.onNavigateTab?.call(1);
    if (item.targetPayload == 'booking') ScheduledReminderSheet.show(context, initialTab: 0);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationListProvider);
    final readIds = ref.watch(readNotificationIdsProvider);
    final unreadCount = notifications.where((n) => !readIds.contains(n.id)).length;

    final filteredList = notifications.where((n) {
      if (_selectedFilter == 'Kasbon') return n.targetPayload == 'kasbon';
      if (_selectedFilter == 'Stok') return n.targetPayload == 'stock';
      if (_selectedFilter == 'Booking') return n.targetPayload == 'booking';
      return true;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pusat Notifikasi Toko', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      unreadCount > 0 ? '$unreadCount pesan belum dibaca' : 'Semua pesan sudah dibaca',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                InkWell(
                  onTap: () => ref.read(readNotificationIdsProvider.notifier).markAllAsRead(notifications.map((n) => n.id)),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', notifications.length),
                const SizedBox(width: 6),
                _buildFilterChip('Kasbon', notifications.where((n) => n.targetPayload == 'kasbon').length),
                const SizedBox(width: 6),
                _buildFilterChip('Stok', notifications.where((n) => n.targetPayload == 'stock').length),
                const SizedBox(width: 6),
                _buildFilterChip('Booking', notifications.where((n) => n.targetPayload == 'booking').length),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    if (notifications.isNotEmpty) {
                      InAppNotificationService.show(
                        context,
                        notifications.first,
                        onTap: () => _handleNotificationTap(notifications.first),
                      );
                    } else {
                      InAppNotificationService.show(
                        context,
                        AppNotificationItem(
                          id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Uji Coba Notifikasi Tokona',
                          body: 'Popup notifikasi muncul otomatis saat ada kasbon jatuh tempo atau stok menipis.',
                          type: AppNotificationType.generalInfo,
                          createdAt: DateTime.now(),
                          targetPayload: 'test',
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF6366F1)),
                        SizedBox(width: 4),
                        Text('Tes Popup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (filteredList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF16A34A)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Semua Beres & Aman', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Tidak ada pemberitahuan penting saat ini.', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _buildNotificationCard(filteredList[i], readIds.contains(filteredList[i].id)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotificationItem item, bool isRead) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNotificationTap(item),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead ? const Color(0xFFF8FAFC) : item.containerColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isRead ? const Color(0xFFE2E8F0) : item.accentColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: isRead ? AppColors.textMuted : item.accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(alpha: isRead ? 0.08 : 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isRead ? AppColors.textSecondary : item.accentColor),
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isRead ? const Color(0xFF64748B) : AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: TextStyle(fontSize: 11.5, color: isRead ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: isRead ? const Color(0xFFCBD5E1) : item.accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
