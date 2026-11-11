import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_management_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';

class ReportHubSection extends StatelessWidget {
  const ReportHubSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      (
        'Laporan Penjualan',
        'Omset kasir, struk & laba kotor',
        Icons.receipt_long_rounded,
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        () => SalesHistorySheet.show(context),
      ),
      (
        'Laporan Pembelian',
        'Biaya kulakan & nota supplier',
        Icons.shopping_bag_outlined,
        const Color(0xFF0D9488),
        const Color(0xFFF0FDFA),
        () => PurchaseHistorySheet.show(context),
      ),
      (
        'Laporan Modal & Prive',
        'Modal awal, suntikan & tarik modal',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
        () => StoreCapitalManagementSheet.show(context),
      ),
      (
        'Laporan Piutang Kasbon',
        'Hutang belanja pelanggan toko',
        Icons.handshake_outlined,
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
        () => CustomerListBottomSheet.show(context),
      ),
      (
        'Laporan Saldo & Arus Kas',
        'Saldo rekening & kas laci kasir',
        Icons.account_balance_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFF0F9FF),
        () => PaymentAccountManagementSheet.show(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Detail Jenis Laporan Toko', style: AppTypography.labelMedium.copyWith(fontSize: 13.5)),
            const Text('Akses Cepat', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = reports[index];
            return Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: item.$6,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.$5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$3, color: item.$4, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1.5),
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
    );
  }
}
