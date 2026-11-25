import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseMarketplaceBreakdownCard extends StatefulWidget {
  final TextEditingController serviceFeeController;
  final TextEditingController shippingFeeController;
  final TextEditingController shippingDiscountController;
  final TextEditingController voucherDiscountController;
  final VoidCallback onChanged;

  const PurchaseMarketplaceBreakdownCard({
    super.key,
    required this.serviceFeeController,
    required this.shippingFeeController,
    required this.shippingDiscountController,
    required this.voucherDiscountController,
    required this.onChanged,
  });

  @override
  State<PurchaseMarketplaceBreakdownCard> createState() => _PurchaseMarketplaceBreakdownCardState();
}

class _PurchaseMarketplaceBreakdownCardState extends State<PurchaseMarketplaceBreakdownCard> {
  bool _isDetailMode = false;

  @override
  void initState() {
    super.initState();
    final hasVoucher = CurrencyFormatter.parse(widget.voucherDiscountController.text) > 0;
    final hasShipDisc = CurrencyFormatter.parse(widget.shippingDiscountController.text) > 0;
    if (hasVoucher || hasShipDisc) {
      _isDetailMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Rincian Biaya & Diskon Marketplace',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _isDetailMode ? 'Mode Rinci' : 'Ringkas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isDetailMode ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: _isDetailMode,
                    activeThumbColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() => _isDetailMode = val);
                      if (!val) {
                        widget.shippingDiscountController.clear();
                        widget.voucherDiscountController.clear();
                        widget.onChanged();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!_isDetailMode)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.shippingFeeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Ongkos Kirim',
                      prefixText: 'Rp ',
                      hintText: '0',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.serviceFeeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Biaya Layanan',
                      prefixText: 'Rp ',
                      hintText: '0',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.shippingFeeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Subtotal Pengiriman',
                      prefixText: 'Rp ',
                      hintText: '108.500',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.shippingDiscountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Diskon Pengiriman',
                      prefixText: '- Rp ',
                      hintText: '108.500',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.voucherDiscountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Voucher Digunakan',
                      prefixText: '- Rp ',
                      hintText: '396.000',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.serviceFeeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => widget.onChanged(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Biaya Layanan',
                      prefixText: 'Rp ',
                      hintText: '4.000',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
