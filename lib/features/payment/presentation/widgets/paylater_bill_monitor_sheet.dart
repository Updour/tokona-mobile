import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/payment/presentation/controllers/paylater_settlement_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_bill_summary_card.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_piggy_bank_card.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_settlement_history_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_sheet.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class PaylaterBillMonitorSheet extends ConsumerWidget {
  const PaylaterBillMonitorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaylaterBillMonitorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final purchases = purchaseState.purchases;
    final prefs = ref.watch(appPreferencesProvider);
    final dueDay = prefs.paylaterDueDay;

    final paylaterPurchases = purchases.where((p) => p.isPaylater && !p.isCancelled).toList();
    final now = DateTime.now();

    double totalTargetBill = 0.0;
    double allTimePaylaterTotal = 0.0;

    for (final p in paylaterPurchases) {
      allTimePaylaterTotal += p.grandTotal;
      if (p.isInstallment) {
        if (!p.isInstallmentCompleted) {
          totalTargetBill += p.currentMonthlyBill;
        }
      } else {
        if (now.day <= dueDay) {
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          if (p.createdAt.year == prevMonth.year && p.createdAt.month == prevMonth.month) {
            totalTargetBill += p.grandTotal;
          }
        } else {
          if (p.createdAt.year == now.year && p.createdAt.month == now.month) {
            totalTargetBill += p.grandTotal;
          }
        }
      }
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final isWindowActive = (now.day >= (dueDay - 3) && now.day <= dueDay) || (now.day == dueDay);
    final targetYear = (now.day <= dueDay && now.month == 1) ? now.year - 1 : now.year;
    final targetMonth = (now.day <= dueDay) ? (now.month == 1 ? 12 : now.month - 1) : now.month;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 44, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rincian Tagihan Paylater', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('Siklus Jatuh Tempo: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: [1, 5, 11, 25].contains(dueDay) ? dueDay : 1,
                            isDense: true,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Tgl 01')),
                              DropdownMenuItem(value: 5, child: Text('Tgl 05')),
                              DropdownMenuItem(value: 11, child: Text('Tgl 11')),
                              DropdownMenuItem(value: 25, child: Text('Tgl 25')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                HapticFeedback.selectionClick();
                                ref.read(appPreferencesProvider.notifier).save(prefs.copyWith(paylaterDueDay: val));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20)),
            ],
          ),
          const SizedBox(height: 10),
          PaylaterBillSummaryCard(
            totalTargetBill: totalTargetBill,
            allTimePaylaterTotal: allTimePaylaterTotal,
            transactionCount: paylaterPurchases.length,
            isWindowActive: isWindowActive,
            targetYear: targetYear,
            targetMonth: targetMonth,
          ),
          if (totalTargetBill > 0)
            PaylaterPiggyBankCard(totalBill: totalTargetBill, dueDay: dueDay),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Pembelian & Cicilan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      final records = ref.read(paylaterSettlementProvider).records;
                      PaylaterSettlementHistorySheet.show(context, records);
                    },
                    child: const Text('Arsip Lunas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ),
                  const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      PaymentAccountManagementSheet.show(context);
                    },
                    child: const Text('Kas Toko →', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: paylaterPurchases.isEmpty
                ? const Center(child: Text('Belum ada transaksi dengan Paylater', style: TextStyle(fontSize: 12, color: AppColors.textMuted)))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: paylaterPurchases.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) => _buildPurchaseTile(context, ref, paylaterPurchases[idx], dateFormat),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTile(BuildContext context, WidgetRef ref, PurchaseModel p, DateFormat dateFormat) {
    return InkWell(
      onTap: () => PurchaseDetailSheet.show(context, p),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: Icon(p.isInstallment ? Icons.calendar_month_rounded : Icons.receipt_long_rounded, size: 16, color: const Color(0xFFD97706)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(p.paymentAccount ?? 'Paylater', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                      if (p.isInstallment) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: p.isInstallmentCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.isInstallmentCompleted ? 'Cicilan Lunas' : 'Cicilan ${p.paidInstallments}/${p.installmentMonths}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: p.isInstallmentCompleted ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(p.supplierName ?? p.invoiceNumber, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Beli: ${dateFormat.format(p.createdAt)}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  p.isInstallment
                      ? '${CurrencyFormatter.format(p.currentMonthlyBill)}/bln'
                      : CurrencyFormatter.format(p.grandTotal),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                if (p.isInstallment)
                  Text('Total: ${CurrencyFormatter.format(p.grandTotal)}', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                if (p.isInstallment && !p.isInstallmentCompleted)
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final next = p.paidInstallments + 1;
                      final ok = await ref.read(purchaseControllerProvider.notifier).updateInstallmentProgress(
                            purchaseId: p.id,
                            paidInstallments: next,
                            storeId: p.storeId,
                          );
                      if (ok && context.mounted) {
                        AppToast.showSuccess(context, 'Cicilan ke-$next berhasil dicatat lunas');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text('+ Bayar Cicilan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
