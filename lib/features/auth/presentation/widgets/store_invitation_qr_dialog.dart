import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';

class StoreInvitationQrDialog extends StatelessWidget {
  final StoreModel store;

  const StoreInvitationQrDialog({super.key, required this.store});

  static void show(BuildContext context, {required StoreModel store}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => StoreInvitationQrDialog(store: store),
    );
  }

  String _buildPayload() {
    return jsonEncode({
      'type': 'tokona_store_invite',
      'store_id': store.id,
      'store_name': store.name,
      'store_address': store.address ?? '',
      'store_phone': store.phone ?? '',
    });
  }

  Future<void> _downloadQrCode(BuildContext context, String payload) async {
    try {
      HapticFeedback.lightImpact();
      final painter = QrPainter(
        data: payload,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF0F172A),
        emptyColor: Colors.white,
      );
      final byteData = await painter.toImageData(600, format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Gagal membuat gambar QR');

      final bytes = byteData.buffer.asUint8List();

      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (downloadDir.existsSync()) targetDir = downloadDir;
      }
      targetDir ??= await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();

      final safeName = store.name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final fileName = 'QR_Undangan_${safeName}.png';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        AppToast.showSuccess(context, 'Barcode berhasil didownload: $fileName');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'Gagal mengunduh barcode: $e');
      }
    }
  }

  Future<void> _shareToWhatsApp(BuildContext context, String payload) async {
    final message = '''
*UNDANGAN KASIR TOKO - TOKONA POS*
Toko: *${store.name}*
Alamat: ${store.address ?? '-'}

_Buka aplikasi Tokona di HP Kasir, lalu scan QR Toko ini untuk langsung membuat akun kasir._
Kode Toko:
$payload
''';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) AppToast.showError(context, 'Tidak dapat membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = _buildPayload();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QR Undangan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text(store.name, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                gapless: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(9)),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 15, color: AppColors.primary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pengguna baru cukup scan QR ini untuk langsung membuat akun kasirnya sendiri',
                      style: TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadQrCode(context, payload),
                icon: const Icon(Icons.download_rounded, size: 17, color: Colors.white),
                label: const Text('Download QR Code', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: payload));
                      AppToast.showSuccess(context, 'Data pairing disalin');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('Salin Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareToWhatsApp(context, payload),
                    icon: const Icon(Icons.share_rounded, size: 15, color: Color(0xFF16A34A)),
                    label: const Text('Kirim WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                      backgroundColor: const Color(0xFFF0FDF4),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
