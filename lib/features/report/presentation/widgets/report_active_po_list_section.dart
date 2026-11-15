import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_order_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/input_tracking_number_dialog.dart';

class ReportActivePoListSection extends ConsumerWidget {
  final String searchQuery;

  const ReportActivePoListSection({
    super.key,
    this.searchQuery = '',
  });

  Future<void> _handleConfirmArrival(BuildContext context, WidgetRef ref, PurchaseModel p) async {
    final ok = await AppDialog.showConfirmation(
      context,
      title: 'Konfirmasi Barang Diterima',
      message: 'Pesanan nota ${p.invoiceNumber} sudah tiba secara fisik di toko? Stok akan langsung ditambahkan.',
      confirmText: 'Ya, Terima Barang',
      icon: Icons.inventory_2_outlined,
    );
    if (ok == true && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        await ref.read(activeOrdersProvider.notifier).confirmReceived(p.id, sId);
        if (context.mounted) AppToast.showSuccess(context, 'Stok dari nota ${p.invoiceNumber} telah masuk inventaris');
      }
    }
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref, PurchaseModel p) async {
    final ok = await AppDialog.showConfirmation(
      context,
      title: 'Batalkan Pesanan Masuk?',
      message: 'Penjual membatalkan pesanan? Dana ${CurrencyFormatter.format(p.grandTotal)} dialihkan ke refund.',
      confirmText: 'Batalkan Pesanan',
      icon: Icons.cancel_outlined,
    );
    if (ok == true && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) await ref.read(activeOrdersProvider.notifier).cancelOrder(p.id, sId);
      if (context.mounted) AppToast.showWarning(context, 'Pesanan dibatalkan');
    }
  }

  Future<void> _handleMarkShipped(BuildContext context, WidgetRef ref, PurchaseModel p) async {
    final resi = await InputTrackingNumberDialog.show(
      context,
      currentResi: p.trackingNumber,
      invoiceNumber: p.invoiceNumber,
      supplierName: p.supplierName,
    );
    if (resi != null && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        final tracking = resi.trim().isNotEmpty ? resi.trim() : null;
        await ref.read(activeOrdersProvider.notifier).markAsShipped(p.id, sId, trackingNumber: tracking);
        if (context.mounted) {
          AppToast.showSuccess(
            context,
            tracking != null ? 'Pesanan dikirim • Resi: $tracking' : 'Status diubah ke Dalam Pengiriman',
          );
        }
      }
    }
  }

  Future<void> _handleEditTracking(BuildContext context, WidgetRef ref, PurchaseModel p) async {
    final resi = await InputTrackingNumberDialog.show(
      context,
      currentResi: p.trackingNumber,
      invoiceNumber: p.invoiceNumber,
      supplierName: p.supplierName,
      isUpdateOnly: true,
    );
    if (resi != null && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        await ref.read(activeOrdersProvider.notifier).updateTrackingNumber(p.id, sId, resi.trim());
        if (context.mounted) AppToast.showSuccess(context, 'No. resi berhasil diperbarui');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrders = ref.watch(activeOrdersProvider);

    final filtered = activeOrders.where((p) {
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchInv = p.invoiceNumber.toLowerCase().contains(q);
        final matchSup = p.supplierName?.toLowerCase().contains(q) ?? false;
        final matchResi = p.trackingNumber?.toLowerCase().contains(q) ?? false;
        final matchItem = p.items.any((i) => (i.productName ?? '').toLowerCase().contains(q));
        if (!matchInv && !matchSup && !matchResi && !matchItem) return false;
      }
      return true;
    }).toList();

    final totalOtw = filtered.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final totalPesanan = filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFFEA580C)),
                  const SizedBox(width: 6),
                  Text(
                    '$totalPesanan Pesanan Indent / OTW',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9A3412)),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(totalOtw),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF9A3412)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _buildEmptyState()
        else
          ...filtered.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: IncomingOrderCard(
                purchase: item,
                onConfirmArrival: () => _handleConfirmArrival(context, ref, item),
                onCancel: () => _handleCancel(context, ref, item),
                onMarkShipped: item.isPreOrder ? () => _handleMarkShipped(context, ref, item) : null,
                onEditTracking: item.isShipping ? () => _handleEditTracking(context, ref, item) : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Tidak Ada Pesanan PO / OTW', style: AppTypography.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Semua barang kulakan telah tiba dan masuk stok fisik gudang.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
