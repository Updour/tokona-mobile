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

  double get _shippingFee => CurrencyFormatter.parse(widget.shippingFeeController.text);
  double get _shippingDiscount => CurrencyFormatter.parse(widget.shippingDiscountController.text);
  double get _voucherDiscount => CurrencyFormatter.parse(widget.voucherDiscountController.text);
  double get _serviceFee => CurrencyFormatter.parse(widget.serviceFeeController.text);

  double get _netShipping => (_shippingFee - _shippingDiscount).clamp(0.0, double.infinity);
  double get _totalDiscount => _shippingDiscount + _voucherDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Biaya & Diskon Marketplace',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Ongkir, layanan & voucher pengadaan',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _isDetailMode = !_isDetailMode);
                  if (!_isDetailMode) {
                    widget.shippingDiscountController.clear();
                    widget.voucherDiscountController.clear();
                    widget.onChanged();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isDetailMode ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isDetailMode ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDetailMode ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        size: 13,
                        color: _isDetailMode ? const Color(0xFF15803D) : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isDetailMode ? 'Ada Diskon' : '+ Diskon/Voucher',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _isDetailMode ? const Color(0xFF15803D) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 1: Biaya Utama (Ongkir & Layanan)
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: widget.shippingFeeController,
                  label: _isDetailMode ? 'Subtotal Ongkir' : 'Ongkos Kirim',
                  prefix: 'Rp',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputField(
                  controller: widget.serviceFeeController,
                  label: 'Biaya Layanan',
                  prefix: 'Rp',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Baris 2: Bagian Diskon & Potongan (Bila mode detail aktif)
          if (_isDetailMode) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.discount_outlined, size: 13, color: Color(0xFF15803D)),
                      SizedBox(width: 5),
                      Text(
                        'Potongan Diskon & Voucher Shopee',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: widget.shippingDiscountController,
                          label: 'Diskon Ongkir',
                          prefix: '-Rp',
                          color: const Color(0xFF15803D),
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          controller: widget.voucherDiscountController,
                          label: 'Voucher Toko/Shopee',
                          prefix: '-Rp',
                          color: const Color(0xFF15803D),
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Footer Live Summary jika ada diskon atau ongkir diisi
          if (_shippingFee > 0 || _totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ongkir Bersih: ${CurrencyFormatter.format(_netShipping)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                  ),
                  if (_totalDiscount > 0)
                    Text(
                      'Hemat: -${CurrencyFormatter.format(_totalDiscount)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String prefix,
    required Color color,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyTextInputFormatter()],
      onChanged: (_) {
        setState(() {});
        widget.onChanged();
      },
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        prefixText: prefix,
        prefixStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        hintText: '0',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
        isDense: true,
        filled: fillColor != null,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
