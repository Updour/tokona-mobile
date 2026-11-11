import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';

class EditPurchaseItemDialog extends StatefulWidget {
  final CreatePurchaseItemDto item;

  const EditPurchaseItemDialog({
    super.key,
    required this.item,
  });

  static Future<CreatePurchaseItemDto?> show(
    BuildContext context, {
    required CreatePurchaseItemDto item,
  }) {
    return showDialog<CreatePurchaseItemDto>(
      context: context,
      builder: (_) => EditPurchaseItemDialog(item: item),
    );
  }

  @override
  State<EditPurchaseItemDialog> createState() => _EditPurchaseItemDialogState();
}

class _EditPurchaseItemDialogState extends State<EditPurchaseItemDialog> {
  late final TextEditingController _qtyController;
  late final TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.item.quantity.toStringAsFixed(widget.item.quantity.truncateToDouble() == widget.item.quantity ? 0 : 2),
    );
    _costController = TextEditingController(
      text: CurrencyFormatter.formatNumber(widget.item.unitCost),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    super.dispose();
  }

  double get _currentQty => double.tryParse(_qtyController.text) ?? 0.0;
  double get _currentCost => CurrencyFormatter.parse(_costController.text);
  double get _currentSubtotal => _currentQty * _currentCost;

  void _submit() {
    if (_currentQty <= 0) {
      AppToast.showWarning(context, 'Jumlah barang harus lebih dari 0');
      return;
    }
    if (_currentCost < 0) {
      AppToast.showWarning(context, 'Harga beli tidak boleh negatif');
      return;
    }

    final updated = widget.item.copyWith(
      quantity: _currentQty,
      unitCost: _currentCost,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ubah Item Belanja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  widget.item.productName,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Satuan: ${widget.item.unitName}'
                '${widget.item.conversionFactor > 1 ? " (${widget.item.conversionFactor.toStringAsFixed(0)} unit dasar)" : ""}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Jumlah (${widget.item.unitName})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Harga Beli Satuan',
                prefixText: 'Rp ',
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal Baru:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(
                    CurrencyFormatter.format(_currentSubtotal),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
