import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final double itemsTotal;
  final double serviceFee;
  final double shippingFee;
  final bool isOnline;

  const PurchaseSummaryCard({
    super.key,
    required this.itemsTotal,
    required this.serviceFee,
    required this.shippingFee,
    required this.isOnline,
  });

  double get grandTotal => itemsTotal + serviceFee + shippingFee;

  @override
  Widget build(BuildContext context) {
    final extraFees = serviceFee + shippingFee;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal Barang:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(itemsTotal),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (isOnline && extraFees > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biaya Layanan & Ongkir:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '+ ${CurrencyFormatter.format(extraFees)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEA580C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Uang Keluar:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                CurrencyFormatter.format(grandTotal),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
