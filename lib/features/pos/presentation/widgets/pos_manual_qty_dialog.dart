import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PosManualQtyDialog extends StatefulWidget {
  final String productName;
  final String unitName;
  final double initialQty;
  final double maxStock;

  const PosManualQtyDialog({
    super.key,
    required this.productName,
    required this.unitName,
    required this.initialQty,
    required this.maxStock,
  });

  static Future<double?> show(
    BuildContext context, {
    required String productName,
    required String unitName,
    required double initialQty,
    required double maxStock,
  }) {
    return showDialog<double>(
      context: context,
      builder: (_) => PosManualQtyDialog(
        productName: productName,
        unitName: unitName,
        initialQty: initialQty,
        maxStock: maxStock,
      ),
    );
  }

  @override
  State<PosManualQtyDialog> createState() => _PosManualQtyDialogState();
}

class _PosManualQtyDialogState extends State<PosManualQtyDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialQty == widget.initialQty.roundToDouble()
          ? widget.initialQty.toInt().toString()
          : widget.initialQty.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final val = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (val == null || val <= 0) {
      setState(() => _errorText = 'Jumlah harus lebih dari 0');
      return;
    }
    if (val > widget.maxStock) {
      setState(() => _errorText = 'Maksimal stok tersedia ${widget.maxStock.toStringAsFixed(0)} ${widget.unitName}');
      return;
    }
    Navigator.of(context).pop(val);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Jumlah (Qty)', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
                      Text(widget.productName, style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: 'Jumlah (${widget.unitName})',
                hintText: 'Masukkan jumlah...',
                errorText: _errorText,
                suffixText: widget.unitName,
                helperText: 'Stok tersedia: ${widget.maxStock.toStringAsFixed(0)} ${widget.unitName}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Terapkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
