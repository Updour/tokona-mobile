import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_formatter_utils.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class ReceiptThermalFormatter {
  ReceiptThermalFormatter._();

  static List<String> wrapText(String text, int width) => ReceiptFormatterUtils.wrapText(text, width);
  static String center(String text, int width) => ReceiptFormatterUtils.center(text, width);
  static String centerMultiLine(String text, int width) => ReceiptFormatterUtils.centerMultiLine(text, width);
  static String twoColumn(String left, String right, int width) => ReceiptFormatterUtils.twoColumn(left, right, width);

  /// Format teks nota struk kasir yang konsisten, monospaced, dan anti-berantakan
  static String formatThermalReceipt({
    required SaleModel sale,
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
    String? customerPhone,
    AppPreferences? prefs,
    int? overrideWidth,
  }) {
    final p = prefs ?? const AppPreferences();
    final paperWidth = overrideWidth ?? p.printerPaperWidth;
    final col = p.printerColumnWidth.clamp(28, 54);

    final divider = '-' * col;
    final doubleDivider = '=' * col;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dueDateShortFormat = DateFormat('dd/MM/yyyy');

    final b = StringBuffer();

    // 1. HEADER TOKO DINAMIS
    final displayTitle = (p.printerHeaderTitle != null && p.printerHeaderTitle!.trim().isNotEmpty)
        ? p.printerHeaderTitle!.trim()
        : storeName.trim();

    b.writeln(centerMultiLine(displayTitle.toUpperCase(), col));

    if (p.printerHeaderSubtitle != null && p.printerHeaderSubtitle!.trim().isNotEmpty) {
      b.writeln(centerMultiLine(p.printerHeaderSubtitle!.trim(), col));
    }

    if (p.printerShowAddress) {
      final addr = (p.printerAddress != null && p.printerAddress!.trim().isNotEmpty)
          ? p.printerAddress!.trim()
          : (storeAddress != null ? storeAddress.trim() : null);
      if (addr != null && addr.isNotEmpty) {
        b.writeln(centerMultiLine(addr, col));
      }
    }

    if (p.printerShowPhone) {
      final ph = (p.printerPhone != null && p.printerPhone!.trim().isNotEmpty)
          ? p.printerPhone!.trim()
          : (storePhone != null ? storePhone.trim() : null);
      if (ph != null && ph.isNotEmpty) {
        b.writeln(center('Telp/WA: $ph', col));
      }
    }

    if (p.printerCustomHeader != null && p.printerCustomHeader!.trim().isNotEmpty) {
      b.writeln(centerMultiLine(p.printerCustomHeader!.trim(), col));
    }

    b.writeln(doubleDivider);

    // 2. METADATA TRANSAKSI
    if (p.printerShowInvoiceNumber || p.printerShowDateTime) {
      final invText = p.printerShowInvoiceNumber ? 'Nota: ${sale.invoiceNumber}' : '';
      final dtText = p.printerShowDateTime ? dateFormat.format(sale.createdAt) : '';
      if (invText.isNotEmpty && dtText.isNotEmpty) {
        b.writeln(twoColumn(invText, dtText, col));
      } else if (invText.isNotEmpty) {
        b.writeln(invText);
      } else {
        b.writeln(dtText);
      }
    }

    if (p.printerShowCashier && cashierName != null && cashierName.trim().isNotEmpty) {
      b.writeln(twoColumn('Kasir: ${cashierName.trim()}', sale.paymentMethod, col));
    } else {
      b.writeln('Metode: ${sale.paymentMethod}');
    }

    if (p.printerShowCustomer) {
      final custName = sale.customerName;
      final custPhone = (customerPhone != null && customerPhone.trim().isNotEmpty)
          ? customerPhone.trim()
          : (sale.customerPhone != null && sale.customerPhone!.trim().isNotEmpty
              ? sale.customerPhone!.trim()
              : null);

      if (custName != null && custName.trim().isNotEmpty) {
        final phonePart = custPhone != null ? ' ($custPhone)' : '';
        b.writeln('Plg  : ${custName.trim()}$phonePart');
      }
    }

    b.writeln(divider);

    // 3. DAFTAR BARANG BELANJAAN (PINTAR & TIDAK AKAN KOCAR-KACIR)
    int idx = 1;
    for (final it in sale.items) {
      final rawName = it.productName?.trim().isNotEmpty == true ? it.productName!.trim() : 'Produk';
      final itemHeader = '$idx. $rawName';
      final nameLines = wrapText(itemHeader, col);

      // Cetak nama barang (bisa multi-baris bila panjang)
      for (final line in nameLines) {
        b.writeln(line);
      }

      // Baris kuantitas x harga satuan dan subtotal di ujung kanan
      final qtyStr = it.quantity == it.quantity.roundToDouble()
          ? it.quantity.toInt().toString()
          : it.quantity.toStringAsFixed(1);
      final qtyPrice = '   $qtyStr ${it.unitName} x ${currency.format(it.sellingPrice)}';
      final subtotal = currency.format(it.subtotal);

      b.writeln(twoColumn(qtyPrice, subtotal, col));
      idx++;
    }

    b.writeln(divider);

    // 4. TOTAL, DISKON, DAN PEMBAYARAN
    b.writeln(twoColumn('Subtotal', currency.format(sale.totalAmount), col));
    if (sale.discountAmount > 0) {
      b.writeln(twoColumn('Diskon', '-${currency.format(sale.discountAmount)}', col));
    }
    if (sale.roundingAmount != 0) {
      final sign = sale.roundingAmount > 0 ? '+' : '-';
      final formattedRounding = '$sign${currency.format(sale.roundingAmount.abs())}';
      b.writeln(twoColumn('Pembulatan', formattedRounding, col));
    }
    b.writeln(twoColumn('TOTAL', currency.format(sale.finalAmount), col));
    b.writeln(twoColumn('Bayar (${sale.paymentMethod})', currency.format(sale.cashPaid), col));

    if (sale.paymentMethod.toUpperCase() == 'KASBON') {
      b.writeln(twoColumn('Status', 'KASBON BELUM LUNAS', col));
      if (sale.dueDate != null) {
        b.writeln(twoColumn('Jatuh Tempo', dueDateShortFormat.format(sale.dueDate!), col));
      }
    } else {
      b.writeln(twoColumn('Kembalian', currency.format(sale.changeAmount), col));
      b.writeln(twoColumn('Status', 'LUNAS', col));
    }

    b.writeln(doubleDivider);

    // 5. FOOTER DINAMIS
    if (p.printerFooterMessage.trim().isNotEmpty) {
      b.writeln(centerMultiLine(p.printerFooterMessage.trim(), col));
    }

    if (p.printerFooterPolicy != null && p.printerFooterPolicy!.trim().isNotEmpty) {
      b.writeln(centerMultiLine(p.printerFooterPolicy!.trim(), col));
    }

    if (p.printerFooterSocial != null && p.printerFooterSocial!.trim().isNotEmpty) {
      b.writeln(centerMultiLine(p.printerFooterSocial!.trim(), col));
    }

    // 6. FEED LINES KOSONG SEBELUM POTONG KERTAS
    for (int i = 0; i < p.printerFeedLines; i++) {
      b.writeln('');
    }

    return b.toString();
  }

  /// Menghasilkan format simulasi struk untuk Live Preview & Uji Cetak
  static String formatSampleReceipt({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    required AppPreferences prefs,
  }) {
    final now = DateTime.now();
    final sampleSale = SaleModel(
      id: 'sample-1',
      storeId: 'store-1',
      userId: 'user-1',
      invoiceNumber: 'INV-SAMPLE-001',
      customerName: 'Budi Santoso',
      customerPhone: '08129876543',
      totalAmount: 164500,
      discountAmount: 4500,
      finalAmount: 160000,
      cashPaid: 200000,
      changeAmount: 40000,
      paymentMethod: 'TUNAI',
      status: 'COMPLETED',
      createdAt: now,
      updatedAt: now,
      items: [
        SaleItemModel(
          id: 'item-1', saleId: 'sample-1', productId: 'p1',
          productName: 'Beras Ramos Super 5kg', unitName: 'sak',
          quantity: 1, conversionFactor: 1, sellingPrice: 75000, costPrice: 65000, subtotal: 75000,
          createdAt: now,
        ),
        SaleItemModel(
          id: 'item-2', saleId: 'sample-1', productId: 'p2',
          productName: 'Minyak Goreng Bimoli 2L', unitName: 'pouch',
          quantity: 2, conversionFactor: 1, sellingPrice: 36000, costPrice: 31000, subtotal: 72000,
          createdAt: now,
        ),
        SaleItemModel(
          id: 'item-3', saleId: 'sample-1', productId: 'p3',
          productName: 'Gula Pasir Gulaku Putih Premium 1kg', unitName: 'bungkus',
          quantity: 1, conversionFactor: 1, sellingPrice: 17500, costPrice: 15000, subtotal: 17500,
          createdAt: now,
        ),
      ],
    );

    return formatThermalReceipt(
      sale: sampleSale,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: 'Kasir Utama',
      customerPhone: '08129876543',
      prefs: prefs,
    );
  }

  /// Menghasilkan barisan byte biner ESC/POS yang kompatibel dengan semua printer thermal USB/Bluetooth
  static List<int> generateEscPosBytes({
    required SaleModel sale,
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
    String? customerPhone,
    AppPreferences? prefs,
    int? overrideWidth,
  }) {
    final p = prefs ?? const AppPreferences();
    final text = formatThermalReceipt(
      sale: sale,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: cashierName,
      customerPhone: customerPhone,
      prefs: p,
      overrideWidth: overrideWidth,
    );

    final bytes = <int>[];

    // 1. ESC @: Inisialisasi printer
    bytes.addAll([0x1B, 0x40]);

    // 2. ESC t 0: Pilih karakter code page standar PC437 (ASCI/Latin)
    bytes.addAll([0x1B, 0x74, 0x00]);

    // 3. Encode teks string ke byte latin1
    bytes.addAll(latin1.encode(text));

    // 4. Feed baris kosong tambahan jika diatur
    if (p.printerFeedLines > 0) {
      bytes.addAll([0x1B, 0x64, p.printerFeedLines.clamp(1, 6)]);
    }

    // 5. GS V 66 0: Partial Cut Paper jika auto-cut aktif
    if (p.printerAutoCut) {
      bytes.addAll([0x1D, 0x56, 0x42, 0x00]);
    }

    return bytes;
  }
}

