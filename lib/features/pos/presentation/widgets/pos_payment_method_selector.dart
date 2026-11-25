import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/widgets/add_payment_account_dialog.dart';

class PosPaymentMethodSelector extends StatelessWidget {
  final List<PaymentAccountModel> accounts;
  final PaymentAccountModel? selectedAccount;
  final bool isKasbonSelected;
  final ValueChanged<PaymentAccountModel> onAccountSelected;
  final VoidCallback onKasbonSelected;

  const PosPaymentMethodSelector({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.isKasbonSelected,
    required this.onAccountSelected,
    required this.onKasbonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                final added = await AddPaymentAccountDialog.show(context);
                if (added != null) onAccountSelected(added);
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Tambah Bank', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...accounts.map((acc) {
                final isSelected = !isKasbonSelected && selectedAccount?.id == acc.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(
                      acc.type == 'cash' ? Icons.money_rounded : (acc.type == 'ewallet' ? Icons.wallet_outlined : Icons.account_balance_outlined),
                      size: 13,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    label: Text(acc.name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      onAccountSelected(acc);
                    },
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  avatar: Icon(Icons.handshake_outlined, size: 14, color: isKasbonSelected ? Colors.white : const Color(0xFFD97706)),
                  label: const Text('Kasbon'),
                  selected: isKasbonSelected,
                  selectedColor: const Color(0xFFD97706),
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isKasbonSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isKasbonSelected ? Colors.white : const Color(0xFFB45309),
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    onKasbonSelected();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
