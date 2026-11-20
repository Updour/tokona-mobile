import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Piutang Kasbon', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(total), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Lewat Tempo', style: TextStyle(fontSize: 10.5, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                    if (overdueCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(5)),
                        child: Text('$overdueCount', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(overdue), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
