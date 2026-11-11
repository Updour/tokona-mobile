import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Pembayaran & Kas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  'Master rekening bank, QRIS, & modal kas toko',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips(int totalCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Semua ($totalCount)', 'ALL'),
          const SizedBox(width: 6),
          _buildChip('Rekening Bank', 'BANK'),
          const SizedBox(width: 6),
          _buildChip('Kas Laci', 'CASH'),
          const SizedBox(width: 6),
          _buildChip('QRIS & E-Wallet', 'EWALLET'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text('Belum ada akun di kategori ini', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          SizedBox(height: 2),
          Text('Tekan tombol di bawah untuk menambah rekening baru', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
          'Tambah Rekening / QRIS / Kas',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
