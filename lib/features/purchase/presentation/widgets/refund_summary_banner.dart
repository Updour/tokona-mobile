import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class RefundSummaryBanner extends StatelessWidget {
  final String title;
  final double amount;
  final String countLabel;
  final bool isError;

  const RefundSummaryBanner({
    super.key,
    required this.title,
    required this.amount,
    required this.countLabel,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final bgColors = isError
        ? [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)]
        : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)];
    final borderColor = isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0);
    final titleColor = isError ? const Color(0xFF991B1B) : const Color(0xFF166534);
    final amountColor = isError ? const Color(0xFF7F1D1D) : const Color(0xFF14532D);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgColors),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 18,
                  color: amountColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              countLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isError ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
