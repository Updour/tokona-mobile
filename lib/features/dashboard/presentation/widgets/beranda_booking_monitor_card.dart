import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/held_orders_bottom_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_bottom_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';

class BerandaBookingMonitorCard extends ConsumerWidget {
  const BerandaBookingMonitorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldOrders = ref.watch(heldCartProvider);
    final count = heldOrders.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, count),
          const SizedBox(height: 12),
          if (heldOrders.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: heldOrders.take(3).map((order) {
                return _buildBookingItem(context, ref, order);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_added_rounded, size: 17, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Jadwal Ambil & Booking',
                            style: AppTypography.headingSmall.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0369A1))),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Stok diamankan untuk pelanggan',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (count > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScheduledReminderSheet.show(context, initialTab: 0);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_send_rounded, size: 12, color: Color(0xFF059669)),
                      SizedBox(width: 3),
                      Text('Kirim WA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  HeldOrdersBottomSheet.show(context);
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text('Semua >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semua pesanan booking aman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('Tahan antrean di kasir untuk mengamankan stok', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, WidgetRef ref, HeldCartModel order) {
    final isDelivery = order.isDelivery;
    final dateStr = order.plannedDate != null ? DateFormat('d MMM', 'id_ID').format(order.plannedDate!) : 'Tanpa Tgl';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDelivery ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isDelivery ? Icons.two_wheeler_rounded : Icons.storefront_rounded,
              size: 18,
              color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.customerName ?? 'Pelanggan Umum',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDelivery ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDelivery ? 'Dianterin' : 'Ambil',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF0F766E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '📅 $dateStr • ${order.totalItemCount} item • ${CurrencyFormatter.format(order.finalAmount)}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17, color: Color(0xFF059669)),
                  tooltip: 'Chat WA',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  onPressed: () {
                    final method = isDelivery ? 'diantar' : 'diambil di toko/rumah';
                    final msg = 'Halo Kak ${order.customerName ?? ""}, pesanan di Tokona sudah siap $method ya!';
                    WhatsAppService.sendReceipt(phone: order.customerPhone!, message: msg);
                  },
                ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final restored = ref.read(heldCartProvider.notifier).restoreHeldCart(order.id);
                  if (restored != null) {
                    ref.read(cartProvider.notifier).restoreCart(items: restored.items, discountAmount: restored.discountAmount, customerName: restored.customerName);
                    PosCartBottomSheet.show(context);
                  }
                },
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(7)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 2),
                    Text('Buka', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

