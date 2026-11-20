import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class PurchaseFinancialSummaryCard extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseFinancialSummaryCard({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal Barang', CurrencyFormatter.format(purchase.totalAmount)),
          if (purchase.shippingFee > 0) ...[
            const SizedBox(height: 6),
            _buildRow('Ongkos Kirim', CurrencyFormatter.format(purchase.shippingFee)),
          ],
          if (purchase.serviceFee > 0) ...[
            const SizedBox(height: 6),
            _buildRow('Biaya Layanan', CurrencyFormatter.format(purchase.serviceFee)),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _buildRow('Total Belanja', CurrencyFormatter.format(purchase.grandTotal), isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13.5 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
