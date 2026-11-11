import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/pos/data/services/whatsapp_reminder_service.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_bottom_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_booking_header.dart';

class ReminderBookingTile extends ConsumerWidget {
  final HeldCartModel order;
  final String storeName;
  final VoidCallback? onOrderRestored;

  const ReminderBookingTile({
    super.key,
    required this.order,
    required this.storeName,
    this.onOrderRestored,
  });

  Future<void> _handleScheduleDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initialDate = order.plannedDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Pilih Tanggal Pengambilan',
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(order.plannedDate ?? now),
      helpText: 'Pilih Jam Pengambilan',
    );

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? 12,
      pickedTime?.minute ?? 0,
    );

    ref.read(heldCartProvider.notifier).updatePlannedDate(order.id, combined);
    if (context.mounted) {
      AppToast.showSuccess(context, 'Jadwal diubah ke ${DateFormat("HH:mm").format(combined)}');
    }
  }

  Future<void> _handleSendWhatsApp(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final ok = await WhatsAppReminderService.sendReminder(
      ref: ref,
      order: order,
      storeName: storeName,
    );

    if (context.mounted) {
      if (ok) {
        AppToast.showSuccess(context, 'Pesan pengingat WA siap dikirim ke ${order.customerName}');
      } else {
        AppToast.showError(context, order.waLogMessage ?? 'Gagal mengirim pesan WA');
      }
    }
  }

  void _restoreToCart(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final restored = ref.read(heldCartProvider.notifier).restoreHeldCart(order.id);
    if (restored != null) {
      ref.read(cartProvider.notifier).restoreCart(
            items: restored.items,
            discountAmount: restored.discountAmount,
            customerName: restored.customerName,
          );
      onOrderRestored?.call();
      AppToast.showSuccess(context, 'Pesanan dimuat ke kasir POS');
      PosCartBottomSheet.show(context);
    }
  }

  void _showLogDetail(BuildContext context) {
    final timeStr = order.waSentAt != null
        ? DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(order.waSentAt!)
        : (order.plannedDate != null ? 'Dijadwalkan jam ${DateFormat("HH:mm").format(order.plannedDate!)}' : '-');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.history_rounded, color: Color(0xFF059669), size: 22),
            SizedBox(width: 8),
            Text('Log Pengiriman WA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Pelanggan', order.customerName ?? 'Pelanggan Umum'),
            const SizedBox(height: 6),
            _buildDialogRow('Nomor WA', order.customerPhone ?? '-'),
            const SizedBox(height: 6),
            _buildDialogRow('Status', order.waStatus),
            const SizedBox(height: 6),
            _buildDialogRow('Waktu Log', timeStr),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: Text(
                order.waLogMessage ?? 'Menunggu waktu pengiriman tiba',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        const Text(': ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isTimeArrived = order.plannedDate != null && now.isAfter(order.plannedDate!);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: order.isWaSent
              ? const Color(0xFFBBF7D0)
              : (order.isWaFailed ? const Color(0xFFFECACA) : AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReminderBookingHeader(order: order, isTimeArrived: isTimeArrived),
          const SizedBox(height: 10),
          _buildOrderSummary(),
          const SizedBox(height: 8),
          _buildLogBanner(context, isTimeArrived),
          const SizedBox(height: 10),
          _buildActionButtons(context, ref, isTimeArrived),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              order.items.isNotEmpty
                  ? '${order.totalItemCount} Item (${order.items.map((i) => i.product.name).take(2).join(", ")}${order.items.length > 2 ? "..." : ""})'
                  : (order.note ?? 'Pesanan Booking'),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(CurrencyFormatter.format(order.finalAmount), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
        ],
      ),
    );
  }

  Widget _buildLogBanner(BuildContext context, bool isTimeArrived) {
    final logText = order.waLogMessage ??
        (isTimeArrived ? 'Jadwal jam ${DateFormat("HH:mm").format(order.plannedDate!)} telah tiba, siap kirim.' : 'Menunggu jadwal jam ${order.plannedDate != null ? DateFormat("HH:mm").format(order.plannedDate!) : "-"}');

    return InkWell(
      onTap: () => _showLogDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: order.isWaSent ? const Color(0xFFDCFCE7) : (order.isWaFailed ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              order.isWaSent ? Icons.done_all_rounded : (order.isWaFailed ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
              size: 13,
              color: order.isWaSent ? const Color(0xFF16A34A) : (order.isWaFailed ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Log WA: $logText',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: order.isWaSent ? const Color(0xFF15803D) : (order.isWaFailed ? const Color(0xFFB91C1C) : const Color(0xFF475569)),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isTimeArrived) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleScheduleDate(context, ref),
            icon: const Icon(Icons.edit_calendar_rounded, size: 14),
            label: const Text('Atur Jam', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _handleSendWhatsApp(context, ref),
            icon: const Icon(Icons.chat_rounded, size: 14, color: Colors.white),
            label: Text(
              order.isWaSent ? 'Kirim Ulang' : 'Kirim WA',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: order.isWaSent ? const Color(0xFF0F766E) : const Color(0xFF059669),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => _restoreToCart(context, ref),
          tooltip: 'Buka ke Kasir POS',
          icon: const Icon(Icons.point_of_sale_rounded, size: 16, color: AppColors.primary),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(7),
          ),
        ),
      ],
    );
  }
}
