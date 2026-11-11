import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_management_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';
import 'package:tokona/features/report/presentation/widgets/report_export_bottom_sheet.dart';

class ReportTypesBottomSheet extends StatelessWidget {
  const ReportTypesBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportTypesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = [
      (
        'Ekspor Laporan (Excel & WA)',
        'Download file Excel (.CSV) atau kirim ringkasan ke WA',
        Icons.table_chart_rounded,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
        () {
          Navigator.of(context).pop();
          ReportExportBottomSheet.show(context);
        },
      ),
      (
        'Laporan Penjualan',
        'Omset kasir, riwayat struk, laba kotor & void',
        Icons.receipt_long_rounded,
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        () {
          Navigator.of(context).pop();
          SalesHistorySheet.show(context);
        },
      ),
      (
        'Laporan Pembelian',
        'Biaya kulakan, faktur & pesanan supplier',
        Icons.shopping_bag_outlined,
        const Color(0xFF0D9488),
        const Color(0xFFF0FDFA),
        () {
          Navigator.of(context).pop();
          PurchaseHistorySheet.show(context);
        },
      ),
      (
        'Laporan Modal & Prive',
        'Modal awal, suntikan modal & penarikan dana usaha',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
        () {
          Navigator.of(context).pop();
          StoreCapitalManagementSheet.show(context);
        },
      ),
      (
        'Laporan Piutang Kasbon',
        'Daftar hutang belanja pelanggan toko belum lunas',
        Icons.handshake_outlined,
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
        () {
          Navigator.of(context).pop();
          CustomerListBottomSheet.show(context);
        },
      ),
      (
        'Laporan Saldo & Arus Kas',
        'Monitoring saldo kasir, laci kas & mutasi bank',
        Icons.account_balance_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFF0F9FF),
        () {
          Navigator.of(context).pop();
          PaymentAccountManagementSheet.show(context);
        },
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semua Jenis Laporan Toko', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        'Pilih jenis laporan untuk melihat data dan riwayat terperinci',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = reports[index];
                return Material(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: item.$6,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.$5,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(item.$3, color: item.$4, size: 21),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
