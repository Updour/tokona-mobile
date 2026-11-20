import 'package:flutter/material.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class SettingsStockWaTab extends StatefulWidget {
  final AppPreferences draft;
  final TextEditingController minStockController;
  final TextEditingController waBookingController;
  final TextEditingController waKasbonController;
  final TextEditingController waOrderController;
  final ValueChanged<AppPreferences> onChanged;

  const SettingsStockWaTab({
    super.key,
    required this.draft,
    required this.minStockController,
    required this.waBookingController,
    required this.waKasbonController,
    required this.waOrderController,
    required this.onChanged,
  });

  @override
  State<SettingsStockWaTab> createState() => _SettingsStockWaTabState();
}

class _SettingsStockWaTabState extends State<SettingsStockWaTab> {
  int _selectedTemplate = 0; // 0: Booking, 1: Kasbon, 2: Order/Beli

  TextEditingController get _activeController {
    if (_selectedTemplate == 0) return widget.waBookingController;
    if (_selectedTemplate == 1) return widget.waKasbonController;
    return widget.waOrderController;
  }

  List<String> get _activeVars {
    if (_selectedTemplate == 0) {
      return const ['{nama}', '{toko}', '{daftar_barang}', '{total}', '{jadwal}', '{metode}'];
    }
    if (_selectedTemplate == 1) {
      return const ['{nama}', '{toko}', '{no_nota}', '{tanggal}', '{jatuh_tempo}', '{total}'];
    }
    return const ['{nama}', '{toko}', '{barang}', '{jumlah}', '{satuan}', '{harga}', '{total}'];
  }

  void _insertPlaceholder(String token) {
    final ctrl = _activeController;
    final sel = ctrl.selection;
    final text = ctrl.text;
    final start = sel.isValid && sel.start >= 0 ? sel.start : text.length;
    final end = sel.isValid && sel.end >= 0 ? sel.end : text.length;
    final nextText = text.replaceRange(start, end, token);
    ctrl.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    _syncTemplateChange(nextText);
  }

  void _syncTemplateChange(String value) {
    if (_selectedTemplate == 0) {
      widget.onChanged(widget.draft.copyWith(waBookingTemplate: value));
    } else if (_selectedTemplate == 1) {
      widget.onChanged(widget.draft.copyWith(waKasbonTemplate: value));
    } else {
      widget.onChanged(widget.draft.copyWith(waOrderTemplate: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 14),
      children: [
        _sectionTitle('Minimum Stok Baru', Icons.inventory_2_rounded, const Color(0xFFD97706)),
        _card(
          children: [
            TextField(
              controller: widget.minStockController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Batas Peringatan Stok Menipis',
                hintText: 'Default saat tambah produk',
                suffixText: 'unit',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                widget.onChanged(widget.draft.copyWith(defaultMinStockAlert: parsed < 0 ? 0 : parsed));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionTitle('Format Pesan WhatsApp', Icons.chat_rounded, const Color(0xFF0D9488)),
        _card(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  _templateSegment('Booking', 0),
                  _templateSegment('Kasbon', 1),
                  _templateSegment('Order Beli', 2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sentuh tag untuk menyisipkan variabel:',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: _activeVars.map((token) {
                return InkWell(
                  onTap: () => _insertPlaceholder(token),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
                    ),
                    child: Text(
                      token,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _activeController,
              maxLines: 6,
              style: const TextStyle(fontSize: 11.5, height: 1.35),
              decoration: InputDecoration(
                labelText: _selectedTemplate == 0
                    ? 'Format Pengingat Booking'
                    : (_selectedTemplate == 1 ? 'Format Tagihan Kasbon' : 'Format Order Beli'),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: _syncTemplateChange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _templateSegment(String label, int index) {
    final active = _selectedTemplate == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTemplate = index),
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: active
                ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}
