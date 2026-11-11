import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';

class CustomerLedgerPaymentTile extends StatelessWidget {
  final CustomerReceivablePaymentModel item;

  const CustomerLedgerPaymentTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(item.amount),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF047857)),
                ),
                const SizedBox(height: 2),
                Text(dateFormat.format(item.paymentDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (item.accountName != null || item.notes != null)
                  Text(
                    [item.accountName, item.notes].whereType<String>().join(' - '),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
