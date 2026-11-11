import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/features/payment/domain/models/store_capital_model.dart';

class StoreCapitalCard extends StatelessWidget {
  final StoreCapitalModel capital;
  final VoidCallback onDelete;

  const StoreCapitalCard({
    super.key,
    required this.capital,
    required this.onDelete,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Catatan Modal',
      message: 'Yakin ingin menghapus catatan modal ini? Jika terhubung dengan rekening, saldo akan otomatis dikoreksi.',
      confirmText: 'Ya, Hapus',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirm == true) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isWithdrawal = capital.isWithdrawal;

    Color badgeColor = const Color(0xFF0D9488);
    if (capital.type == 'MODAL_AWAL') badgeColor = const Color(0xFF2563EB);
    if (isWithdrawal) badgeColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      capital.typeLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(capital.capitalDate),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                tooltip: 'Hapus',
                visualDensity: VisualDensity.compact,
                onPressed: () => _handleDelete(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isWithdrawal ? '-' : '+'}${CurrencyFormatter.format(capital.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isWithdrawal ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              if (capital.accountName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        capital.accountName!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (capital.source != null || capital.notes != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (capital.source != null)
              Row(
                children: [
                  const Text('Sumber: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(capital.source!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            if (capital.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  capital.notes!,
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
