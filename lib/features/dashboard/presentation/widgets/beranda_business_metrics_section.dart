import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/modern_animations.dart';
import 'package:tokona/features/dashboard/presentation/widgets/card_background_sparkline_painter.dart';
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
    final totalSalesCount = reportState.summary.transactionCount;

    final totalPurchaseSpend = reportState.summary.totalPurchaseSpend > 0
        ? reportState.summary.totalPurchaseSpend
        : purchaseState.purchases.where((p) => p.isReceived).fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final totalPurchaseCount = purchaseState.purchases.where((p) => p.isReceived).length;

    final poOrders = activeOrders.where((p) => p.isPreOrder).toList();
    final totalPoAmount = poOrders.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    final otwOrders = activeOrders.where((p) => p.isShipping).toList();
    final totalOtwAmount = otwOrders.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    final periodLabel = reportState.selectedFilter.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Toko',
              style: AppTypography.headingSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            InkWell(
              onTap: () => onNavigateTab?.call(3),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text('Lihat Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
                subtitle: '$totalSalesCount Transaksi ($periodLabel)',
                icon: Icons.receipt_long_rounded,
                gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                sparklineData: reportState.dailyTrends.length >= 2
                    ? reportState.dailyTrends.map((d) => d.revenue).toList()
                    : [12.0, 24.0, 18.0, 36.0, 48.0, 40.0, 60.0],
                badgeText: periodLabel.toUpperCase(),
                onTap: () => onNavigateTab?.call(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Pembelian',
                value: CurrencyFormatter.format(totalPurchaseSpend),
                subtitle: '$totalPurchaseCount Faktur Selesai',
                icon: Icons.shopping_bag_outlined,
                gradient: const [Color(0xFF0F766E), Color(0xFF115E59)],
                sparklineData: purchaseState.purchases.length >= 2
                    ? purchaseState.purchases.take(7).map((p) => p.grandTotal).toList().reversed.toList()
                    : [20.0, 15.0, 30.0, 25.0, 42.0, 50.0, 45.0],
                badgeText: periodLabel.toUpperCase(),
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
                gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                sparklineData: [10.0, 30.0, 22.0, 45.0, 38.0, 55.0, 65.0],
                badgeText: poOrders.isNotEmpty ? '${poOrders.length} PO' : null,
                onTap: () => IncomingOrdersSheet.show(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Pengiriman',
                value: CurrencyFormatter.format(totalOtwAmount),
                subtitle: '${otwOrders.length} Paket di Jalan',
                icon: Icons.local_shipping_outlined,
                gradient: const [Color(0xFFEA580C), Color(0xFFC2410C)],
                sparklineData: [35.0, 28.0, 42.0, 38.0, 50.0, 46.0, 62.0],
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
    required List<Color> gradient,
    required List<double> sparklineData,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: CardBackgroundSparklinePainter(
                    data: sparklineData,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(icon, size: 16, color: Colors.white),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          value,
                          key: ValueKey<String>(value),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
