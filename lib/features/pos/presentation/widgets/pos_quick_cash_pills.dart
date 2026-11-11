import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PosQuickCashPills extends StatelessWidget {
  final double finalAmount;
  final ValueChanged<double> onQuickCashSelected;

  const PosQuickCashPills({
    super.key,
    required this.finalAmount,
    required this.onQuickCashSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final double base = finalAmount;
    final List<double> higherPresets = [];

    void addIfHigher(double candidate) {
      if (candidate > base && !higherPresets.contains(candidate)) {
        higherPresets.add(candidate);
      }
    }

    if (base > 0) {
      addIfHigher(((base / 5000).ceil()) * 5000.0);
      addIfHigher(((base / 10000).ceil()) * 10000.0);
      addIfHigher(((base / 20000).ceil()) * 20000.0);
      addIfHigher(((base / 50000).ceil()) * 50000.0);
      addIfHigher(((base / 100000).ceil()) * 100000.0);
      if (higherPresets.length < 3) addIfHigher(100000);
      if (higherPresets.length < 4) addIfHigher(200000);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              avatar: const Icon(Icons.flash_on_rounded, size: 13, color: Color(0xFF047857)),
              label: Text(
                'Uang Pas (${currency.format(finalAmount)})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
              ),
              backgroundColor: const Color(0xFFD1FAE5),
              side: const BorderSide(color: Color(0xFF6EE7B7)),
              onPressed: () {
                HapticFeedback.lightImpact();
                onQuickCashSelected(finalAmount);
              },
            ),
          ),
          ...higherPresets.take(4).map((val) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                label: Text(
                  currency.format(val),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onQuickCashSelected(val);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

