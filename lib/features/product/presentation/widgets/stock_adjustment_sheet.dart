import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/product/data/repositories/stock_repository.dart';
import 'package:tokona/features/product/domain/dtos/create_stock_adjustment_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/product/presentation/widgets/stock_projection_card.dart';
import 'package:tokona/features/product/presentation/widgets/stock_reason_selector.dart';

class StockAdjustmentSheet extends ConsumerStatefulWidget {
  final ProductModel product;

  const StockAdjustmentSheet({
    super.key,
    required this.product,
  });

  static Future<bool?> show(BuildContext context, {required ProductModel product}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockAdjustmentSheet(product: product),
    );
  }

  @override
  ConsumerState<StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends ConsumerState<StockAdjustmentSheet> {
  final _qtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  String _type = 'out';
  String _reason = 'damaged';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentStock => widget.product.stockBase;

  double get _inputQty => CurrencyFormatter.parse(_qtyController.text);

  double get _calculatedStock {
    if (_type == 'in') {
      return _currentStock + _inputQty;
    }
    return _currentStock - _inputQty;
  }

  Future<void> _submit() async {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) {
      AppToast.showError(context, 'Toko aktif tidak ditemukan');
      return;
    }

    if (_inputQty <= 0) {
      AppToast.showError(context, 'Jumlah penyesuaian harus lebih dari 0');
      return;
    }

    if (_type == 'out' && _calculatedStock < 0) {
      AppToast.showError(context, 'Stok akhir tidak boleh kurang dari 0');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dto = CreateStockAdjustmentDto(
        storeId: storeId,
        productId: widget.product.id,
        adjustmentQty: _inputQty,
        type: _type,
        reason: _reason,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await ref.read(stockRepositoryProvider).adjustStock(dto);
      await ref.read(productListProvider.notifier).loadProducts(storeId);

      if (mounted) {
        AppToast.showSuccess(context, 'Penyesuaian stok berhasil disimpan');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Gagal menyesuaikan stok: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penyesuaian & Opname Stok', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(widget.product.name, style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 14),
              StockReasonSelector(
                selectedReason: _reason,
                type: _type,
                onReasonChanged: (val) => setState(() => _reason = val),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _qtyController,
                label: 'Jumlah Penyesuaian (${widget.product.baseUnit})',
                hint: '1',
                keyboardType: TextInputType.number,
                prefixIcon: _type == 'out' ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                inputFormatters: [CurrencyTextInputFormatter()],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              StockProjectionCard(
                currentStock: _currentStock,
                inputQty: _inputQty,
                calculatedStock: _calculatedStock,
                type: _type,
                unit: widget.product.baseUnit,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _notesController,
                label: 'Catatan (Opsional)',
                hint: 'Contoh: Kemasan sobek saat bongkar muat',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'out' ? AppColors.error : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _type == 'out' ? 'KURANGI STOK' : 'TAMBAHKAN STOK',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _type = 'out';
                _reason = 'damaged';
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _type == 'out' ? const Color(0xFFFEE2E2) : AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _type == 'out' ? AppColors.error : AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle_rounded, size: 16, color: _type == 'out' ? AppColors.error : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Kurangi Stok (-)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _type == 'out' ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _type = 'in';
                _reason = 'opname_in';
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _type == 'in' ? const Color(0xFFDCFCE7) : AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _type == 'in' ? const Color(0xFF15803D) : AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_rounded, size: 16, color: _type == 'in' ? const Color(0xFF15803D) : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Tambah Stok (+)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _type == 'in' ? const Color(0xFF15803D) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
