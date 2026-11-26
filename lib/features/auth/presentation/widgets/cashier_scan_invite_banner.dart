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
      title: 'Scan QR Toko',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleScan(context, ref),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 17, color: Color(0xFF0D9488)),
              SizedBox(width: 8),
              Text(
                'Kasir? Scan QR Toko',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F766E),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
