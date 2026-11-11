import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PosCheckoutButton extends StatelessWidget {
  final bool isProcessing;
  final bool isEmpty;
  final bool isKasbon;
  final VoidCallback onCheckout;

  const PosCheckoutButton({
    super.key,
    required this.isProcessing,
    required this.isEmpty,
    required this.isKasbon,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isProcessing
            ? null
            : (isKasbon
                ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)])
                : AppColors.primaryGradient),
        color: isProcessing ? AppColors.border : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: isProcessing || isEmpty ? null : onCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                isKasbon ? 'SIMPAN PENJUALAN TEMPO' : 'PROSES TRANSAKSI',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

