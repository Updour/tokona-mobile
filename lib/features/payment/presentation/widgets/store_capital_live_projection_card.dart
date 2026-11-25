import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/domain/models/store_capital_state.dart';

class StoreCapitalLiveProjectionCard extends StatelessWidget {
  final String type;
  final String targetName;
  final double currentAccBalance;
  final double rawAmount;
  final StoreCapitalState capitalState;
  final bool isOverdrawn;

  const StoreCapitalLiveProjectionCard({
    super.key,
    required this.type,
    required this.targetName,
    required this.currentAccBalance,
    required this.rawAmount,
    required this.capitalState,
    required this.isOverdrawn,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 'TARIK_MODAL') {
      final remainingAcc = currentAccBalance - rawAmount;
      final remainingNet = capitalState.netCapital - rawAmount;

      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isOverdrawn ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverdrawn ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
            width: isOverdrawn ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverdrawn ? Icons.error_outline_rounded : Icons.calculate_outlined,
                  size: 16,
                  color: isOverdrawn ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Proyeksi Sisa Saldo Kas & Modal Usaha',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isOverdrawn ? const Color(0xFF991B1B) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo Kas ($targetName) Saat Ini:', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                Text(CurrencyFormatter.format(currentAccBalance), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nominal Ditarik (Prive):', style: TextStyle(fontSize: 11.5, color: AppColors.error)),
                Text(
                  rawAmount > 0 ? '- ${CurrencyFormatter.format(rawAmount)}' : 'Rp0',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverdrawn ? 'Saldo Kas Tidak Cukup:' : 'Sisa Saldo Kas Nanti:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isOverdrawn ? const Color(0xFF991B1B) : const Color(0xFF166534),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(remainingAcc),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isOverdrawn ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
            if (isOverdrawn) ...[
              const SizedBox(height: 4),
              Text(
                'Defisit kas sebesar ${CurrencyFormatter.format(remainingAcc.abs())}. Kurangi nominal penarikan.',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C)),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sisa Modal Usaha (Net) Nanti:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  CurrencyFormatter.format(remainingNet),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (type == 'TAMBAH_MODAL') {
      final projectedAcc = currentAccBalance + rawAmount;
      final projectedNet = capitalState.netCapital + rawAmount;

      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF059669)),
                SizedBox(width: 6),
                Text(
                  'Estimasi Saldo Kas & Modal Bertambah',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo Kas ($targetName) Saat Ini:', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                Text(CurrencyFormatter.format(currentAccBalance), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tambahan Modal Masuk:', style: TextStyle(fontSize: 11.5, color: Color(0xFF059669))),
                Text(
                  rawAmount > 0 ? '+ ${CurrencyFormatter.format(rawAmount)}' : 'Rp0',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimasi Saldo Kas Nanti:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                ),
                Text(
                  CurrencyFormatter.format(projectedAcc),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimasi Modal Toko (Net) Nanti:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  CurrencyFormatter.format(projectedNet),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      final projectedInitial = capitalState.initialCapital + rawAmount;
      final projectedAcc = currentAccBalance + rawAmount;

      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_outlined, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Text(
                  'Proyeksi Modal Awal Toko',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Modal Awal Saat Ini:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                Text(CurrencyFormatter.format(capitalState.initialCapital), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Modal Awal Baru:', style: TextStyle(fontSize: 11.5, color: Color(0xFF2563EB))),
                Text(
                  rawAmount > 0 ? '+ ${CurrencyFormatter.format(rawAmount)}' : 'Rp0',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Modal Awal Baru:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF)),
                ),
                Text(
                  CurrencyFormatter.format(projectedInitial),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimasi Saldo Kas ($targetName) Nanti:', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  CurrencyFormatter.format(projectedAcc),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
