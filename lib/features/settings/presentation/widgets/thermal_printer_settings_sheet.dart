import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class ThermalPrinterSettingsSheet extends ConsumerStatefulWidget {
  const ThermalPrinterSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThermalPrinterSettingsSheet(),
    );
  }

  @override
  ConsumerState<ThermalPrinterSettingsSheet> createState() => _ThermalPrinterSettingsSheetState();
}

class _ThermalPrinterSettingsSheetState extends ConsumerState<ThermalPrinterSettingsSheet> {
  late int _paperWidth;
  late bool _autoPrint;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(appPreferencesProvider);
    _paperWidth = prefs.printerPaperWidth;
    _autoPrint = prefs.autoPrintReceipt;
    _footerController = TextEditingController(text: prefs.printerFooterMessage);
  }

  @override
  void dispose() {
    _footerController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final updated = ref.read(appPreferencesProvider).copyWith(
          printerPaperWidth: _paperWidth,
          autoPrintReceipt: _autoPrint,
          printerFooterMessage: _footerController.text.trim(),
        );
    ref.read(appPreferencesProvider.notifier).save(updated);
    AppToast.showSuccess(context, 'Pengaturan printer thermal berhasil disimpan');
    Navigator.of(context).pop();
  }

  void _showTestPrintPreview() {
    final store = ref.read(authProvider).currentStore;
    final storeName = store?.name ?? 'TOKO BERKAH';
    final width = _paperWidth;
    final col = width == 80 ? 48 : 32;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F766E), size: 20),
            const SizedBox(width: 8),
            Text('Simulasi Struk ${width}mm', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SingleChildScrollView(
            child: Text(
              '${"=" * col}\n'
              '${storeName.toUpperCase()}\n'
              '${store?.address ?? "Jl. Raya Pertokoan No. 1"}\n'
              '${"=" * col}\n'
              'No: TKN-TEST-001\n'
              'Tgl: 19/11/2026 15:30\n'
              'Kasir: Kasir Toko\n'
              '${"-" * col}\n'
              '1. Beras Premium 5kg\n'
              '   1 x Rp 75.000       Rp 75.000\n'
              '2. Minyak Goreng 2L\n'
              '   1 x Rp 34.000       Rp 34.000\n'
              '${"-" * col}\n'
              'Subtotal               Rp 109.000\n'
              'TOTAL                  Rp 109.000\n'
              'Bayar (TUNAI)          Rp 110.000\n'
              'Kembalian                Rp 1.000\n'
              '${"=" * col}\n'
              '${_footerController.text}\n'
              'Simpan struk ini sebagai bukti\n\n',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.35, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              AppToast.showSuccess(context, 'Perintah ESC/POS dikirim ke modul printer');
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Kirim ke Printer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.print_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Printer Struk Kasir (Thermal ESC/POS)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Format cetak 58mm & 80mm Bluetooth/USB', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: [
                const Text('Lebar Kertas Struk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaperSizeOption(
                        title: '58 mm (Standard)',
                        subtitle: '32 Kolom (Printer Mini)',
                        value: 58,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPaperSizeOption(
                        title: '80 mm (Lebar)',
                        subtitle: '48 Kolom (Printer Kasir Besar)',
                        value: 80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _autoPrint,
                  title: const Text('Cetak Otomatis Setelah Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Langsung print struk saat pembayaran kasir sukses', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _autoPrint = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _footerController,
                  decoration: InputDecoration(
                    labelText: 'Pesan Kaki Struk (Footer)',
                    hintText: 'Contoh: Terima kasih atas kunjungan Anda!',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showTestPrintPreview,
                  icon: const Icon(Icons.preview_rounded, size: 16, color: Color(0xFF0F766E)),
                  label: const Text('Uji Simulasi Struk (Test Print)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF0F766E))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF99F6E4)),
                    backgroundColor: const Color(0xFFF0FDFA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan Pengaturan Printer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperSizeOption({required String title, required String subtitle, required int value}) {
    final isSelected = _paperWidth == value;
    return InkWell(
      onTap: () => setState(() => _paperWidth = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0), width: isSelected ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
