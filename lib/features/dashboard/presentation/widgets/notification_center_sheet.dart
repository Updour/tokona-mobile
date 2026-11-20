import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/notification_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/notification_item_tile.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_bill_monitor_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/settings/presentation/widgets/dynamic_settings_sheet.dart';

class NotificationCenterSheet extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const NotificationCenterSheet({super.key, this.onNavigateTab});

  static Future<void> show(BuildContext context, {ValueChanged<int>? onNavigateTab}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
    if (item.targetPayload == 'incoming') IncomingOrdersSheet.show(context);
    if (item.targetPayload == 'paylater') PaylaterBillMonitorSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationListProvider);
    final readIds = ref.watch(readNotificationIdsProvider);
    final prefs = ref.watch(appPreferencesProvider);
    final unreadCount = notifications.where((n) => !readIds.contains(n.id)).length;

    final filteredList = notifications.where((n) {
      if (_selectedFilter == 'Kasbon') return n.targetPayload == 'kasbon';
      if (_selectedFilter == 'Paylater') return n.targetPayload == 'paylater';
      if (_selectedFilter == 'Stok') return n.targetPayload == 'stock';
      if (_selectedFilter == 'Pengiriman') return n.targetPayload == 'incoming';
      if (_selectedFilter == 'Booking') return n.targetPayload == 'booking';
      return true;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 14),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, size: 18, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifikasi', style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 1),
                    Text(
                      unreadCount > 0 ? '$unreadCount pesan belum dibaca' : 'Semua sudah dibaca',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                    child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                  ),
                ),
              IconButton(
                onPressed: () => DynamicSettingsSheet.show(context, initialTab: 0),
                tooltip: 'Pengaturan',
                icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF64748B)),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 19, color: Color(0xFF64748B)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterTab('Semua', Icons.inbox_rounded, notifications.length),
                  ...[
                    ('Pengiriman', Icons.local_shipping_rounded, 'incoming'),
                    ('Paylater', Icons.credit_card_rounded, 'paylater'),
                    ('Kasbon', Icons.receipt_long_rounded, 'kasbon'),
                    ('Stok', Icons.inventory_2_rounded, 'stock'),
                    ('Booking', Icons.event_available_rounded, 'booking'),
                  ].where((t) {
                    if (!prefs.hideEmptyNotificationTabs) return true;
                    return _selectedFilter == t.$1 || notifications.any((n) => n.targetPayload == t.$3);
                  }).map(
                    (t) => _buildFilterTab(
                      t.$1,
                      t.$2,
                      notifications.where((n) => n.targetPayload == t.$3).length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (filteredList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline_rounded, size: 36, color: Color(0xFF16A34A)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Semua Beres & Aman', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 2),
                    const Text('Tidak ada pemberitahuan penting saat ini.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: filteredList.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => NotificationItemTile(
                  item: filteredList[i],
                  isRead: readIds.contains(filteredList[i].id),
                  onTap: () => _handleNotificationTap(filteredList[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, IconData icon, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedFilter = label),
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4.5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : const Color(0xFF64748B),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4.5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
