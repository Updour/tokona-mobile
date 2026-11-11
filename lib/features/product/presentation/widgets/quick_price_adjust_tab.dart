import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class QuickPriceAdjustTab extends StatefulWidget {
  final ProductModel product;
  final Future<bool> Function(double newCost, double newSelling)? onQuickEditPrice;
  final VoidCallback onSuccess;

  const QuickPriceAdjustTab({
    super.key,
    required this.product,
    this.onQuickEditPrice,
    required this.onSuccess,
  });

  @override
  State<QuickPriceAdjustTab> createState() => _QuickPriceAdjustTabState();
}

class _QuickPriceAdjustTabState extends State<QuickPriceAdjustTab> {
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _costPriceController = TextEditingController(
      text: CurrencyFormatter.formatNumber(widget.product.baseCostPrice),
    );
    _sellingPriceController = TextEditingController(
      text: CurrencyFormatter.formatNumber(widget.product.baseSellingPrice),
    );
  }

  @override
  void dispose() {
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.onQuickEditPrice == null) return;
    final cost = CurrencyFormatter.parse(_costPriceController.text);
    final sell = CurrencyFormatter.parse(_sellingPriceController.text);
    if (sell <= 0) {
      AppToast.showError(context, 'Harga jual harus lebih besar dari 0');
      return;
    }
    if (cost < 0) {
      AppToast.showError(context, 'HPP modal tidak boleh negatif');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await widget.onQuickEditPrice!(cost, sell);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppToast.showSuccess(context, 'Harga berhasil diperbarui');
        widget.onSuccess();
      } else {
        AppToast.showError(context, 'Gagal memperbarui harga');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cost = CurrencyFormatter.parse(_costPriceController.text);
    final sell = CurrencyFormatter.parse(_sellingPriceController.text);
    final profit = sell - cost;
    final profitPct = cost > 0 ? (profit / cost) * 100 : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _costPriceController,
            label: 'HPP Modal Satuan (Rp)',
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyTextInputFormatter()],
            prefixIcon: Icons.account_balance_wallet_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _sellingPriceController,
            label: 'Harga Jual Satuan (Rp)',
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyTextInputFormatter()],
            prefixIcon: Icons.sell_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: profit >= 0 ? AppColors.successContainer : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    profit >= 0 ? 'Margin Keuntungan:' : 'Potensi Rugi:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${CurrencyFormatter.format(profit)} (+${profitPct.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: profit >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Simpan Ubah Harga', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
