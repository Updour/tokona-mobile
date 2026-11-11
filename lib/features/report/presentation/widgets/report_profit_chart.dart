import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';

class ReportProfitChart extends StatelessWidget {
  final List<DailyTrendPoint> points;

  const ReportProfitChart({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = points.fold<double>(
      1.0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grafik Tren Harian', style: AppTypography.labelMedium.copyWith(fontSize: 14)),
              Row(
                children: [
                  _buildLegendIndicator(AppColors.primary, 'Omset'),
                  const SizedBox(width: 10),
                  _buildLegendIndicator(const Color(0xFF10B981), 'Laba'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final revRatio = (p.revenue / maxVal).clamp(0.06, 1.0);
                final profitRatio = (p.profit / maxVal).clamp(0.04, 1.0);
                final shortDate = p.dateString.length >= 10
                    ? '${p.dateString.substring(8, 10)}/${p.dateString.substring(5, 7)}'
                    : p.dateString;

                return Expanded(
                  child: Tooltip(
                    message: '${p.dateString}\nOmset: ${CurrencyFormatter.format(p.revenue)}\nLaba: ${CurrencyFormatter.format(p.profit)}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FractionallySizedBox(
                                    heightFactor: revRatio,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: FractionallySizedBox(
                                    heightFactor: profitRatio,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            shortDate,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
