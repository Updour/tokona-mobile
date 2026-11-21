import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/cashier_self_register_sheet.dart';

class OfflinePairingSheet extends ConsumerStatefulWidget {
  const OfflinePairingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OfflinePairingSheet(),
    );
  }

  @override
  ConsumerState<OfflinePairingSheet> createState() => _OfflinePairingSheetState();
}

class _OfflinePairingSheetState extends ConsumerState<OfflinePairingSheet> {
  final _manualCodeController = TextEditingController();
  bool _isLoading = false;
  bool _showManualInput = false;

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _processPairing(String rawCode) async {
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final json = jsonDecode(trimmed) as Map<String, dynamic>;
      if (json['type'] == 'tokona_store_invite') {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context);
        CashierSelfRegisterSheet.show(context, storeData: json);
        return;
      }
      if (json['type'] != 'tokona_pairing' || json['store_id'] == null) {
        throw const FormatException('Format kode QR pairing tidak valid');
      }

      final success = await ref.read(authProvider.notifier).importPairingJson(trimmed);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        AppToast.showSuccess(context, 'Berhasil pairing dengan ${json['store_name'] ?? 'Toko'}');
        Navigator.pop(context);
      } else {
        final err = ref.read(authProvider).errorMessage ?? 'Gagal menghubungkan perangkat';
        AppToast.showError(context, err);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.showError(context, 'Data pairing tidak valid: ${e.toString().replaceFirst("FormatException: ", "")}');
    }
  }

  Future<void> _openCameraScanner() async {
    final scannedCode = await CameraBarcodeScanner.scan(
      context,
      title: 'Scan QR Pairing Toko',
    );
    if (scannedCode != null && scannedCode.isNotEmpty) {
      await _processPairing(scannedCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pairing Kasir Offline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('Hubungkan ke toko tanpa internet via QR Code', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF99F6E4), width: 0.8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.wifi_off_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HP Kasir dapat dihubungkan ke toko 100% offline. Buka menu "Manajemen Pengguna" di HP Pemilik Toko, lalu scan QR yang ditampilkan.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF0F766E), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _openCameraScanner,
              icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
              label: const Text('Buka Kamera Scanner QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _showManualInput = !_showManualInput),
              child: Text(
                _showManualInput ? 'Sembunyikan Input Manual' : 'Atau tempel teks kode pairing manual',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            if (_showManualInput) ...[
              const SizedBox(height: 6),
              TextField(
                controller: _manualCodeController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Tempel teks format JSON pairing di sini...',
                  hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _processPairing(_manualCodeController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Terapkan Data Pairing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
