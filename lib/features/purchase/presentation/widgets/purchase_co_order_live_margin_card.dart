import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseCoOrderLiveMarginCard extends StatelessWidget {
  final double coProfit;
  final double coMarginPercent;
  final double coTotalCost;
  final double coTotalReceived;
  final String platform;

  const PurchaseCoOrderLiveMarginCard({
    super.key,
    required this.coProfit,
    required this.coMarginPercent,
    required this.coTotalCost,
    required this.coTotalReceived,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    final isProfitable = coProfit >= 0;
    final primaryColor = isProfitable ? const Color(0xFF16A34A) : AppColors.error;
    final bgColor = isProfitable ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final borderColor = isProfitable ? const Color(0xFFBBF7D0) : const Color(0xFFFCA5A5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Uang Diterima dari Rekan:',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(coTotalReceived),
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modal Belanja ($platform):',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '- ${CurrencyFormatter.format(coTotalCost)}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 1, color: Color(0xFFCBD5E1)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isProfitable ? Icons.monetization_on_rounded : Icons.warning_amber_rounded,
                    size: 15,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isProfitable ? 'Laba Bersih:' : 'Rugi Selisih:',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isProfitable ? const Color(0xFF166534) : AppColors.error,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${isProfitable ? '+' : ''}${CurrencyFormatter.format(coProfit)}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: isProfitable ? const Color(0xFF15803D) : AppColors.error,
                    ),
                  ),
                  if (coTotalCost > 0) ...[
                    const SizedBox(width: 5),
                    Text(
                      '(${coMarginPercent >= 0 ? '+' : ''}${coMarginPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isProfitable ? const Color(0xFF16A34A) : AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
