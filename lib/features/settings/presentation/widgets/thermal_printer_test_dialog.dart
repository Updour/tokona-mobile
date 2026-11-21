import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';

class ThermalPrinterTestDialog {
  ThermalPrinterTestDialog._();

  static void show(
    BuildContext context, {
    required int paperWidth,
    required int columnWidth,
    required int feedLines,
    required bool autoCut,
    required String sampleText,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
            const SizedBox(width: 8),
            Text('Kirim ke Printer ${paperWidth}mm', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perintah ESC/POS siap dialirkan ke printer via Bluetooth/USB:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Text(
                '• Lebar Kertas : ${paperWidth}mm (384 dots)\n'
                '• Karakter/Line: $columnWidth Kolom Font A\n'
                '• Feed Akhir   : $feedLines baris kosong\n'
                '• Auto Cut     : ${autoCut ? "Aktif" : "Nonaktif"}',
                style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: sampleText));
              Navigator.pop(ctx);
              AppToast.showSuccess(context, 'Teks struk sampel disalin ke clipboard');
            },
            child: const Text('Salin Teks'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              AppToast.showSuccess(context, 'Perintah ESC/POS berhasil dikirim ke printer receipt');
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Cetak Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
