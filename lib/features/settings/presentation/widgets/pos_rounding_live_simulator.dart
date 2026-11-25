import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PosRoundingLiveSimulator extends StatelessWidget {
  final bool enabled;
  final String mode;
  final int step;
  final TextEditingController testAmountController;
  final double simulatedRawAmount;
  final double simulatedRounding;
  final double simulatedFinalAmount;

  const PosRoundingLiveSimulator({
    super.key,
    required this.enabled,
    required this.mode,
    required this.step,
    required this.testAmountController,
    required this.simulatedRawAmount,
    required this.simulatedRounding,
    required this.simulatedFinalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final sign = simulatedRounding > 0 ? '+' : '';
    final roundingColor = simulatedRounding > 0
        ? const Color(0xFF15803D)
        : (simulatedRounding < 0 ? const Color(0xFFDC2626) : const Color(0xFF64748B));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF0F766E)),
                  SizedBox(width: 6),
                  Text(
                    'Simulasi Struk Kasir',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: enabled ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  enabled ? 'Aktif' : 'Mati',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: enabled ? const Color(0xFF15803D) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: testAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coba Ketik Total Belanja (Rp)',
                    isDense: true,
                    prefixText: 'Rp',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Subtotal Belanja', CurrencyFormatter.format(simulatedRawAmount)),
                const SizedBox(height: 4),
                if (enabled && simulatedRounding != 0) ...[
                  _buildReceiptRow(
                    'Pembulatan (${mode == "round_up" ? "Round Up" : (mode == "round_down" ? "Round Down" : "Terdekat")} $step)',
                    '$sign${CurrencyFormatter.format(simulatedRounding)}',
                    color: roundingColor,
                    isBold: true,
                  ),
                  const SizedBox(height: 4),
                ],
                const Divider(height: 12, thickness: 1),
                _buildReceiptRow(
                  'TOTAL DIBAYAR',
                  CurrencyFormatter.format(simulatedFinalAmount),
                  color: AppColors.primary,
                  isBold: true,
                  fontSize: 13.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? color, bool isBold = false, double fontSize = 11.5}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: color ?? const Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
