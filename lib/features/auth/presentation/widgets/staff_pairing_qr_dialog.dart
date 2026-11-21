import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

class StaffPairingQrDialog extends StatelessWidget {
  final UserModel staff;
  final StoreModel store;

  const StaffPairingQrDialog({
    super.key,
    required this.staff,
    required this.store,
  });

  static void show(BuildContext context, {required UserModel staff, required StoreModel store}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => StaffPairingQrDialog(staff: staff, store: store),
    );
  }

  String _buildPairingPayload() {
    return jsonEncode({
      'type': 'tokona_pairing',
      'store_id': store.id,
      'store_name': store.name,
      'store_address': store.address ?? '',
      'store_phone': store.phone ?? '',
      'user_id': staff.id,
      'username': staff.username,
      'full_name': staff.fullName,
      'password_hash': staff.passwordHash,
      'salt': staff.salt,
      'role': staff.role.key,
    });
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    final payload = _buildPairingPayload();
    final message = '''
*KREDENSIAL KASIR TOKONA*
Toko: ${store.name}
Nama: ${staff.fullName}
Username: *${staff.username}*
Role: ${staff.role.label}

_Gunakan menu "Scan QR Toko" di aplikasi Tokona untuk pairing instan offline._
Kode Pairing:
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
    final payload = _buildPairingPayload();

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
                  child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QR Pairing Kasir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('${staff.fullName} (${staff.role.label})', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(9)),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 15, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Scan dari HP Kasir (100% Offline tanpa kuota internet)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: payload));
                      AppToast.showSuccess(context, 'Data pairing disalin ke clipboard');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareToWhatsApp(context),
                    icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                    label: const Text('Kirim WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
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
