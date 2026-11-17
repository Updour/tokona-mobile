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
    if (item.targetPayload == 'incoming') IncomingOrdersSheet.show(context);
    if (item.targetPayload == 'paylater') PaylaterBillMonitorSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationListProvider);
    final readIds = ref.watch(readNotificationIdsProvider);
    final unreadCount = notifications.where((n) => !readIds.contains(n.id)).length;

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final isPaylaterWindowActive = (now.day >= (lastDayOfMonth - 2)) || (now.day == 1);

    final filteredList = notifications.where((n) {
      if (_selectedFilter == 'Kasbon') return n.targetPayload == 'kasbon';
      if (_selectedFilter == 'Paylater') return n.targetPayload == 'paylater';
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
                _buildFilterChip(
                  'Paylater',
                  notifications.where((n) => n.targetPayload == 'paylater').length,
                  isMuted: !isPaylaterWindowActive,
                ),
                const SizedBox(width: 6),
                _buildFilterChip('Stok', notifications.where((n) => n.targetPayload == 'stock').length),
                const SizedBox(width: 6),
                _buildFilterChip('Booking', notifications.where((n) => n.targetPayload == 'booking').length),
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
                separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
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

  Widget _buildFilterChip(String label, int count, {bool isMuted = false}) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = label);
        if (label == 'Paylater') {
          // Tetap bisa diklik langsung untuk membuka riwayat tagihan Paylater
          PaylaterBillMonitorSheet.show(context);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isMuted ? const Color(0xFF64748B) : AppColors.primary)
              : (isMuted ? const Color(0xFFF1F5F9) : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isMuted ? const Color(0xFF64748B) : AppColors.primary)
                : (isMuted ? const Color(0xFFCBD5E1) : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMuted) ...[
              const Icon(Icons.credit_card_outlined, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
            ],
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isMuted ? const Color(0xFF94A3B8) : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
