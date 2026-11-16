import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class KasbonKpiSummaryCard extends StatelessWidget {
  final double total;
  final double overdue;
  final int overdueCount;

  const KasbonKpiSummaryCard({
    super.key,
    required this.total,
    required this.overdue,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Piutang Kasbon', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFFDE68A)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Lewat Tempo', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                    if (overdueCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                        child: Text('$overdueCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(overdue), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
