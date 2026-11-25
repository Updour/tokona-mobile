import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class WaDynamicOrderCalcCard extends StatefulWidget {
  final String recipientName;
  final String storeName;
  final String template;
  final ValueChanged<String> onApplyMessage;

  const WaDynamicOrderCalcCard({
    super.key,
    required this.recipientName,
    required this.storeName,
    required this.template,
    required this.onApplyMessage,
  });

  @override
  State<WaDynamicOrderCalcCard> createState() => _WaDynamicOrderCalcCardState();
}

class _WaDynamicOrderCalcCardState extends State<WaDynamicOrderCalcCard> {
  final _itemCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController(text: 'Pcs');
  final _priceCtrl = TextEditingController(text: '0');

  double get _qty => double.tryParse(_qtyCtrl.text.trim().replaceAll(',', '.')) ?? 0;
  double get _price => CurrencyFormatter.parse(_priceCtrl.text);
  double get _total => _qty * _price;

  @override
  void dispose() {
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final qtyStr = _qty == _qty.roundToDouble() ? _qty.toInt().toString() : _qty.toString();
    final barang = _itemCtrl.text.trim().isEmpty ? 'Pesanan Barang' : _itemCtrl.text.trim();
    final satuan = _unitCtrl.text.trim().isEmpty ? 'Pcs' : _unitCtrl.text.trim();
    final rendered = AppPreferences.renderTemplate(widget.template, {
      'nama': widget.recipientName,
      'toko': widget.storeName,
      'barang': barang,
      'jumlah': qtyStr,
      'satuan': satuan,
      'harga': CurrencyFormatter.format(_price),
      'total': CurrencyFormatter.format(_total),
    });
    widget.onApplyMessage(rendered);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_rounded, size: 15, color: Color(0xFF047857)),
              SizedBox(width: 6),
              Text(
                'Hitung Jumlah & Total Beli Dinamis',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _itemCtrl,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Nama Barang',
              hintText: 'Beras 5kg / Minyak Goreng',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _unitCtrl,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Satuan',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyTextInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Beli', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.format(_total),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                label: const Text('Terapkan ke Pesan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
