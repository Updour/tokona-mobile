import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';

class ReminderBookingHeader extends StatelessWidget {
  final HeldCartModel order;
  final bool isTimeArrived;

  const ReminderBookingHeader({
    super.key,
    required this.order,
    required this.isTimeArrived,
  });

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Belum Diatur';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari ini, ${DateFormat("HH:mm").format(dt)}';
    if (diff == 1) return 'Besok, ${DateFormat("HH:mm").format(dt)}';
    if (diff < 0) return 'Lewat ${-diff} hari lalu (${DateFormat("HH:mm").format(dt)})';
    return DateFormat('EEE, d MMM • HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = order.isDelivery;

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: isDelivery ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
          child: Text(
            (order.customerName?.isNotEmpty == true ? order.customerName![0] : 'P').toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF059669),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      order.customerName ?? 'Pelanggan',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isDelivery ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.deliveryMethodLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(order.plannedDate),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                  if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_rounded, size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          order.customerPhone!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        _buildWaStatusChip(),
      ],
    );
  }

  Widget _buildWaStatusChip() {
    if (order.isWaSent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
            const SizedBox(width: 4),
            Text(
              order.waSentAt != null ? 'Terkirim ${DateFormat("HH:mm").format(order.waSentAt!)}' : 'Terkirim',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
            ),
          ],
        ),
      );
    }

    if (order.isWaFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 12, color: Color(0xFFDC2626)),
            SizedBox(width: 4),
            Text('Gagal WA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
          ],
        ),
      );
    }

    if (isTimeArrived) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_rounded, size: 12, color: Color(0xFFD97706)),
            SizedBox(width: 4),
            Text('Waktunya Kirim', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Terjadwal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
    );
  }
}

