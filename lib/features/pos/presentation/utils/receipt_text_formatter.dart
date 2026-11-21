import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_thermal_formatter.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class ReceiptTextFormatter {
  ReceiptTextFormatter._();

  /// Format struk untuk teks, WhatsApp, atau salin ke clipboard
  static String formatReceipt({
    required SaleModel sale,
    required String storeName,
    String? cashierName,
    String? customerName,
    String? customerPhone,
    String? storeAddress,
    String? storePhone,
    AppPreferences? prefs,
    bool forWhatsApp = true,
  }) {
    final p = prefs ?? const AppPreferences();

    // Dapatkan teks struk monospaced yang rapi dan terukur
    final thermalText = ReceiptThermalFormatter.formatThermalReceipt(
      sale: sale,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: cashierName,
      customerPhone: customerPhone,
      prefs: p,
    ).trim();

    final buffer = StringBuffer();

    if (forWhatsApp && p.printerMonospaceWhatsApp) {
      buffer.writeln('🧾 *BUKTI NOTA PEMBELIAN RESMI*');
      buffer.writeln('```');
      buffer.writeln(thermalText);
      buffer.writeln('```');
      buffer.writeln('🙏 _Terima kasih telah berbelanja! Simpan nota ini sebagai bukti resmi transaksi._');
    } else {
      buffer.writeln(thermalText);
    }

    return buffer.toString();
  }
}

