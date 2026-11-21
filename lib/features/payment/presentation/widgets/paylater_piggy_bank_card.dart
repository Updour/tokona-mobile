import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PaylaterPiggyBankCard extends StatelessWidget {
  final double totalBill;
  final int dueDay;

  const PaylaterPiggyBankCard({
    super.key,
    required this.totalBill,
    required this.dueDay,
  });

  @override
  Widget build(BuildContext context) {
    if (totalBill <= 0) return const SizedBox.shrink();

    final now = DateTime.now();
    int daysLeft = dueDay - now.day;
    if (daysLeft <= 0) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      daysLeft = (daysInMonth - now.day) + dueDay;
    }
    if (daysLeft <= 0) daysLeft = 1;

    final dailyTarget = totalBill / daysLeft;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.savings_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alokasi Celengan Harian PayLater',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sisa $daysLeft Hari',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    children: [
                      const TextSpan(text: 'Saran sisihkan dari kasir: '),
                      TextSpan(
                        text: '${CurrencyFormatter.format(dailyTarget)} / hari',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                      ),
                      TextSpan(text: ' untuk jatuh tempo tgl $dueDay.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
