import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';

class SalesChartFilterBar extends StatelessWidget {
  final ReportFilterType activeFilter;
  final bool isBarChart;
  final ValueChanged<ReportFilterType> onFilterChanged;
  final VoidCallback onToggleChartMode;

  const SalesChartFilterBar({
    super.key,
    required this.activeFilter,
    required this.isBarChart,
    required this.onFilterChanged,
    required this.onToggleChartMode,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      ReportFilterType.today,
      ReportFilterType.last7Days,
      ReportFilterType.thisMonth,
      ReportFilterType.thisYear,
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: () {
                      if (!isSelected) {
                        HapticFeedback.selectionClick();
                        onFilterChanged(f);
                      }
                    },
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F766E) : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: isSelected ? const Color(0xFF0F766E) : AppColors.border),
                      ),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggleChartMode();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isBarChart ? Icons.bar_chart_rounded : Icons.show_chart_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 3),
                Text(isBarChart ? 'Batang' : 'Garis', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

