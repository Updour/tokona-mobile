import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/pay_kasbon_bottom_sheet.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class KasbonSaleTile extends StatelessWidget {
  final SaleModel sale;
  final CustomerModel? customer;
  final DateTime now;

  const KasbonSaleTile({
    super.key,
    required this.sale,
    required this.customer,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = sale.dueDate != null && now.isAfter(sale.dueDate!);
    final daysDiff = sale.dueDate != null ? sale.dueDate!.difference(now).inDays : null;

    String dueLabel;
    Color dueColor;
    if (sale.dueDate == null) {
      dueLabel = 'Tanpa Batas Waktu';
      dueColor = AppColors.textMuted;
    } else if (isOverdue) {
      final daysLate = now.difference(sale.dueDate!).inDays;
      dueLabel = daysLate == 0 ? 'Hari Ini Jatuh Tempo!' : 'Telat $daysLate Hari';
      dueColor = AppColors.error;
    } else if (daysDiff != null && daysDiff <= 3) {
      dueLabel = daysDiff == 0 ? 'Hari Ini Jatuh Tempo' : '$daysDiff Hari Lagi';
      dueColor = const Color(0xFFD97706);
    } else {
      dueLabel = 'Tempo ${dateFormat.format(sale.dueDate!)}';
      dueColor = const Color(0xFF047857);
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isOverdue ? const Color(0xFFFEF2F2).withValues(alpha: 0.6) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOverdue ? const Color(0xFFFCA5A5) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sale.customerName ?? 'Pelanggan Umum',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: dueColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dueLabel,
                  style: TextStyle(color: dueColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${sale.invoiceNumber} • Transaksi: ${dateFormat.format(sale.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(sale.finalAmount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
              ),
              if (customer != null)
                ElevatedButton.icon(
                  onPressed: () {
                    PayKasbonBottomSheet.show(context, customer: customer!);
                  },
                  icon: const Icon(Icons.payments_outlined, size: 14),
                  label: const Text('Bayar Kasbon', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

