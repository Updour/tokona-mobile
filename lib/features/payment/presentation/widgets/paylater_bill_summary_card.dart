import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/paylater_settlement_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_settlement_account_sheet.dart';

class PaylaterBillSummaryCard extends ConsumerWidget {
  final double totalTargetBill;
  final double allTimePaylaterTotal;
  final int transactionCount;
  final bool isWindowActive;
  final int targetYear;
  final int targetMonth;

  const PaylaterBillSummaryCard({
    super.key,
    required this.totalTargetBill,
    required this.allTimePaylaterTotal,
    required this.transactionCount,
    required this.isWindowActive,
    required this.targetYear,
    required this.targetMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementState = ref.watch(paylaterSettlementProvider);
    final isSettled = settlementState.isSettled(targetYear, targetMonth);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSettled
              ? const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)]
              : (isWindowActive
                  ? const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]
                  : const [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSettled
              ? const Color(0xFF86EFAC)
              : (isWindowActive ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tagihan Jatuh Tempo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSettled ? const Color(0xFF166534) : const Color(0xFF92400E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isSettled
                      ? const Color(0xFF16A34A)
                      : (isWindowActive ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSettled ? 'LUNAS' : (isWindowActive ? 'SIAP DIBAYAR' : 'TAGIHAN AKTIF'),
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(totalTargetBill > 0 ? totalTargetBill : allTimePaylaterTotal),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isSettled ? const Color(0xFF15803D) : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isSettled ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 13,
                color: isSettled ? const Color(0xFF16A34A) : const Color(0xFFB45309),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  isSettled
                      ? 'Tagihan siklus ini sudah dikonfirmasi lunas.'
                      : '$transactionCount transaksi kulakan & cicilan PayLater berjalan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSettled ? const Color(0xFF166534) : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButton(context, ref, isSettled),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, bool isSettled) {
    final effectiveBill = totalTargetBill > 0 ? totalTargetBill : allTimePaylaterTotal;
    final store = ref.read(authProvider).currentStore;

    if (isSettled) {
      final record = ref.watch(paylaterSettlementProvider).getRecord(targetYear, targetMonth);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (record?.accountName != null) ...[
            Text(
              'Dibayar via: ${record!.accountName!} (${CurrencyFormatter.format(record.amount)})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
            ),
            const SizedBox(height: 6),
          ],
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await AppDialog.showConfirmation(
                context,
                title: 'Batal Status Lunas',
                message: 'Ubah kembali status tagihan bulan ini menjadi belum lunas? Saldo kas yang terpotong akan dikembalikan.',
                confirmText: 'Ya, Batalkan',
              );
              if (confirm == true) {
                final removed = await ref.read(paylaterSettlementProvider.notifier).unmarkSettled(targetYear, targetMonth);
                if (removed != null && removed.accountId != null && store != null && removed.amount > 0) {
                  // Kembalikan saldo kas
                  await ref.read(paymentAccountListProvider.notifier).adjustBalance(
                        store.id,
                        removed.accountId!,
                        removed.amount,
                      );
                }
                if (context.mounted) AppToast.showSuccess(context, 'Status tagihan diperbarui (Saldo kas dikembalikan)');
              }
            },
            icon: const Icon(Icons.undo_rounded, size: 14, color: Color(0xFF15803D)),
            label: const Text('Sudah Lunas (Batalkan)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF86EFAC)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );
    }

    final btnColor = isWindowActive ? const Color(0xFF16A34A) : const Color(0xFF0D9488);
    final btnLabel = isWindowActive ? 'Konfirmasi & Bayar Tagihan' : 'Bayar Lebih Awal / Cicil Sekarang';

    return ElevatedButton.icon(
      onPressed: effectiveBill <= 0
          ? null
          : () async {
              final accounts = ref.read(paymentAccountListProvider);
              if (accounts.isEmpty && store != null) {
                await ref.read(paymentAccountListProvider.notifier).loadAccounts(store.id);
              }
              final currentAccounts = ref.read(paymentAccountListProvider);

              if (!context.mounted) return;
              final selectedAccount = await PaylaterSettlementAccountSheet.show(
                context,
                amount: effectiveBill,
                accounts: currentAccounts,
              );

              if (selectedAccount == null || !context.mounted) return;

              if (store != null) {
                await ref.read(paymentAccountListProvider.notifier).adjustBalance(
                      store.id,
                      selectedAccount.id,
                      -effectiveBill,
                    );
              }

              await ref.read(paylaterSettlementProvider.notifier).markSettled(
                    targetYear,
                    targetMonth,
                    accountId: selectedAccount.id,
                    accountName: selectedAccount.name,
                    amount: effectiveBill,
                  );

              if (context.mounted) {
                AppToast.showSuccess(
                  context,
                  'Tagihan SPayLater lunas! Dipotong dari ${selectedAccount.name} (${CurrencyFormatter.format(effectiveBill)})',
                );
              }
            },
      icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
      label: Text(btnLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
