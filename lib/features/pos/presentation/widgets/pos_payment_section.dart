import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_bank_transfer_card.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_payment_method_selector.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_quick_cash_pills.dart';

class PosPaymentSection extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double roundingAmount;
  final double finalAmount;
  final TextEditingController cashController;
  final TextEditingController discountController;
  final List<PaymentAccountModel> accounts;
  final PaymentAccountModel? selectedAccount;
  final bool isKasbonSelected;
  final ValueChanged<PaymentAccountModel> onAccountSelected;
  final VoidCallback onKasbonSelected;
  final ValueChanged<double> onQuickCashSelected;

  const PosPaymentSection({
    super.key,
    required this.subtotal,
    required this.discount,
    this.roundingAmount = 0.0,
    required this.finalAmount,
    required this.cashController,
    required this.discountController,
    required this.accounts,
    required this.selectedAccount,
    this.isKasbonSelected = false,
    required this.onAccountSelected,
    required this.onKasbonSelected,
    required this.onQuickCashSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final cashPaid = CurrencyFormatter.parse(cashController.text);
    final change = cashPaid - finalAmount;
    final isEnough = cashPaid >= finalAmount;
    final isCash = !isKasbonSelected && (selectedAccount == null || selectedAccount!.type == 'cash');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              Text(currency.format(subtotal), style: AppTypography.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(flex: 2, child: Text('Diskon (Rp)', style: AppTypography.bodySmall.copyWith(fontSize: 12))),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    decoration: InputDecoration(
                      hintText: '0',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      suffixIcon: discount > 0
                          ? GestureDetector(
                              onTap: () => discountController.clear(),
                              child: const Icon(Icons.cancel_rounded, size: 14, color: AppColors.textMuted),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          if (roundingAmount != 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Pembulatan', style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: roundingAmount > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roundingAmount > 0 ? 'Round Up' : 'Round Down',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: roundingAmount > 0 ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${roundingAmount > 0 ? "+" : ""}${currency.format(roundingAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: roundingAmount > 0 ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: AppTypography.labelMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Text(currency.format(finalAmount), style: AppTypography.headingSmall.copyWith(color: AppColors.primary, fontSize: 16.5, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          PosPaymentMethodSelector(
            accounts: accounts,
            selectedAccount: selectedAccount,
            isKasbonSelected: isKasbonSelected,
            onAccountSelected: onAccountSelected,
            onKasbonSelected: onKasbonSelected,
          ),
          const SizedBox(height: 10),
          if (isKasbonSelected) ...[
            _buildKasbonCard(currency),
          ] else if (isCash) ...[
            Text('Nominal Pembayaran Tunai', style: AppTypography.bodySmall.copyWith(fontSize: 11.5)),
            const SizedBox(height: 6),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],
              style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                prefixIcon: Icon(Icons.payments_outlined, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            PosQuickCashPills(finalAmount: finalAmount, onQuickCashSelected: onQuickCashSelected),
            const SizedBox(height: 10),
            _buildChangeBanner(isEnough, change, currency),
          ] else if (selectedAccount != null) ...[
            PosBankTransferCard(account: selectedAccount!, currency: currency),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeBanner(bool isEnough, double change, NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isEnough ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: isEnough ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isEnough ? Icons.check_circle_rounded : Icons.info_outline_rounded, size: 15, color: isEnough ? const Color(0xFF059669) : const Color(0xFFD97706)),
              const SizedBox(width: 5),
              Text(
                isEnough ? 'Kembalian' : 'Kekurangan',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isEnough ? const Color(0xFF065F46) : const Color(0xFF92400E)),
              ),
            ],
          ),
          Text(
            currency.format(change.abs()),
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isEnough ? const Color(0xFF059669) : const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }

  Widget _buildKasbonCard(NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined, color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penjualan Tempo (Kasbon)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                const SizedBox(height: 2),
                Text('Tagihan ${currency.format(finalAmount)} otomatis dicatat ke riwayat hutang pelanggan.', style: const TextStyle(fontSize: 10.5, color: Color(0xFF78350F))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
