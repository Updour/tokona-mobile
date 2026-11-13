import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/purchase/data/services/courier_service.dart';

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
  late final TextEditingController _courierController;
  late final TextEditingController _resiController;
  List<String> _couriers = CourierService.defaultCouriers;

  @override
  void initState() {
    super.initState();
    final raw = widget.currentResi ?? '';
    _courierController = TextEditingController(text: _parseCourier(raw));
    _resiController = TextEditingController(text: _parseResiOnly(raw));
    _loadCouriers();
  }

  Future<void> _loadCouriers() async {
    final list = await CourierService.getCouriers();
    if (mounted) setState(() => _couriers = list);
  }

  String _parseCourier(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final bracket = RegExp(r'^\[([^\]]+)\]').firstMatch(trimmed);
    if (bracket != null) return bracket.group(1)?.trim() ?? '';
    final dash = RegExp(r'^([A-Za-z0-9\s&]+)\s*-\s*([A-Za-z0-9]+)$').firstMatch(trimmed);
    if (dash != null) return dash.group(1)?.trim() ?? '';
    return '';
  }

  String _parseResiOnly(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final bracket = RegExp(r'^\[[^\]]+\]\s*(.*)$').firstMatch(trimmed);
    if (bracket != null) return bracket.group(1)?.trim() ?? '';
    final dash = RegExp(r'^[A-Za-z0-9\s&]+\s*-\s*([A-Za-z0-9]+)$').firstMatch(trimmed);
    if (dash != null) return dash.group(2)?.trim() ?? '';
    return trimmed;
  }

  @override
  void dispose() {
    _courierController.dispose();
    _resiController.dispose();
    super.dispose();
  }

  void _selectCourier(String courier) {
    final current = _courierController.text.trim();
    if (current.toLowerCase() == courier.toLowerCase()) {
      _courierController.clear();
    } else {
      _courierController.text = courier;
    }
    setState(() {});
  }

  Future<void> _handleDeleteCourier(String courier) async {
    await CourierService.deleteCourier(courier);
    _loadCouriers();
  }

  void _submit() {
    final courier = _courierController.text.trim();
    final resi = _resiController.text.trim();

    if (courier.isNotEmpty) {
      CourierService.saveCourier(courier);
    }

    String result;
    if (courier.isNotEmpty && resi.isNotEmpty) {
      result = '[$courier] $resi';
    } else if (resi.isNotEmpty) {
      result = resi;
    } else if (courier.isNotEmpty) {
      result = '[$courier]';
    } else {
      result = '';
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final currentCourier = _courierController.text.trim().toLowerCase();

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
            TextField(
              controller: _courierController,
              decoration: InputDecoration(
                labelText: 'Ekspedisi / Kurir (Bebas / Dinamis)',
                hintText: 'Misal: J&T Cargo, SPX, JNE, Indah Cargo...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.local_shipping_outlined, size: 20),
                suffixIcon: _courierController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _courierController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _couriers.map((c) {
                  final isSelected = currentCourier == c.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(c, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F766E),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _selectCourier(c),
                      onDeleted: () => _handleDeleteCourier(c),
                      deleteIcon: const Icon(Icons.close_rounded, size: 13),
                      deleteIconColor: isSelected ? Colors.white70 : AppColors.textMuted,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _resiController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Nomor Resi / AWB',
                hintText: 'Contoh: JTC8291038491 / SPXID02918',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20),
                suffixIcon: _resiController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _resiController.clear();
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
                  onPressed: _submit,
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
