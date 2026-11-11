import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';

class PosBankTransferCard extends StatelessWidget {
  final PaymentAccountModel account;
  final NumberFormat currency;

  const PosBankTransferCard({
    super.key,
    required this.account,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                account.type == 'ewallet' ? Icons.wallet_outlined : Icons.account_balance_outlined,
                size: 18,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Instruksi Pembayaran ${account.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
          if (account.accountNumber != null && account.accountNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nomor Rekening / Virtual Account:', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    const SizedBox(height: 2),
                    Text(
                      account.accountNumber!,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF2563EB)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: account.accountNumber!));
                    HapticFeedback.lightImpact();
                    AppToast.showSuccess(context, 'Nomor rekening disalin');
                  },
                ),
              ],
            ),
          ],
          if (account.holderName != null && account.holderName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Atas Nama: ${account.holderName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ],
        ],
      ),
    );
  }
}
