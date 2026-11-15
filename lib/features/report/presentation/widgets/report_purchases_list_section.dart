import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_card.dart';

class ReportPurchasesListSection extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String searchQuery;

  const ReportPurchasesListSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final allPurchases = purchaseState.purchases;

    final filtered = allPurchases.where((p) {
      if (p.isCancelled) return false;
      final isAfterOrEqual = p.createdAt.isAfter(startDate) || p.createdAt.isAtSameMomentAs(startDate);
      final isBeforeOrEqual = p.createdAt.isBefore(endDate) || p.createdAt.isAtSameMomentAs(endDate);
      if (!isAfterOrEqual || !isBeforeOrEqual) return false;

      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchInv = p.invoiceNumber.toLowerCase().contains(q);
        final matchSup = p.supplierName?.toLowerCase().contains(q) ?? false;
        final matchResi = p.trackingNumber?.toLowerCase().contains(q) ?? false;
        final matchItem = p.items.any((i) => (i.productName ?? '').toLowerCase().contains(q));
        if (!matchInv && !matchSup && !matchResi && !matchItem) return false;
      }
      return true;
    }).toList();

    final totalBelanja = filtered.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final totalFaktur = filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 6),
                  Text(
                    '$totalFaktur Faktur Belanja',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF115E59)),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(totalBelanja),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF115E59)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _buildEmptyState()
        else
          ...filtered.map(
            (purchase) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PurchaseHistoryCard(
                purchase: purchase,
                onTap: () => PurchaseDetailSheet.show(context, purchase),
              ),
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
          const Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Belum Ada Faktur Pembelian', style: AppTypography.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Belum ada pembelian stok / kulakan pada periode laporan yang dipilih.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
