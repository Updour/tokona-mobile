import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_pie_chart_painter.dart';
import 'package:tokona/features/report/domain/models/top_product_model.dart';

class SalesPieChartView extends StatefulWidget {
  final List<TopProductModel> products;

  const SalesPieChartView({super.key, required this.products});

  @override
  State<SalesPieChartView> createState() => _SalesPieChartViewState();
}

class _SalesPieChartViewState extends State<SalesPieChartView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _anim;
  int? _selectedIndex;

  static const List<Color> _palette = [
    Color(0xFF0D9488),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF94A3B8),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant SalesPieChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<PieSliceData> _buildSlices() {
    if (widget.products.isEmpty) return const [];

    final double totalRevenue =
        widget.products.fold(0.0, (acc, p) => acc + p.revenue);
    if (totalRevenue <= 0) return const [];

    final top4 = widget.products.take(4).toList();
    final remainder = widget.products.skip(4);
    final remainderRevenue = remainder.fold(0.0, (acc, p) => acc + p.revenue);

    final List<PieSliceData> slices = [];

    for (int i = 0; i < top4.length; i++) {
      final p = top4[i];
      final pct = (p.revenue / totalRevenue) * 100.0;
      slices.add(
        PieSliceData(
          label: p.productName,
          value: p.revenue,
          percentage: pct,
          color: _palette[i % _palette.length],
        ),
      );
    }

    if (remainderRevenue > 0) {
      final pct = (remainderRevenue / totalRevenue) * 100.0;
      slices.add(
        PieSliceData(
          label: 'Lainnya',
          value: remainderRevenue,
          percentage: pct,
          color: _palette.last,
        ),
      );
    }

    return slices;
  }

  @override
  Widget build(BuildContext context) {
    final slices = _buildSlices();

    if (slices.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text(
          'Belum ada data distribusi produk pada periode ini',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          // Donut canvas
          SizedBox(
            width: 130,
            height: 130,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (ctx, _) {
                return CustomPaint(
                  painter: SalesPieChartPainter(
                    slices: slices,
                    animationProgress: _anim.value,
                    selectedIndex: _selectedIndex,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Legend list
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: slices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, idx) {
                final slice = slices[idx];
                final isSelected = _selectedIndex == idx;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedIndex = isSelected ? null : idx;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? slice.color.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: slice.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            slice.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${slice.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: slice.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

