import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_payment_account_dialog.dart';

class PurchasePaymentAccountChips extends ConsumerWidget {
  final String? selectedAccount;
  final ValueChanged<String> onAccountSelected;

  const PurchasePaymentAccountChips({
    super.key,
    required this.selectedAccount,
    required this.onAccountSelected,
  });

  static const List<String> fallbackAccounts = [
    'SeaBank',
    'Bank BCA',
    'ShopeePay',
    'Kas Tunai',
  ];

  IconData _getIconForAccount(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pay') || lower.contains('dana') || lower.contains('ovo') || lower.contains('gopay')) {
      return Icons.wallet_outlined;
    }
    if (lower.contains('kas') || lower.contains('tunai')) {
      return Icons.payments_outlined;
    }
    return Icons.account_balance_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(authProvider).currentStore;
    final accountList = ref.watch(paymentAccountListProvider);
    final accounts = accountList.isEmpty ? fallbackAccounts : accountList;

    if (accountList.isEmpty && store != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(paymentAccountListProvider.notifier).loadAccounts(store.id);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sumber Pembayaran',
                  style: AppTypography.labelMedium.copyWith(fontSize: 12.5),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                final name = await AddPaymentAccountDialog.show(context);
                if (name != null && store != null) {
                  final added = await ref
                      .read(paymentAccountListProvider.notifier)
                      .addAccount(store.id, name);
                  if (added != null) {
                    onAccountSelected(added);
                  }
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 2),
                    Text(
                      'Tambah Bank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...accounts.map((acc) {
                final isSelected = selectedAccount == acc;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      _getIconForAccount(acc),
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    label: Text(
                      acc,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: AppColors.surfaceElevated,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : AppColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) onAccountSelected(acc);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
