import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class StoreCapitalPresetChips extends StatelessWidget {
  final bool isWithdrawal;
  final double currentAccBalance;
  final ValueChanged<double> onAmountSelected;

  const StoreCapitalPresetChips({
    super.key,
    required this.isWithdrawal,
    required this.currentAccBalance,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isWithdrawal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            if (currentAccBalance > 0) ...[
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAmountSelected(currentAccBalance);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        'Tarik Semua Saldo (${CurrencyFormatter.format(currentAccBalance)})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            ...[50000, 100000, 250000, 500000, 1000000].where((amt) => amt <= currentAccBalance || currentAccBalance == 0).map((amt) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAmountSelected(amt.toDouble());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      CurrencyFormatter.format(amt.toDouble()),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [100000, 250000, 500000, 1000000, 2000000, 5000000].map((amt) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onAmountSelected(amt.toDouble());
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  '+${CurrencyFormatter.format(amt.toDouble())}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
