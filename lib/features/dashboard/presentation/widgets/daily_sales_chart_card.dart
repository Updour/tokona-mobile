import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_chart_header.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_pie_chart_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_trend_chart_painter.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class DailySalesChartCard extends ConsumerStatefulWidget {
  const DailySalesChartCard({super.key});

  @override
  ConsumerState<DailySalesChartCard> createState() => _DailySalesChartCardState();
}

class _DailySalesChartCardState extends ConsumerState<DailySalesChartCard> with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _pulseController;
  late final Animation<double> _enterAnimation;
  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex;
  ChartMode _chartMode = ChartMode.line;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _enterAnimation = CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFilterSelected(ReportFilterType filter) {
    final store = ref.read(authProvider).currentStore;
    if (store != null) {
      HapticFeedback.selectionClick();
      ref.read(reportControllerProvider.notifier).changeFilter(store.id, filter);
      _enterController.reset();
      _enterController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final trends = reportState.dailyTrends;
    final totalRevenue = trends.fold(0.0, (acc, t) => acc + t.revenue);
    final activeFilter = reportState.selectedFilter;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalesChartHeader(
            totalRevenue: totalRevenue,
            activeFilter: activeFilter,
            chartMode: _chartMode,
            pulseController: _pulseController,
            onChartModeChanged: (m) => setState(() => _chartMode = m),
            onFilterSelected: _onFilterSelected,
          ),
          const SizedBox(height: 12),
          if (_chartMode == ChartMode.pie)
            SalesPieChartView(products: reportState.topProducts)
          else if (trends.isEmpty || totalRevenue <= 0)
            _buildEmptyState()
          else
            _buildScrollableChart(trends),
        ],
      ),
    );
  }

  Widget _buildScrollableChart(List<DailyTrendPoint> trends) {
    final activeIndex = _selectedIndex ?? (trends.length - 1);
    final selectedPoint = (activeIndex >= 0 && activeIndex < trends.length) ? trends[activeIndex] : trends.last;

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotW = math.max(46.0, constraints.maxWidth / math.max(1, trends.length));
        final chartW = math.max(constraints.maxWidth, slotW * trends.length);

        return Column(
          children: [
            _buildTooltipPill(selectedPoint),
            const SizedBox(height: 8),
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: chartW,
                child: Column(
                  children: [
                    GestureDetector(
                      onTapDown: (details) => _handleTouch(details.localPosition.dx, slotW, trends.length),
                      onPanUpdate: (details) => _handleTouch(details.localPosition.dx, slotW, trends.length),
                      onPanEnd: (_) => setState(() => _selectedIndex = null),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_enterAnimation, _pulseController]),
                        builder: (ctx, _) {
                          return SizedBox(
                            height: 125,
                            width: chartW,
                            child: CustomPaint(
                              painter: SalesTrendChartPainter(
                                points: trends,
                                animationProgress: _enterAnimation.value,
                                pulseProgress: _pulseController.value,
                                selectedIndex: _selectedIndex,
                                isBarChart: _chartMode == ChartMode.bar,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildLabelsRow(trends, activeIndex, slotW),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleTouch(double localX, double slotW, int count) {
    if (count <= 0) return;
    final idx = (localX / slotW).floor().clamp(0, count - 1);
    if (_selectedIndex != idx) {
      HapticFeedback.selectionClick();
      setState(() => _selectedIndex = idx);
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 130,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text('Belum ada transaksi di periode ini', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
    );
  }

  Widget _buildTooltipPill(DailyTrendPoint point) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(point.dateString, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Text(CurrencyFormatter.format(point.revenue), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
          const SizedBox(width: 6),
          Text('Laba: ${CurrencyFormatter.format(point.profit)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
        ],
      ),
    );
  }

  Widget _buildLabelsRow(List<DailyTrendPoint> trends, int activeIndex, double slotW) {
    return Row(
      children: trends.asMap().entries.map((entry) {
        final isSelected = entry.key == activeIndex;
        final label = _extractShortDay(entry.value.dateString);
        return SizedBox(
          width: slotW,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0F766E) : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }

  String _extractShortDay(String raw) {
    final parts = raw.split('-');
    return parts.length == 3 ? '${parts[2]}/${parts[1]}' : raw;
  }
}
