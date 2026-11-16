import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/domain/models/report_state.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';
import 'package:tokona/features/report/presentation/widgets/report_active_po_list_section.dart';
import 'package:tokona/features/report/presentation/widgets/report_export_bottom_sheet.dart';
import 'package:tokona/features/report/presentation/widgets/report_filter_sheet.dart';
import 'package:tokona/features/report/presentation/widgets/report_kpi_cards.dart';
import 'package:tokona/features/report/presentation/widgets/report_minimal_header.dart';
import 'package:tokona/features/report/presentation/widgets/report_profit_chart.dart';
import 'package:tokona/features/report/presentation/widgets/report_purchases_list_section.dart';
import 'package:tokona/features/report/presentation/widgets/report_sales_list_section.dart';
import 'package:tokona/features/report/presentation/widgets/report_segmented_nav.dart';
import 'package:tokona/features/report/presentation/widgets/report_top_products_list.dart';
import 'package:tokona/features/report/presentation/widgets/report_types_bottom_sheet.dart';

class LaporanTabView extends ConsumerStatefulWidget {
  const LaporanTabView({super.key});

  @override
  ConsumerState<LaporanTabView> createState() => _LaporanTabViewState();
}

class _LaporanTabViewState extends ConsumerState<LaporanTabView> {
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageController;
  bool _isSearching = false;
  String _searchQuery = '';
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _loadAllData() {
    final store = ref.read(authProvider).currentStore;
    if (store != null) {
      ref.read(reportControllerProvider.notifier).loadReport(store.id);
      ref.read(saleHistoryControllerProvider.notifier).loadSales(store.id);
      ref.read(purchaseControllerProvider.notifier).loadPurchases(store.id);
      ref.read(activeOrdersProvider.notifier).loadOrders(store.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final store = ref.read(authProvider).currentStore;
    if (store == null) return;

    final state = ref.read(reportControllerProvider);
    ReportFilterSheet.show(
      context,
      currentFilter: state.selectedFilter,
      currentStart: state.customStartDate,
      currentEnd: state.customEndDate,
      onApply: (filter, start, end) {
        ref.read(reportControllerProvider.notifier).changeFilter(
              store.id,
              filter,
              customStart: start,
              customEnd: end,
            );
      },
    );
  }

  void _handleTabSelected(int idx) {
    if (_currentTabIndex == idx) return;
    setState(() => _currentTabIndex = idx);
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final reportState = ref.watch(reportControllerProvider);
    final activeOrders = ref.watch(activeOrdersProvider);

    final filteredProducts = _searchQuery.trim().isEmpty
        ? reportState.topProducts
        : reportState.topProducts.where((p) {
            final q = _searchQuery.trim().toLowerCase();
            final nameMatch = p.productName.toLowerCase().contains(q);
            final catMatch = p.category != null && p.category!.toLowerCase().contains(q);
            return nameMatch || catMatch;
          }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        if (store != null) _loadAllData();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                ReportMinimalHeader(
                  activeFilterLabel: reportState.activeFilterLabel,
                  isFilterActive: reportState.selectedFilter != ReportFilterType.today,
                  isLoading: reportState.isLoading,
                  isSearching: _isSearching,
                  searchController: _searchController,
                  onSearchToggled: (val) => setState(() => _isSearching = val),
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onOpenFilter: _openFilterSheet,
                  onRefresh: () {
                    if (store != null) _loadAllData();
                  },
                  onOpenReportTypes: () => ReportTypesBottomSheet.show(context),
                  onOpenExport: () => ReportExportBottomSheet.show(context),
                ),
                const SizedBox(height: 10),
                ReportSegmentedNav(
                  currentIndex: _currentTabIndex,
                  onTabSelected: _handleTabSelected,
                  activePoCount: activeOrders.length,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) {
                if (_currentTabIndex != idx) {
                  setState(() => _currentTabIndex = idx);
                }
              },
              children: [
                _buildPageContainer(_buildSummaryTab(reportState, filteredProducts)),
                _buildPageContainer(ReportSalesListSection(
                  startDate: reportState.startDate,
                  endDate: reportState.endDate,
                  searchQuery: _searchQuery,
                )),
                _buildPageContainer(ReportPurchasesListSection(
                  startDate: reportState.startDate,
                  endDate: reportState.endDate,
                  searchQuery: _searchQuery,
                )),
                _buildPageContainer(ReportActivePoListSection(
                  searchQuery: _searchQuery,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContainer(Widget child) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      child: child,
    );
  }

  Widget _buildSummaryTab(ReportState reportState, List<dynamic> filteredProducts) {
    if (reportState.isLoading &&
        reportState.summary.transactionCount == 0 &&
        reportState.summary.totalRevenue == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (reportState.summary.transactionCount == 0 &&
        reportState.summary.totalPurchaseSpend == 0 &&
        reportState.summary.totalRevenue == 0) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportKpiCards(summary: reportState.summary),
        if (reportState.dailyTrends.isNotEmpty && _searchQuery.isEmpty) ...[
          const SizedBox(height: 16),
          ReportProfitChart(points: reportState.dailyTrends),
        ],
        const SizedBox(height: 16),
        ReportTopProductsList(items: filteredProducts.cast()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.bar_chart_rounded, size: 28, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Text('Belum Ada Transaksi Periode Ini', style: AppTypography.labelMedium),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Data omset, HPP, grafik tren laba kotor, dan produk terlaris akan otomatis terisi saat transaksi tercatat.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
