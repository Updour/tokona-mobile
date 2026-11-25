import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';

class StoreCapitalAccountPicker extends StatelessWidget {
  final List<PaymentAccountModel> accounts;
  final String? selectedAccountId;
  final bool isWithdrawal;
  final ValueChanged<PaymentAccountModel?> onAccountSelected;

  const StoreCapitalAccountPicker({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.isWithdrawal,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Memuat saldo rekening kas toko...', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...accounts.map((acc) {
            final isSel = selectedAccountId == acc.id;
            final isCash = acc.type == 'cash';
            final isBank = acc.type == 'bank';
            final icon = isCash
                ? Icons.payments_outlined
                : (isBank ? Icons.account_balance_outlined : Icons.wallet_rounded);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAccountSelected(acc);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSel
                        ? (isWithdrawal ? const Color(0xFFFEF2F2) : AppColors.primaryContainer)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel
                          ? (isWithdrawal ? AppColors.error : AppColors.primary)
                          : AppColors.border,
                      width: isSel ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 15,
                            color: isSel
                                ? (isWithdrawal ? AppColors.error : AppColors.primaryDark)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            acc.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSel
                                  ? (isWithdrawal ? const Color(0xFF991B1B) : AppColors.primaryDark)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Sisa Kas: ${CurrencyFormatter.format(acc.currentBalance)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? (isWithdrawal ? AppColors.error : AppColors.primary)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onAccountSelected(null);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: selectedAccountId == null ? const Color(0xFFF1F5F9) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedAccountId == null ? const Color(0xFF94A3B8) : AppColors.border,
                    width: selectedAccountId == null ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.money_off_rounded,
                          size: 15,
                          color: selectedAccountId == null ? const Color(0xFF334155) : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tanpa Rekening',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selectedAccountId == null ? const Color(0xFF1E293B) : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text('Hanya Catatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
