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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF99F6E4), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 16, color: Color(0xFF0F766E)),
              SizedBox(width: 5),
              Text(
                'Scan QR',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
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
