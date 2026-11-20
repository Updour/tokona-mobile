import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/presentation/controllers/paylater_settlement_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_bill_summary_card.dart';
import 'package:tokona/features/payment/presentation/widgets/paylater_settlement_history_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_sheet.dart';

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

    // Filter pembelian yang memakai akun Paylater (SPayLater, GoPay Paylater, Akulaku, dsb.)
    final paylaterPurchases = purchases.where((p) => p.isPaylater && !p.isCancelled).toList();

    // Hitung total tagihan Paylater bulan ini
    final now = DateTime.now();
    // Jika tgl 1, tagihan bulan kemarin. Jika tgl 29-31, tagihan bulan berjalan.
    final targetMonthPurchases = paylaterPurchases.where((p) {
      if (now.day == 1) {
        // Tagihan yang dibuat bulan lalu (jatuh tempo hari ini tgl 1)
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        return p.createdAt.year == prevMonth.year && p.createdAt.month == prevMonth.month;
      } else {
        return p.createdAt.year == now.year && p.createdAt.month == now.month;
      }
    }).toList();

    final totalTargetBill = targetMonthPurchases.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final allTimePaylaterTotal = paylaterPurchases.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    final currentDay = now.day;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final isWindowActive = (currentDay >= (lastDayOfMonth - 2)) || (currentDay == 1);
    final targetYear = (now.day == 1 && now.month == 1) ? now.year - 1 : now.year;
    final targetMonth = (now.day == 1) ? (now.month == 1 ? 12 : now.month - 1) : now.month;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
            ),
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
                    const Text('Jatuh tempo setiap tanggal 1 awal bulan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // KPI Summary Card & Confirmation Button
          PaylaterBillSummaryCard(
            totalTargetBill: totalTargetBill,
            allTimePaylaterTotal: allTimePaylaterTotal,
            transactionCount: paylaterPurchases.length,
            isWindowActive: isWindowActive,
            targetYear: targetYear,
            targetMonth: targetMonth,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pembelian Paylater', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.credit_card_off_outlined, size: 36, color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text('Belum ada transaksi dengan Paylater', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: paylaterPurchases.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final p = paylaterPurchases[idx];
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFFD97706)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(p.paymentAccount ?? 'Paylater', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                                        if (p.deviceTag != null && p.deviceTag!.isNotEmpty) ...[
                                          const SizedBox(width: 4),
                                          Text('• 📱 ${p.deviceTag!}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.supplierName ?? p.invoiceNumber,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Waktu beli: ${dateFormat.format(p.createdAt)}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(p.grandTotal),
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: p.isReceived ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.isReceived ? 'Diterima' : 'OTW/PO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: p.isReceived ? const Color(0xFF15803D) : const Color(0xFF0284C7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

