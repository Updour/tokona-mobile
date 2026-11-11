import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';

enum ChartMode { line, bar, pie }

class SalesChartHeader extends StatelessWidget {
  final double totalRevenue;
  final ReportFilterType activeFilter;
  final ChartMode chartMode;
  final AnimationController pulseController;
  final ValueChanged<ChartMode> onChartModeChanged;
  final ValueChanged<ReportFilterType> onFilterSelected;

  const SalesChartHeader({
    super.key,
    required this.totalRevenue,
    required this.activeFilter,
    required this.chartMode,
    required this.pulseController,
    required this.onChartModeChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF0D9488)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.show_chart_rounded, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Tren Penjualan', style: AppTypography.headingSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 5),
                    _buildPulsingLiveBadge(),
                  ],
                ),
                Row(
                  children: [
                    Text(activeFilter.label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                    const SizedBox(width: 4),
                    Text('• ${CurrencyFormatter.format(totalRevenue)}', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChartModeSwitch(),
            const SizedBox(width: 2),
            _buildThreeDotsMenu(),
          ],
        ),
      ],
    );
  }

  Widget _buildPulsingLiveBadge() {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final glow = pulseController.value;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981),
            boxShadow: [
              BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4 + (0.5 * glow)), blurRadius: 4 + (4 * glow)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeBtn(Icons.show_chart_rounded, ChartMode.line),
          _modeBtn(Icons.bar_chart_rounded, ChartMode.bar),
          _modeBtn(Icons.pie_chart_outline_rounded, ChartMode.pie),
        ],
      ),
    );
  }

  Widget _modeBtn(IconData icon, ChartMode mode) {
    final isSelected = chartMode == mode;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onChartModeChanged(mode);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4.5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)] : null,
        ),
        child: Icon(icon, size: 15, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }

  Widget _buildThreeDotsMenu() {
    const filters = [
      ReportFilterType.today,
      ReportFilterType.last7Days,
      ReportFilterType.thisMonth,
      ReportFilterType.thisYear,
    ];

    return PopupMenuButton<ReportFilterType>(
      initialValue: activeFilter,
      icon: const Icon(Icons.more_vert_rounded, size: 19, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      tooltip: 'Pilih Periode',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onFilterSelected,
      itemBuilder: (context) {
        return filters.map((f) {
          final isSelected = activeFilter == f;
          return PopupMenuItem<ReportFilterType>(
            value: f,
            height: 38,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 15,
                  color: isSelected ? const Color(0xFF0F766E) : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0F766E) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

