import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class PosThermalPrintDialog {
  PosThermalPrintDialog._();

  static void show(
    BuildContext context, {
    required AppPreferences prefs,
    required int byteCount,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.print_rounded, color: Color(0xFF0F766E), size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Cetak Struk ESC/POS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perintah ESC/POS ($byteCount bytes) siap dikirim ke printer:',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Format Kertas: ${prefs.printerPaperWidth}mm (Lebar)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('• Resolusi Kolom: ${prefs.printerColumnWidth} Karakter/Baris', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('• Perintah Driver: POS/ESC Command Set', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('• Auto-Cut: ${prefs.printerAutoCut ? "Aktif (GS V 66 0)" : "Nonaktif"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('• Spasi Feed: ${prefs.printerFeedLines} baris kosong', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppToast.showSuccess(context, 'Struk berhasil dikirim ke printer thermal (${prefs.printerPaperWidth}mm)');
            },
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Kirim ke Printer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
