import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';

class PaymentAccountCardItem extends StatelessWidget {
  final PaymentAccountModel account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentAccountCardItem({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  _AccountStyle _resolveStyle(String name, String type) {
    final lower = name.toLowerCase();
    if (type == 'cash' || lower.contains('tunai') || lower.contains('laci')) {
      return const _AccountStyle(
        icon: Icons.payments_rounded,
        iconColor: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        badgeLabel: 'Kas Laci',
      );
    }
    if (type == 'qris' || lower.contains('qris')) {
      return const _AccountStyle(
        icon: Icons.qr_code_2_rounded,
        iconColor: Color(0xFF7C3AED),
        bgColor: Color(0xFFF5F3FF),
        badgeLabel: 'QRIS',
      );
    }
    if (lower.contains('bca')) {
      return const _AccountStyle(
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF00569E),
        bgColor: Color(0xFFEFF6FF),
        badgeLabel: 'Bank BCA',
      );
    }
    if (lower.contains('mandiri')) {
      return const _AccountStyle(
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF003066),
        bgColor: Color(0xFFEFF6FF),
        badgeLabel: 'Mandiri',
      );
    }
    if (lower.contains('bri')) {
      return const _AccountStyle(
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF00529C),
        bgColor: Color(0xFFEFF6FF),
        badgeLabel: 'Bank BRI',
      );
    }
    if (type == 'ewallet' || lower.contains('dana') || lower.contains('gopay') || lower.contains('ovo')) {
      return const _AccountStyle(
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Color(0xFFD97706),
        bgColor: Color(0xFFFEF3C7),
        badgeLabel: 'E-Wallet',
      );
    }
    return const _AccountStyle(
      icon: Icons.account_balance_rounded,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
      badgeLabel: 'Bank Transfer',
    );
  }

  void _copyAccountNumber(BuildContext context) {
    if (account.accountNumber != null && account.accountNumber!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: account.accountNumber!));
      HapticFeedback.lightImpact();
      AppToast.showSuccess(context, 'Nomor rekening disalin ke clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(account.name, account.type);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: style.bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(style.icon, color: style.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(color: style.bgColor, borderRadius: BorderRadius.circular(5)),
                          child: Text(style.badgeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: style.iconColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (account.accountNumber != null && account.accountNumber!.isNotEmpty)
                      InkWell(
                        onTap: () => _copyAccountNumber(context),
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              account.accountNumber!,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.3),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 11, color: Color(0xFF64748B)),
                            if (account.holderName != null && account.holderName!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text('• A.N ${account.holderName!}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ],
                        ),
                      )
                    else
                      const Text('Kas Tunai Laci Operasional', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo Tersedia', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                Text(
                  CurrencyFormatter.format(account.currentBalance),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String badgeLabel;

  const _AccountStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.badgeLabel,
  });
}

