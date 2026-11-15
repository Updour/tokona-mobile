import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class BerandaBusinessMetricsSection extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const BerandaBusinessMetricsSection({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportControllerProvider);
    final saleState = ref.watch(saleHistoryControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final activeOrders = ref.watch(activeOrdersProvider);

    final totalOmzet = reportState.summary.totalRevenue;
    final totalSalesCount = saleState.sales.where((s) => !s.isVoided).length;

    final completedPurchases = purchaseState.purchases.where((p) => p.isReceived);
    final totalPurchaseSpend = completedPurchases.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final totalPurchaseCount = completedPurchases.length;

    final poOrders = activeOrders.where((p) => p.isPreOrder).toList();
    final totalPoAmount = poOrders.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    final otwOrders = activeOrders.where((p) => p.isShipping).toList();
    final totalOtwAmount = otwOrders.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas & Performa Toko',
              style: AppTypography.headingSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            InkWell(
              onTap: () => onNavigateTab?.call(3),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text('Buka Laporan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Penjualan',
                value: CurrencyFormatter.format(totalOmzet),
                subtitle: '$totalSalesCount Nota Kasir',
                icon: Icons.receipt_long_rounded,
                accentColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => onNavigateTab?.call(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Pembelian (Kulak)',
                value: CurrencyFormatter.format(totalPurchaseSpend),
                subtitle: '$totalPurchaseCount Faktur Selesai',
                icon: Icons.shopping_bag_outlined,
                accentColor: const Color(0xFF0F766E),
                bgColor: const Color(0xFFF0FDFA),
                onTap: () => PurchaseHistorySheet.show(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Pre-Order (PO)',
                value: CurrencyFormatter.format(totalPoAmount),
                subtitle: '${poOrders.length} Pesanan Indent',
                icon: Icons.hourglass_top_rounded,
                accentColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                badgeText: poOrders.isNotEmpty ? '${poOrders.length} PO' : null,
                onTap: () => IncomingOrdersSheet.show(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Dalam Kirim (OTW)',
                value: CurrencyFormatter.format(totalOtwAmount),
                subtitle: '${otwOrders.length} Paket di Jalan',
                icon: Icons.local_shipping_outlined,
                accentColor: const Color(0xFFEA580C),
                bgColor: const Color(0xFFFFF7ED),
                badgeText: otwOrders.isNotEmpty ? '${otwOrders.length} OTW' : null,
                onTap: () => IncomingOrdersSheet.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: accentColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
