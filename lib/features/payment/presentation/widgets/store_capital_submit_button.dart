import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class StoreCapitalSubmitButton extends StatelessWidget {
  final bool isFormValid;
  final bool isOverdrawn;
  final bool isSubmitting;
  final bool isWithdrawal;
  final String btnLabel;
  final VoidCallback onSubmit;

  const StoreCapitalSubmitButton({
    super.key,
    required this.isFormValid,
    required this.isOverdrawn,
    required this.isSubmitting,
    required this.isWithdrawal,
    required this.btnLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isFormValid && !isOverdrawn && !isSubmitting ? onSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isWithdrawal ? AppColors.error : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                isOverdrawn ? 'Saldo Kas Tidak Cukup' : btnLabel,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
      ),
    );
  }
}
