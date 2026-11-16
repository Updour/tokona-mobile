import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/dashboard/presentation/widgets/purchase_chart_header.dart';
import 'package:tokona/features/dashboard/presentation/widgets/purchase_supplier_breakdown_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_chart_header.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_trend_chart_painter.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';

class DailyPurchaseTrendView extends StatefulWidget {
  final List<PurchaseModel> purchases;
  final ReportFilterType activeFilter;
  final ValueChanged<ReportFilterType> onFilterSelected;

  const DailyPurchaseTrendView({
    super.key,
    required this.purchases,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  State<DailyPurchaseTrendView> createState() => _DailyPurchaseTrendViewState();
}

class _DailyPurchaseTrendViewState extends State<DailyPurchaseTrendView> with TickerProviderStateMixin {
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

  List<PurchaseModel> _filterPurchases() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.purchases.where((p) {
      if (p.status == 'cancelled') return false;
      final d = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
      switch (widget.activeFilter) {
        case ReportFilterType.today:
          return d.isAtSameMomentAs(today);
        case ReportFilterType.yesterday:
          return d.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
        case ReportFilterType.last7Days:
          return d.isAfter(today.subtract(const Duration(days: 7))) && !d.isAfter(today);
        case ReportFilterType.thisMonth:
          return d.year == now.year && d.month == now.month;
        case ReportFilterType.lastMonth:
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          return d.year == prevMonth.year && d.month == prevMonth.month;
        case ReportFilterType.thisYear:
          return d.year == now.year;
        case ReportFilterType.custom:
          return true;
      }
    }).toList();
  }

  List<DailyTrendPoint> _buildDailyPoints(List<PurchaseModel> filtered) {
    if (filtered.isEmpty) return const [];
    final df = DateFormat('yyyy-MM-dd');
    final Map<String, double> aggregated = {};

    for (final p in filtered) {
      final key = df.format(p.createdAt);
      aggregated[key] = (aggregated[key] ?? 0.0) + p.grandTotal;
    }

    final sortedKeys = aggregated.keys.toList()..sort();
    return sortedKeys.map((key) {
      return DailyTrendPoint(
        dateString: key,
        revenue: aggregated[key] ?? 0.0,
        profit: 0.0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterPurchases();
    final totalSpend = filtered.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final trendPoints = _buildDailyPoints(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PurchaseChartHeader(
          totalSpend: totalSpend,
          activeFilter: widget.activeFilter,
          chartMode: _chartMode,
          pulseController: _pulseController,
          onChartModeChanged: (m) => setState(() => _chartMode = m),
          onFilterSelected: widget.onFilterSelected,
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty || totalSpend <= 0)
          _buildEmptyState()
        else if (_chartMode == ChartMode.pie)
          PurchaseSupplierBreakdownView(purchases: filtered, totalSpend: totalSpend)
        else
          _buildScrollableChart(trendPoints),
      ],
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
                      onTapDown: (d) => _handleTouch(d.localPosition.dx, slotW, trends.length),
                      onPanUpdate: (d) => _handleTouch(d.localPosition.dx, slotW, trends.length),
                      onPanEnd: (_) => setState(() => _selectedIndex = null),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_enterAnimation, _pulseController]),
                        builder: (ctx, _) => SizedBox(
                          height: 125,
                          width: chartW,
                          child: CustomPaint(
                            painter: SalesTrendChartPainter(
                              points: trends,
                              animationProgress: _enterAnimation.value,
                              pulseProgress: _pulseController.value,
                              selectedIndex: _selectedIndex,
                              isBarChart: _chartMode == ChartMode.bar,
                              primaryColor: const Color(0xFF2563EB),
                              secondaryColor: const Color(0xFF60A5FA),
                            ),
                          ),
                        ),
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
          Text(point.dateString, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(CurrencyFormatter.format(point.revenue), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
        ],
      ),
    );
  }

  Widget _buildLabelsRow(List<DailyTrendPoint> trends, int activeIndex, double slotW) {
    return Row(
      children: List.generate(trends.length, (i) {
        final p = trends[i];
        final isSelected = i == activeIndex;
        final label = p.dateString.length >= 5 ? p.dateString.substring(5) : p.dateString;
        return SizedBox(
          width: slotW,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? const Color(0xFF2563EB) : AppColors.textMuted,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 140,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          const Text('Belum ada pembelian pada periode ini', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
