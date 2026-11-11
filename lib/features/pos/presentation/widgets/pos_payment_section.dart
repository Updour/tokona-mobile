import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/widgets/add_payment_account_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_bank_transfer_card.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_quick_cash_pills.dart';

class PosPaymentSection extends StatelessWidget {
  final double subtotal;
  final double discount;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: AppTypography.labelMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Text(currency.format(finalAmount), style: AppTypography.headingSmall.copyWith(color: AppColors.primary, fontSize: 16.5, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          _buildMethodHeader(context),
          const SizedBox(height: 6),
          _buildAccountSelector(),
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

  Widget _buildMethodHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Metode Pembayaran', style: AppTypography.bodySmall.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600)),
        InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            final added = await AddPaymentAccountDialog.show(context);
            if (added != null) onAccountSelected(added);
          },
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                SizedBox(width: 2),
                Text('Tambah Bank', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...accounts.map((acc) {
            final isSelected = !isKasbonSelected && selectedAccount?.id == acc.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                avatar: Icon(
                  acc.type == 'cash' ? Icons.money_rounded : (acc.type == 'ewallet' ? Icons.wallet_outlined : Icons.account_balance_outlined),
                  size: 13,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                label: Text(acc.name),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onAccountSelected(acc);
                },
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(Icons.handshake_outlined, size: 14, color: isKasbonSelected ? Colors.white : const Color(0xFFD97706)),
              label: const Text('Kasbon'),
              selected: isKasbonSelected,
              selectedColor: const Color(0xFFD97706),
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isKasbonSelected ? FontWeight.w700 : FontWeight.w500,
                color: isKasbonSelected ? Colors.white : const Color(0xFFB45309),
              ),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                onKasbonSelected();
              },
            ),
          ),
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
