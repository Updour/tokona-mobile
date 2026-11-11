import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/calendar_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';

class HoldCartDialog extends ConsumerStatefulWidget {
  final String? initialCustomerName;

  const HoldCartDialog({super.key, this.initialCustomerName});

  static Future<bool?> show(BuildContext context, {String? initialCustomerName}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => HoldCartDialog(initialCustomerName: initialCustomerName),
    );
  }

  @override
  ConsumerState<HoldCartDialog> createState() => _HoldCartDialogState();
}

class _HoldCartDialogState extends ConsumerState<HoldCartDialog> {
  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  String _deliveryMethod = 'pickup';
  DateTime? _plannedDate;
  bool _addToCalendar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCustomerName ?? '');
    _plannedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _plannedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFD97706))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _plannedDate = picked);
  }

  void _handleHold() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return AppToast.showWarning(context, 'Keranjang masih kosong');

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final note = _noteController.text.trim();

    ref.read(heldCartProvider.notifier).holdCart(
          cart: cart,
          customerName: name.isNotEmpty ? name : 'Pelanggan Umum',
          customerPhone: phone.isNotEmpty ? phone : null,
          deliveryMethod: _deliveryMethod,
          plannedDate: _plannedDate,
          note: note.isNotEmpty ? note : null,
        );

    ref.read(cartProvider.notifier).clearCart();
    Navigator.of(context).pop(true);

    if (_addToCalendar && _plannedDate != null) {
      final methodText = _deliveryMethod == 'delivery' ? 'Dianterin' : 'Diambil di Rumah/Toko';
      final title = 'Pesanan $methodText: ${name.isNotEmpty ? name : "Pelanggan"}';
      final itemsSummary = cart.items.map((i) => "${i.product.name} (${i.quantity.toStringAsFixed(0)})").join(", ");
      await CalendarService.addEventToCalendar(title: title, description: 'Barang: $itemsSummary${note.isNotEmpty ? "\nCatatan: $note" : ""}', plannedDate: _plannedDate!);
    }

    AppToast.showSuccess(context, 'Pesanan & stok berhasil diamankan');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.bookmark_add_rounded, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking / Tahan Pesanan', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
                    Text('Amankan stok barang agar tidak terjual', style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMethodSelector(),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                hintText: 'Contoh: Bu Siti / Mas Budi',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'No. WhatsApp Pelanggan (Opsional)',
                hintText: '0812xxxx (Untuk kirim pengingat)',
                prefixIcon: Icon(Icons.phone_outlined, size: 18),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            _buildDatePickerTile(),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                labelText: _deliveryMethod == 'delivery' ? 'Alamat Antar / Catatan' : 'Catatan Tambahan',
                hintText: _deliveryMethod == 'delivery' ? 'Contoh: Jl. Mawar No. 4' : 'Contoh: Titip sampai sore',
                prefixIcon: const Icon(Icons.edit_note_rounded, size: 18),
                isDense: true,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _addToCalendar = !_addToCalendar),
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _addToCalendar,
                      activeColor: const Color(0xFFD97706),
                      onChanged: (v) => setState(() => _addToCalendar = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Pasang pengingat di Kalender HP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 9)),
                    child: const Text('Batal', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleHold,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    child: const Text('Simpan Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _methodTile('Diambil di Rumah/Toko', Icons.storefront_rounded, _deliveryMethod == 'pickup', () {
            setState(() => _deliveryMethod = 'pickup');
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _methodTile('Dianterin (COD)', Icons.two_wheeler_rounded, _deliveryMethod == 'delivery', () {
            setState(() => _deliveryMethod = 'delivery');
          }),
        ),
      ],
    );
  }

  Widget _methodTile(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3C7) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: isSelected ? const Color(0xFFD97706) : AppColors.border, width: isSelected ? 1.4 : 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? const Color(0xFFB45309) : AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 10.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFFB45309) : AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile() {
    final dateStr = _plannedDate != null ? DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_plannedDate!) : 'Pilih Hari/Tanggal';

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.event_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_deliveryMethod == 'delivery' ? 'Rencana Jadwal Antar' : 'Rencana Jadwal Ambil', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    Text(dateStr, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
