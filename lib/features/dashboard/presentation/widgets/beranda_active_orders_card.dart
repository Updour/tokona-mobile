import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';

class BerandaActiveOrdersCard extends ConsumerWidget {
  const BerandaActiveOrdersCard({super.key});

  Future<void> _handleConfirmArrival(BuildContext context, WidgetRef ref, PurchaseModel p) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Konfirmasi Barang Tiba',
      message: 'Apakah paket fisik untuk nota ${p.invoiceNumber} sudah tiba di toko dan dicek? Stok barang akan otomatis bertambah.',
      confirmText: 'Ya, Terima Barang',
      icon: Icons.inventory_2_outlined,
    );
    if (confirmed == true && context.mounted) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        await ref.read(activeOrdersProvider.notifier).confirmReceived(p.id, storeId);
      }
      if (context.mounted) {
        AppToast.showSuccess(context, 'Stok barang berhasil ditambahkan ke inventaris');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrders = ref.watch(activeOrdersProvider);
    final count = activeOrders.length;

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
          if (activeOrders.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: activeOrders.take(3).map((order) {
                return _buildOrderItem(context, ref, order);
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
                  gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_rounded, size: 17, color: Colors.white),
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
                            'Pesanan Berjalan',
                            style: AppTypography.headingSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Text(
                              '$count Berjalan',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text('PO dan pengiriman supplier toko', style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (count > 0)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              IncomingOrdersSheet.show(context);
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Text('Lihat Semua', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Semua pesanan kulakan telah diterima (stok aman).',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, WidgetRef ref, PurchaseModel p) {
    final isPo = p.isPreOrder;
    final badgeColor = isPo ? const Color(0xFFD97706) : AppColors.primary;
    final badgeBg = isPo ? const Color(0xFFFEF3C7) : AppColors.primaryContainer;
    final statusLabel = isPo ? 'PO ${p.poDays ?? 3} Hari' : 'Dalam Kirim';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.supplierName != null && p.supplierName!.isNotEmpty ? p.supplierName! : p.invoiceNumber,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CurrencyFormatter.format(p.grandTotal),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(5)),
                  child: Text(statusLabel, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: badgeColor)),
                ),
                if (p.deviceTag != null && p.deviceTag!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: AppColors.border)),
                    child: Text('📱 ${p.deviceTag!}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
                  ),
                ],
                if (p.platform != null && p.platform!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(5)),
                    child: Text(p.platform!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF6D28D9))),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  p.items.isNotEmpty ? p.items.map((i) => '${i.quantity.toStringAsFixed(0)} ${i.unitName}').join(', ') : 'No: ${p.invoiceNumber}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _handleConfirmArrival(context, ref, p),
                icon: const Icon(Icons.check_rounded, size: 14),
                label: const Text('Terima Barang', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

