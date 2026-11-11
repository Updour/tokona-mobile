import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class QuickStockAdjustTab extends StatefulWidget {
  final ProductModel product;
  final Future<bool> Function(double newStock)? onAdjustStock;
  final VoidCallback onSuccess;

  const QuickStockAdjustTab({
    super.key,
    required this.product,
    this.onAdjustStock,
    required this.onSuccess,
  });

  @override
  State<QuickStockAdjustTab> createState() => _QuickStockAdjustTabState();
}

class _QuickStockAdjustTabState extends State<QuickStockAdjustTab> {
  final _stockController = TextEditingController(text: '10');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  double get _currentStock => widget.product.stockBase;

  double get _inputStockValue => CurrencyFormatter.parse(_stockController.text);

  double get _resultingStock => _currentStock + _inputStockValue;

  Future<void> _submit() async {
    if (widget.onAdjustStock == null) return;
    if (_resultingStock < 0) {
      AppToast.showError(context, 'Stok akhir tidak boleh kurang dari 0');
      return;
    }
    if (_inputStockValue <= 0) {
      AppToast.showError(context, 'Jumlah tambahan stok harus lebih dari 0');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await widget.onAdjustStock!(_resultingStock);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppToast.showSuccess(context, 'Stok berhasil ditambahkan');
        widget.onSuccess();
      } else {
        AppToast.showError(context, 'Gagal menambahkan stok');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _stockController,
            label: 'Jumlah Tambahan Stok (${widget.product.baseUnit})',
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyTextInputFormatter()],
            prefixIcon: Icons.add_box_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [5, 10, 25, 50, 100].map((qty) {
              return ActionChip(
                label: Text('+$qty'),
                backgroundColor: AppColors.surfaceElevated,
                onPressed: () {
                  final curr = _inputStockValue;
                  _stockController.text = CurrencyFormatter.formatNumber(curr + qty);
                  setState(() {});
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Estimasi Stok Baru:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_resultingStock.toStringAsFixed(0)} ${widget.product.baseUnit}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
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
                : const Text('Simpan Tambahan Stok', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
