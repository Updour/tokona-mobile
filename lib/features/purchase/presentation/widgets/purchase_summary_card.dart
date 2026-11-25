import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final double itemsTotal;
  final double serviceFee;
  final double shippingFee;
  final double shippingDiscount;
  final double voucherDiscount;
  final bool isOnline;

  const PurchaseSummaryCard({
    super.key,
    required this.itemsTotal,
    required this.serviceFee,
    required this.shippingFee,
    this.shippingDiscount = 0.0,
    this.voucherDiscount = 0.0,
    required this.isOnline,
  });

  double get totalDiscount => shippingDiscount + voucherDiscount;
  double get grandTotal => (itemsTotal + shippingFee - shippingDiscount - voucherDiscount + serviceFee).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal Produk', CurrencyFormatter.format(itemsTotal), isBold: false),
          if (isOnline && shippingFee > 0) ...[
            const SizedBox(height: 5),
            _buildRow('Subtotal Pengiriman', '+ ${CurrencyFormatter.format(shippingFee)}', color: const Color(0xFF64748B)),
          ],
          if (isOnline && shippingDiscount > 0) ...[
            const SizedBox(height: 5),
            _buildRow('Diskon Pengiriman', '- ${CurrencyFormatter.format(shippingDiscount)}', color: const Color(0xFF15803D)),
          ],
          if (isOnline && voucherDiscount > 0) ...[
            const SizedBox(height: 5),
            _buildRow('Voucher Digunakan', '- ${CurrencyFormatter.format(voucherDiscount)}', color: const Color(0xFF15803D)),
          ],
          if (isOnline && serviceFee > 0) ...[
            const SizedBox(height: 5),
            _buildRow('Biaya Layanan', '+ ${CurrencyFormatter.format(serviceFee)}', color: const Color(0xFF64748B)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pesanan:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                CurrencyFormatter.format(grandTotal),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (totalDiscount > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Efisiensi Belanja: Kamu berhasil hemat ${CurrencyFormatter.format(totalDiscount)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
