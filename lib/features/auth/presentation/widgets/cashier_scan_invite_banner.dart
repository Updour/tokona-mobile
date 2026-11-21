import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/cashier_self_register_sheet.dart';

class CashierScanInviteBanner extends ConsumerWidget {
  const CashierScanInviteBanner({super.key});

  Future<void> _handleScan(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    final scannedCode = await CameraBarcodeScanner.scan(
      context,
      title: 'Scan QR Undangan / Pairing Toko',
    );
    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    try {
      final json = jsonDecode(scannedCode.trim()) as Map<String, dynamic>;
      if (json['type'] == 'tokona_store_invite') {
        if (context.mounted) {
          CashierSelfRegisterSheet.show(context, storeData: json);
        }
      } else if (json['type'] == 'tokona_pairing') {
        final success = await ref.read(authProvider.notifier).importPairingJson(scannedCode);
        if (context.mounted) {
          if (success) {
            AppToast.showSuccess(context, 'Berhasil pairing dengan ${json['store_name'] ?? 'Toko'}');
          } else {
            final err = ref.read(authProvider).errorMessage ?? 'Gagal menghubungkan perangkat';
            AppToast.showError(context, err);
          }
        }
      } else {
        if (context.mounted) {
          AppToast.showError(context, 'Format QR tidak dikenali sebagai undangan Tokona');
        }
      }
    } catch (_) {
      if (context.mounted) {
        AppToast.showError(context, 'Kode QR tidak berisi data Tokona yang valid');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleScan(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kasir / Karyawan Baru?',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        'Scan QR Toko untuk buat akun & langsung masuk',
                        style: TextStyle(color: Color(0xFFCCFBF1), fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
