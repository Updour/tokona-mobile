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
    if (points.isEmpty) return const SizedBox.shrink();

    final maxVal = points.fold<double>(
      1.0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tren Omset & Laba', style: AppTypography.labelMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Row(
                children: [
                  _buildLegendIndicator(const Color(0xFF0D9488), 'Omset'),
                  const SizedBox(width: 8),
                  _buildLegendIndicator(const Color(0xFF10B981), 'Laba'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
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
                      padding: const EdgeInsets.symmetric(horizontal: 3),
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
                                        color: const Color(0xFF0D9488),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2.5),
                                Flexible(
                                  child: FractionallySizedBox(
                                    heightFactor: profitRatio,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            shortDate,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
