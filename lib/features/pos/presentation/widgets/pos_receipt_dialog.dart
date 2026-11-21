import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_text_formatter.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_thermal_formatter.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_receipt_paper_card.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_thermal_print_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/whatsapp_phone_input_dialog.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_settings_sheet.dart';

class PosReceiptDialog extends ConsumerWidget {
  final SaleModel sale;
  final String storeName;
  final String? cashierName;
  final String? customerPhone;
  final String? storeAddress;
  final String? storePhone;

  const PosReceiptDialog({
    super.key,
    required this.sale,
    required this.storeName,
    this.cashierName,
    this.customerPhone,
    this.storeAddress,
    this.storePhone,
  });

  static Future<void> show(
    BuildContext context, {
    required SaleModel sale, required String storeName,
    String? cashierName, String? customerPhone, String? storeAddress, String? storePhone,
  }) {
    return showDialog<void>(
      context: context, barrierDismissible: false,
      builder: (context) => PosReceiptDialog(
        sale: sale, storeName: storeName, cashierName: cashierName,
        customerPhone: customerPhone, storeAddress: storeAddress, storePhone: storePhone,
      ),
    );
  }

  String? get _effectivePhone => (customerPhone != null && customerPhone!.trim().isNotEmpty)
      ? customerPhone!.trim()
      : (sale.customerPhone != null && sale.customerPhone!.trim().isNotEmpty
          ? sale.customerPhone!.trim()
          : null);

  String _getThermalReceiptText(AppPreferences prefs) => ReceiptThermalFormatter.formatThermalReceipt(
        sale: sale, storeName: storeName, storeAddress: storeAddress,
        storePhone: storePhone, cashierName: cashierName, customerPhone: _effectivePhone, prefs: prefs,
      );

  String _getWhatsAppReceiptText(AppPreferences prefs) => ReceiptTextFormatter.formatReceipt(
        sale: sale, storeName: storeName, cashierName: cashierName, customerName: sale.customerName,
        customerPhone: _effectivePhone, storeAddress: storeAddress, storePhone: storePhone, prefs: prefs, forWhatsApp: true,
      );

  void _copyReceiptText(BuildContext context, AppPreferences prefs) {
    Clipboard.setData(ClipboardData(text: _getThermalReceiptText(prefs)));
    HapticFeedback.lightImpact();
    AppToast.showSuccess(context, 'Teks struk berhasil disalin ke clipboard');
  }

  Future<void> _handleSendWhatsApp(BuildContext context, AppPreferences prefs) async {
    final receiptText = _getWhatsAppReceiptText(prefs);
    final phone = _effectivePhone;

    if (phone != null && phone.isNotEmpty) {
      HapticFeedback.lightImpact();
      AppToast.showInfo(context, 'Membuka WhatsApp ke $phone...');
      final launched = await WhatsAppService.sendReceipt(phone: phone, message: receiptText);
      if (!launched && context.mounted) {
        AppToast.showWarning(context, 'Tidak dapat membuka WhatsApp. Teks nota telah disalin.');
        Clipboard.setData(ClipboardData(text: receiptText));
      }
      return;
    }
    WhatsAppPhoneInputDialog.show(context, receiptText: receiptText);
  }

  void _handlePrintThermal(BuildContext context, AppPreferences prefs) {
    HapticFeedback.lightImpact();
    final bytes = ReceiptThermalFormatter.generateEscPosBytes(
      sale: sale, storeName: storeName, storeAddress: storeAddress,
      storePhone: storePhone, cashierName: cashierName, customerPhone: _effectivePhone, prefs: prefs,
    );
    PosThermalPrintDialog.show(context, prefs: prefs, byteCount: bytes.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final thermalText = _getThermalReceiptText(prefs);
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: mediaQuery.size.height * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaksi Berhasil!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Nota: ${sale.invoiceNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
                      tooltip: 'Atur Struk & Printer',
                      onPressed: () => ThermalPrinterSettingsSheet.show(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.print_outlined, size: 14, color: Color(0xFF0F766E)),
                            const SizedBox(width: 6),
                            Text(
                              'Format: Kertas ${prefs.printerPaperWidth}mm • ${prefs.printerColumnWidth} Kolom • ESC/POS',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                            ),
                          ],
                        ),
                      ),
                      PosReceiptPaperCard(thermalText: thermalText),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handlePrintThermal(context, prefs),
                        icon: const Icon(Icons.print_rounded, size: 17),
                        label: Text(
                          'Cetak Thermal (${prefs.printerPaperWidth}mm ESC/POS)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyReceiptText(context, prefs),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleSendWhatsApp(context, prefs),
                            icon: const Icon(Icons.send_rounded, size: 14),
                            label: const Text('Kirim WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => ThermalPrinterSettingsSheet.show(context),
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          tooltip: 'Atur Header/Footer & Kertas',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF334155),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'TRANSAKSI BARU',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
