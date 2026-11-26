import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/daily_purchase_trend_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/daily_sales_trend_view.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class DailySalesChartCard extends ConsumerStatefulWidget {
  const DailySalesChartCard({super.key});

  @override
  ConsumerState<DailySalesChartCard> createState() => _DailySalesChartCardState();
}

class _DailySalesChartCardState extends ConsumerState<DailySalesChartCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFilterSelected(ReportFilterType filter) {
    final store = ref.read(authProvider).currentStore;
    if (store != null) {
      HapticFeedback.selectionClick();
      ref.read(reportControllerProvider.notifier).changeFilter(store.id, filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.055), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabPill('Penjualan', 0, const Color(0xFF0F766E)),
              const SizedBox(width: 8),
              _buildTabPill('Pembelian', 1, const Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _currentPage == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: DailySalesTrendView(
              reportState: reportState,
              onFilterSelected: _onFilterSelected,
            ),
            secondChild: DailyPurchaseTrendView(
              purchases: purchaseState.purchases,
              activeFilter: reportState.selectedFilter,
              onFilterSelected: _onFilterSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, int page, Color activeColor) {
    final isSelected = _currentPage == page;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentPage = page);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? activeColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
