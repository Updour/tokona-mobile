import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/modern_sheet_widgets.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/add_payment_account_dialog.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_card_item.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_store_wallet_card.dart';

class PaymentAccountManagementSheet extends ConsumerStatefulWidget {
  const PaymentAccountManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentAccountManagementSheet(),
    );
  }

  @override
  ConsumerState<PaymentAccountManagementSheet> createState() => _PaymentAccountManagementSheetState();
}

class _PaymentAccountManagementSheetState extends ConsumerState<PaymentAccountManagementSheet> {
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        ref.read(paymentAccountListProvider.notifier).loadAccounts(store.id);
      }
    });
  }

  Future<void> _handleDelete(PaymentAccountModel acc) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Akun Pembayaran',
      message: 'Hapus rekening ${acc.name}? Riwayat transaksi lama tetap tersimpan.',
      confirmText: 'Hapus',
      isDestructive: true,
    );
    if (confirmed == true) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        await ref.read(paymentAccountListProvider.notifier).deleteAccount(store.id, acc.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(paymentAccountListProvider);
    final totalBalance = ref.watch(totalStoreBalanceProvider);

    final filteredAccounts = accounts.where((acc) {
      if (_selectedFilter == 'BANK') return acc.type == 'bank';
      if (_selectedFilter == 'CASH') return acc.type == 'cash';
      if (_selectedFilter == 'EWALLET') return acc.type == 'ewallet' || acc.type == 'qris';
      return true;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernSheetHeader(
                title: 'Akun Pembayaran & Kas',
                subtitle: 'Rekening bank, QRIS & kas toko',
                icon: Icons.account_balance_rounded,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 14),
              PaymentStoreWalletCard(accounts: accounts, totalBalance: totalBalance),
              const SizedBox(height: 14),
              _buildFilterChips(accounts.length),
              const SizedBox(height: 10),
              Expanded(
                child: filteredAccounts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredAccounts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final acc = filteredAccounts[index];
                          return PaymentAccountCardItem(
                            account: acc,
                            onEdit: () => AddPaymentAccountDialog.show(context, initialAccount: acc),
                            onDelete: () => _handleDelete(acc),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              _buildAddButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(int totalCount) {
    return ModernFilterChips<String>(
      items: [
        ('ALL', 'Semua ($totalCount)'),
        ('BANK', 'Bank'),
        ('CASH', 'Kas Laci'),
        ('EWALLET', 'QRIS & E-Wallet'),
      ],
      selectedValue: _selectedFilter,
      onSelected: (val) => setState(() => _selectedFilter = val),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text('Belum ada akun di sini', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          SizedBox(height: 2),
          Text('Tap tombol di bawah untuk menambah akun', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => AddPaymentAccountDialog.show(context),
        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
        label: const Text(
          'Tambah Akun',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
