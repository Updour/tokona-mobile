import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ThermalPrinterPaperTab extends StatelessWidget {
  final int paperWidth;
  final int columnWidth;
  final int feedLines;
  final bool autoPrint;
  final bool autoCut;
  final void Function(int paperWidth, int columnWidth) onPaperSizeSelected;
  final ValueChanged<int> onColumnWidthChanged;
  final ValueChanged<int> onFeedLinesChanged;
  final ValueChanged<bool> onAutoPrintChanged;
  final ValueChanged<bool> onAutoCutChanged;

  const ThermalPrinterPaperTab({
    super.key,
    required this.paperWidth,
    required this.columnWidth,
    required this.feedLines,
    required this.autoPrint,
    required this.autoCut,
    required this.onPaperSizeSelected,
    required this.onColumnWidthChanged,
    required this.onFeedLinesChanged,
    required this.onAutoPrintChanged,
    required this.onAutoCutChanged,
  });

  Widget _buildPaperSizeOption({
    required String title,
    required String subtitle,
    required int value,
    required bool recommended,
    required VoidCallback onSelect,
  }) {
    final isSelected = paperWidth == value;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            if (recommended) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                child: const Text('Printer Anda', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const Text(
          'Ukuran Kertas Thermal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildPaperSizeOption(
                title: '58 mm (Standard)',
                subtitle: '384 dots • 32 Kolom (Printer Anda)',
                value: 58,
                recommended: true,
                onSelect: () => onPaperSizeSelected(58, 32),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPaperSizeOption(
                title: '80 mm (Lebar)',
                subtitle: '576 dots • 48 Kolom (Desktop)',
                value: 80,
                recommended: false,
                onSelect: () => onPaperSizeSelected(80, 48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kerapatan Karakter (Kolom Per Baris)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(6)),
                    child: Text('$columnWidth Kolom', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Printer 58mm menggunakan standar 32 kolom agar nama barang dan harga tidak kocar-kacir.', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              Slider(
                value: columnWidth.toDouble(),
                min: 28,
                max: 48,
                divisions: 20,
                activeColor: AppColors.primary,
                label: '$columnWidth kolom',
                onChanged: (val) => onColumnWidthChanged(val.toInt()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jarak Potong Kertas (Feed Lines)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('$feedLines Baris Kosong', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Memberikan ruang kosong di akhir struk agar mudah disobek di pisau printer tanpa terpotong teks.', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4, 5].map((num) {
                  final isSelected = feedLines == num;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => onFeedLinesChanged(num),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1)),
                          ),
                          child: Center(
                            child: Text(
                              '$num',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: autoPrint,
          title: const Text('Cetak Otomatis Saat Selesai Bayar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          subtitle: const Text('Langsung print struk saat transaksi kasir berhasil', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          activeColor: AppColors.primary,
          onChanged: onAutoPrintChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: autoCut,
          title: const Text('Kirim Perintah Potong Kertas (Auto-Cut)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          subtitle: const Text('Untuk printer thermal yang dilengkapi pemotong pisau otomatis', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          activeColor: AppColors.primary,
          onChanged: onAutoCutChanged,
        ),
      ],
    );
  }
}
