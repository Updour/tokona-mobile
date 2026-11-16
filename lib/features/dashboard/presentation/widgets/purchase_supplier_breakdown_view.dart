import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class PurchaseSupplierBreakdownView extends StatelessWidget {
  final List<PurchaseModel> purchases;
  final double totalSpend;

  const PurchaseSupplierBreakdownView({
    super.key,
    required this.purchases,
    required this.totalSpend,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> supplierTotals = {};
    for (final p in purchases) {
      final name = (p.supplierName != null && p.supplierName!.trim().isNotEmpty) ? p.supplierName!.trim() : 'Supplier Lain';
      supplierTotals[name] = (supplierTotals[name] ?? 0) + p.grandTotal;
    }
    final sortedSuppliers = supplierTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${purchases.length} Faktur Selesai', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
              Text('Total Belanja: ${CurrencyFormatter.format(totalSpend)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...sortedSuppliers.take(4).map((entry) {
          final pct = totalSpend > 0 ? (entry.value / totalSpend) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(entry.key, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                    ),
                    Text(CurrencyFormatter.format(entry.value), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  value: pct.clamp(0.05, 1.0),
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  borderRadius: BorderRadius.circular(3),
                  minHeight: 5,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
