import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class InputTrackingNumberDialog extends StatefulWidget {
  final String? currentResi;
  final String invoiceNumber;
  final String? supplierName;
  final bool isUpdateOnly;

  const InputTrackingNumberDialog({
    super.key,
    this.currentResi,
    required this.invoiceNumber,
    this.supplierName,
    this.isUpdateOnly = false,
  });

  static Future<String?> show(
    BuildContext context, {
    String? currentResi,
    required String invoiceNumber,
    String? supplierName,
    bool isUpdateOnly = false,
  }) {
    return showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => InputTrackingNumberDialog(
        currentResi: currentResi,
        invoiceNumber: invoiceNumber,
        supplierName: supplierName,
        isUpdateOnly: isUpdateOnly,
      ),
    );
  }

  @override
  State<InputTrackingNumberDialog> createState() => _InputTrackingNumberDialogState();
}

class _InputTrackingNumberDialogState extends State<InputTrackingNumberDialog> {
  late final TextEditingController _controller;
  static const List<String> _couriers = ['SPX', 'J&T', 'JNE', 'SiCepat', 'Anteraja', 'Kurir Toko'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentResi ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyCourierPrefix(String courier) {
    final cur = _controller.text.trim();
    final regex = RegExp(r'^\[[^\]]+\]\s*');
    final clean = cur.replaceFirst(regex, '');
    _controller.text = '[$courier] $clean';
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF0F766E), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isUpdateOnly ? 'Ubah No. Resi' : 'Input No. Resi Pengiriman',
                        style: AppTypography.headingSmall.copyWith(fontSize: 15),
                      ),
                      Text(
                        widget.supplierName != null ? '${widget.invoiceNumber} • ${widget.supplierName}' : widget.invoiceNumber,
                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Pilih Ekspedisi / Kurir Cepat:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _couriers.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(c, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      onPressed: () => _applyCourierPrefix(c),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Nomor Resi / AWB',
                hintText: 'Contoh: [SPX] SPXID048123490',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ),
                if (!widget.isUpdateOnly) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Tanpa Resi', style: TextStyle(color: Color(0xFF0F766E), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final resi = _controller.text.trim();
                    Navigator.of(context).pop(resi);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    widget.isUpdateOnly ? 'Simpan' : 'Kirim Paket',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
