import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/calendar_service.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_bottom_sheet.dart';

class HeldOrdersBottomSheet extends ConsumerWidget {
  const HeldOrdersBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeldOrdersBottomSheet(),
    );
  }

  void _restoreOrder(BuildContext context, WidgetRef ref, HeldCartModel order) {
    final activeCart = ref.read(cartProvider);
    if (activeCart.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ganti Keranjang Aktif?'),
          content: Text(
            'Keranjang kasir saat ini memiliki ${activeCart.totalItemCount} barang. '
            'Melanjutkan pesanan ini akan menimpa keranjang aktif.',
            style: AppTypography.bodySmall,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _executeRestore(context, ref, order);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Timpa & Buka', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      _executeRestore(context, ref, order);
    }
  }

  void _executeRestore(BuildContext context, WidgetRef ref, HeldCartModel order) {
    final restored = ref.read(heldCartProvider.notifier).restoreHeldCart(order.id);
    if (restored != null) {
      ref.read(cartProvider.notifier).restoreCart(
            items: restored.items,
            discountAmount: restored.discountAmount,
            customerName: restored.customerName,
          );
      Navigator.of(context).pop();
      AppToast.showSuccess(context, 'Pesanan ${restored.customerName ?? 'pelanggan'} dimuat kembali');
      PosCartBottomSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldOrders = ref.watch(heldCartProvider);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 10),
          _buildHeader(context, heldOrders.length),
          const Divider(height: 20),
          if (heldOrders.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.separated(
                itemCount: heldOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = heldOrders[index];
                  return _buildOrderItemTile(context, ref, order, currency);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFFD97706).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pesanan Ditahan', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('$count pesanan stok diamankan', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: AppColors.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Text('Belum Ada Pesanan Ditahan', style: AppTypography.labelMedium),
          const SizedBox(height: 3),
          Text('Gunakan tombol Tahan di keranjang kasir untuk memarkir antrean / booking', style: AppTypography.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(BuildContext context, WidgetRef ref, HeldCartModel order, NumberFormat currency) {
    final isDelivery = order.deliveryMethod == 'delivery';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.customerName ?? 'Pelanggan Umum',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDelivery ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isDelivery ? Icons.two_wheeler_rounded : Icons.storefront_rounded, size: 11, color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF0F766E)),
                          const SizedBox(width: 3),
                          Text(
                            isDelivery ? 'Dianterin' : 'Diambil di Rumah/Toko',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: isDelivery ? const Color(0xFFB45309) : const Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (order.plannedDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_rounded, size: 12, color: Color(0xFFD97706)),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('d MMM', 'id_ID').format(order.plannedDate!),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(order.note!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.totalItemCount} jenis (${order.totalQuantity.toStringAsFixed(0)} pcs) • ${currency.format(order.finalAmount)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF059669), size: 18),
                      tooltip: 'Hubungi WA',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        final method = isDelivery ? 'diantar' : 'diambil di toko/rumah';
                        final msg = 'Halo Kak ${order.customerName ?? ""}, barang pesanannya di Tokona sudah siap $method ya!';
                        WhatsAppService.sendReceipt(phone: order.customerPhone!, message: msg);
                      },
                    ),
                  if (order.plannedDate != null)
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined, color: Color(0xFFD97706), size: 18),
                      tooltip: 'Simpan ke Kalender HP',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        CalendarService.addEventToCalendar(
                          title: 'Pesanan: ${order.customerName ?? "Pelanggan"} (${order.deliveryMethodLabel})',
                          description: 'Barang: ${order.items.map((i) => i.product.name).join(", ")}',
                          plannedDate: order.plannedDate!,
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                    tooltip: 'Hapus pesanan',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      ref.read(heldCartProvider.notifier).removeHeldCart(order.id);
                      AppToast.showSuccess(context, 'Pesanan booking dihapus');
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: () => _restoreOrder(context, ref, order),
                    icon: const Icon(Icons.play_arrow_rounded, size: 15),
                    label: const Text('Buka', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
