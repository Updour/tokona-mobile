import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class BerandaSwipeableCards extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const BerandaSwipeableCards({super.key, this.onNavigateTab});

  @override
  ConsumerState<BerandaSwipeableCards> createState() => _BerandaSwipeableCardsState();
}

class _BerandaSwipeableCardsState extends ConsumerState<BerandaSwipeableCards> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final alerts = ref.watch(alertNotificationProvider);
    final totalBalance = ref.watch(totalStoreBalanceProvider);
    final saleState = ref.watch(saleHistoryControllerProvider);
    final productState = ref.watch(productListProvider);

    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final kasbonSales = saleState.sales.where((s) => s.isKasbon && !s.isVoided);
    final totalKasbonAmount = kasbonSales.fold(0.0, (acc, s) => acc + s.finalAmount);

    final txCount = reportState.summary.transactionCount;
    final avgBasket = txCount > 0 ? reportState.summary.totalRevenue / txCount : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 184,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() => _currentPage = idx);
            },
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCardWrapper(
                gradient: const [Color(0xFF0F766E), Color(0xFF0D9488)],
                icon: Icons.trending_up_rounded,
                badgeText: 'HARI INI',
                badgeBg: Colors.white.withValues(alpha: 0.22),
                hasLiveDot: true,
                title: 'Penjualan Bersih Toko (Omzet)',
                mainValue: currency.format(reportState.summary.totalRevenue),
                footerLeftLabel: 'Laba',
                footerLeftValue: currency.format(reportState.summary.grossProfit),
                footerRightLabel: 'Rerata',
                footerRightValue: currency.format(avgBasket),
                onTap: () => widget.onNavigateTab?.call(3),
              ),
              _buildCardWrapper(
                gradient: alerts.hasOverdueKasbon
                    ? const [Color(0xFF991B1B), Color(0xFFDC2626)]
                    : (alerts.hasUrgentKasbon
                        ? const [Color(0xFFB45309), Color(0xFFD97706)]
                        : const [Color(0xFF312E81), Color(0xFF4338CA)]),
                icon: alerts.hasOverdueKasbon
                    ? Icons.warning_amber_rounded
                    : (alerts.hasUrgentKasbon ? Icons.event_busy_rounded : Icons.check_circle_outline_rounded),
                badgeText: alerts.hasOverdueKasbon
                    ? '${alerts.overdueKasbonCount} LEWAT TEMPO!'
                    : (alerts.hasUrgentKasbon ? '${alerts.totalUrgentKasbon} TEMPO DEKAT' : 'KASBON AMAN'),
                badgeBg: alerts.hasOverdueKasbon
                    ? const Color(0xFFFEE2E2).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
                title: 'Total Piutang Kasbon Pelanggan',
                mainValue: currency.format(totalKasbonAmount),
                footerLeftLabel: 'Nota',
                footerLeftValue: '${kasbonSales.length} Belum Lunas',
                footerRightLabel: '',
                footerRightValue: 'Buka Tempo >',
                onTap: () => KasbonDueMonitorSheet.show(context),
              ),
              _buildCardWrapper(
                gradient: const [Color(0xFF0F172A), Color(0xFF334155)],
                icon: Icons.account_balance_wallet_rounded,
                badgeText: 'KAS & BANK',
                badgeBg: Colors.white.withValues(alpha: 0.16),
                title: 'Total Saldo Keuangan Toko',
                mainValue: currency.format(totalBalance),
                footerLeftLabel: 'Status',
                footerLeftValue: 'Kasir Aktif',
                footerRightLabel: '',
                footerRightValue: 'Kelola Saldo >',
                onTap: () => PaymentAccountManagementSheet.show(context),
              ),
              _buildCardWrapper(
                gradient: alerts.hasUrgentStock
                    ? const [Color(0xFFC2410C), Color(0xFFEA580C)]
                    : const [Color(0xFF0369A1), Color(0xFF0284C7)],
                icon: Icons.inventory_2_rounded,
                badgeText: alerts.hasUrgentStock ? '${alerts.totalUrgentStock} PERLU RESTOK' : 'STOK OPTIMAL',
                badgeBg: Colors.white.withValues(alpha: 0.2),
                title: 'Katalog Barang & Gudang',
                mainValue: '${productState.products.length} Barang Terdaftar',
                footerLeftLabel: 'Menipis',
                footerLeftValue: '${alerts.lowStockCount} Item',
                footerRightLabel: 'Habis',
                footerRightValue: '${alerts.outOfStockCount} Item',
                onTap: () => widget.onNavigateTab?.call(1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCardWrapper({
    required List<Color> gradient,
    required IconData icon,
    required String badgeText,
    required Color badgeBg,
    bool hasLiveDot = false,
    required String title,
    required String mainValue,
    required String footerLeftLabel,
    required String footerLeftValue,
    required String footerRightLabel,
    required String footerRightValue,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: gradient.first.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasLiveDot) ...[
                            Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                            const SizedBox(width: 4),
                          ],
                          Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                        ],
                      ),
                    ),
                    Icon(icon, color: Colors.white.withValues(alpha: 0.88), size: 22),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        mainValue,
                        style: const TextStyle(color: Colors.white, fontSize: 20.5, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(9)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('$footerLeftLabel: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                            Flexible(
                              child: Text(
                                footerLeftValue,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (footerRightLabel.isNotEmpty)
                            Text('$footerRightLabel: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                          Text(footerRightValue, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
