import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/sale_detail_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sale_history_card.dart';

class ReportSalesListSection extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String searchQuery;

  const ReportSalesListSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleState = ref.watch(saleHistoryControllerProvider);
    final allSales = saleState.sales;

    final filtered = allSales.where((s) {
      final isAfterOrEqual = s.createdAt.isAfter(startDate) || s.createdAt.isAtSameMomentAs(startDate);
      final isBeforeOrEqual = s.createdAt.isBefore(endDate) || s.createdAt.isAtSameMomentAs(endDate);
      if (!isAfterOrEqual || !isBeforeOrEqual) return false;

      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchInv = s.invoiceNumber.toLowerCase().contains(q);
        final matchCust = s.customerName?.toLowerCase().contains(q) ?? false;
        final matchItem = s.items.any((i) => i.productName?.toLowerCase().contains(q) ?? false);
        if (!matchInv && !matchCust && !matchItem) return false;
      }
      return true;
    }).toList();

    final validSales = filtered.where((s) => !s.isVoided);
    final totalOmzet = validSales.fold<double>(0.0, (acc, s) => acc + s.finalAmount);
    final totalNota = validSales.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text(
                    '$totalNota Nota Transaksi',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(totalOmzet),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _buildEmptyState()
        else
          ...filtered.map(
            (sale) => SaleHistoryCard(
              sale: sale,
              onTap: () => SaleDetailSheet.show(context, sale),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Tidak Ada Transaksi Penjualan', style: AppTypography.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Belum ada transaksi kasir pada periode laporan yang dipilih.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
