import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_filter_menu_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/swipeable_card_item.dart';
import 'package:tokona/features/payment/presentation/controllers/paylater_settlement_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_bill_monitor_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class BerandaSwipeableCards extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const BerandaSwipeableCards({super.key, this.onNavigateTab});

  @override
  ConsumerState<BerandaSwipeableCards> createState() => _BerandaSwipeableCardsState();
}

class _BerandaSwipeableCardsState extends ConsumerState<BerandaSwipeableCards> {
  final PageController _pageController = PageController(viewportFraction: 0.98);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context, ReportFilterType currentFilter) {
    BerandaFilterMenuSheet.show(context, ref, currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final alerts = ref.watch(alertNotificationProvider);
    final totalBalance = ref.watch(totalStoreBalanceProvider);
    final saleState = ref.watch(saleHistoryControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final productState = ref.watch(productListProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final customerState = ref.watch(customerListProvider);
    final settlementState = ref.watch(paylaterSettlementProvider);

    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final kasbonSales = saleState.sales.where((s) => s.isKasbon && !s.isVoided).toList();
    final salesKasbonAmount = kasbonSales.fold(0.0, (acc, s) => acc + s.finalAmount);
    final customersKasbonAmount = customerState.customers.fold<double>(0.0, (acc, c) => acc + c.receivableBalance);
    final totalKasbonAmount = salesKasbonAmount > 0 ? salesKasbonAmount : customersKasbonAmount;

    // SPayLater data calculation
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final isPaylaterWindow = (now.day >= (lastDayOfMonth - 2)) || (now.day == 1);
    final isSettled = settlementState.isSettled(now.year, now.month);
    final paylaterPurchases = purchaseState.purchases.where((p) => p.isPaylater && !p.isCancelled).toList();
    final totalPaylaterBill = paylaterPurchases.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final paylaterTrend = paylaterPurchases.length >= 2
        ? paylaterPurchases.take(7).map((p) => p.grandTotal).toList().reversed.toList()
        : [0.0, 0.0];

    final txCount = reportState.summary.transactionCount;
    final avgBasket = txCount > 0 ? reportState.summary.totalRevenue / txCount : 0.0;

    // Data tren harian & riil
    final realSalesTrend = reportState.dailyTrends.map((d) => d.revenue).toList();
    final salesTrend = realSalesTrend.length >= 2
        ? realSalesTrend
        : (saleState.sales.length >= 2
            ? saleState.sales.take(7).map((s) => s.finalAmount).toList().reversed.toList()
            : [0.0, 0.0]);

    final kasbonTrend = kasbonSales.length >= 2
        ? kasbonSales.take(7).map((s) => s.finalAmount).toList().reversed.toList()
        : [0.0, 0.0];

    final accounts = ref.watch(paymentAccountListProvider);
    final List<double> balanceTrend = accounts.length >= 2
        ? accounts.map((a) => a.currentBalance).toList()
        : <double>[totalBalance * 0.4, totalBalance];

    final stockTrend = productState.products.length >= 2
        ? productState.products.take(8).map((p) => p.stockBase).toList()
        : [1.0, 1.0];

    final purchaseTrend = purchaseState.purchases.length >= 2
        ? purchaseState.purchases.take(7).map((p) => p.grandTotal).toList().reversed.toList()
        : [0.0, 0.0];

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
              SwipeableCardItem(
                gradient: const [Color(0xFF0D9488), Color(0xFF047857), Color(0xFF064E3B)],
                sparklineData: salesTrend,
                icon: Icons.trending_up_rounded,
                badgeText: reportState.selectedFilter.label.toUpperCase(),
                badgeBg: Colors.white.withValues(alpha: 0.22),
                hasLiveDot: reportState.selectedFilter == ReportFilterType.today,
                title: 'Penjualan Bersih (Omzet)',
                mainValue: currency.format(reportState.summary.totalRevenue),
                footerLeftLabel: 'Laba',
                footerLeftValue: currency.format(reportState.summary.grossProfit),
                footerRightLabel: 'Rerata',
                footerRightValue: currency.format(avgBasket),
                onTap: () => widget.onNavigateTab?.call(3),
                onBadgeTap: () => _showFilterMenu(context, reportState.selectedFilter),
              ),
              SwipeableCardItem(
                gradient: alerts.hasOverdueKasbon
                    ? const [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF7F1D1D)]
                    : (alerts.hasUrgentKasbon
                        ? const [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)]
                        : const [Color(0xFF4F46E5), Color(0xFF3730A3), Color(0xFF1E1B4B)]),
                sparklineData: kasbonTrend,
                icon: alerts.hasOverdueKasbon
                    ? Icons.warning_amber_rounded
                    : (alerts.hasUrgentKasbon ? Icons.event_busy_rounded : Icons.check_circle_outline_rounded),
                badgeText: alerts.hasOverdueKasbon
                    ? '${alerts.overdueKasbonCount} LEWAT TEMPO!'
                    : (alerts.hasUrgentKasbon ? '${alerts.totalUrgentKasbon} TEMPO DEKAT' : 'KASBON AMAN'),
                badgeBg: alerts.hasOverdueKasbon
                    ? const Color(0xFFFEE2E2).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
                title: 'Total Piutang Kasbon',
                mainValue: currency.format(totalKasbonAmount),
                footerLeftLabel: 'Nota',
                footerLeftValue: '${kasbonSales.length} Belum Lunas',
                footerRightLabel: '',
                footerRightValue: 'Buka Tempo',
                onTap: () => KasbonDueMonitorSheet.show(context),
              ),
              SwipeableCardItem(
                gradient: isSettled
                    ? const [Color(0xFF059669), Color(0xFF047857), Color(0xFF064E3B)]
                    : (isPaylaterWindow
                        ? const [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF7F1D1D)]
                        : const [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)]),
                sparklineData: paylaterTrend,
                icon: Icons.credit_card_rounded,
                badgeText: isSettled
                    ? 'LUNAS'
                    : (isPaylaterWindow ? 'TGL 01 JATUH TEMPO' : 'SPAYLATER AKTIF'),
                badgeBg: Colors.white.withValues(alpha: 0.2),
                title: 'Tagihan SPayLater',
                mainValue: currency.format(totalPaylaterBill),
                footerLeftLabel: 'Nota',
                footerLeftValue: '${paylaterPurchases.length} Kulakan',
                footerRightLabel: '',
                footerRightValue: 'Rincian & Bayar',
                onTap: () => PaylaterBillMonitorSheet.show(context),
              ),
              SwipeableCardItem(
                gradient: const [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
                sparklineData: balanceTrend,
                icon: Icons.account_balance_wallet_rounded,
                badgeText: 'KAS & BANK',
                badgeBg: Colors.white.withValues(alpha: 0.16),
                title: 'Total Saldo Keuangan',
                mainValue: currency.format(totalBalance),
                footerLeftLabel: 'Status',
                footerLeftValue: 'Kasir Aktif',
                footerRightLabel: '',
                footerRightValue: 'Kelola Saldo',
                onTap: () => PaymentAccountManagementSheet.show(context),
              ),
              SwipeableCardItem(
                gradient: alerts.hasUrgentStock
                    ? const [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF7C2D12)]
                    : const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
                sparklineData: stockTrend,
                icon: Icons.inventory_2_rounded,
                badgeText: alerts.hasUrgentStock ? '${alerts.totalUrgentStock} PERLU RESTOK' : 'STOK OPTIMAL',
                badgeBg: Colors.white.withValues(alpha: 0.2),
                title: 'Katalog Barang',
                mainValue: '${productState.products.length} Barang Terdaftar',
                footerLeftLabel: 'Menipis',
                footerLeftValue: '${alerts.lowStockCount} Item',
                footerRightLabel: 'Habis',
                footerRightValue: '${alerts.outOfStockCount} Item',
                onTap: () => widget.onNavigateTab?.call(1),
              ),
              SwipeableCardItem(
                gradient: const [Color(0xFF059669), Color(0xFF047857), Color(0xFF064E3B)],
                sparklineData: purchaseTrend,
                icon: Icons.shopping_cart_checkout_rounded,
                badgeText: reportState.selectedFilter.label.toUpperCase(),
                badgeBg: Colors.white.withValues(alpha: 0.2),
                hasLiveDot: reportState.selectedFilter == ReportFilterType.today,
                title: 'Total Pembelian',
                mainValue: currency.format(reportState.summary.totalPurchaseSpend),
                footerLeftLabel: 'Pengiriman',
                footerLeftValue: '${activeOrders.length} Pesanan',
                footerRightLabel: '',
                footerRightValue: 'Buka Riwayat',
                onTap: () => PurchaseHistorySheet.show(context),
                onBadgeTap: () => _showFilterMenu(context, reportState.selectedFilter),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
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
}
