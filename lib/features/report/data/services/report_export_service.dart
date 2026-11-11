import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/report/domain/models/report_state.dart';

class ReportExportService {
  ReportExportService._();

  static String generateCsv({
    required String storeName,
    required ReportState report,
    required List<SaleModel> sales,
    String? storeAddress,
    String? storePhone,
  }) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final buffer = StringBuffer();

    // UTF-8 BOM agar Microsoft Excel langsung membaca karakter dan Rupiah dengan benar
    buffer.write('\uFEFF');

    buffer.writeln('"LAPORAN KEUANGAN & PENJUALAN TOKONA POS"');
    buffer.writeln('"Nama Outlet:","${storeName.replaceAll('"', '""')}"');
    if (storeAddress != null && storeAddress.isNotEmpty) {
      buffer.writeln('"Alamat:","${storeAddress.replaceAll('"', '""')}"');
    }
    if (storePhone != null && storePhone.isNotEmpty) {
      buffer.writeln('"Telepon / WA:","${storePhone.replaceAll('"', '""')}"');
    }
    buffer.writeln('"Periode Laporan:","${report.activeFilterLabel}"');
    buffer.writeln('"Waktu Ekspor:","${dateFormat.format(DateTime.now())}"');
    buffer.writeln('');

    // Ringkasan Finansial
    buffer.writeln('"--- RINGKASAN FINANSIAL ---"');
    buffer.writeln('"Indikator","Nilai"');
    buffer.writeln('"Total Omset Penjualan Bersih","${currency.format(report.summary.totalRevenue)}"');
    buffer.writeln('"Estimasi Laba Kotor","${currency.format(report.summary.grossProfit)}"');
    buffer.writeln('"Total Transaksi / Struk","${report.summary.transactionCount} Transaksi"');
    buffer.writeln('"Rata-rata per Transaksi","${currency.format(report.summary.averageBasket)}"');
    buffer.writeln('');

    // Produk Terlaris
    buffer.writeln('"--- 10 PRODUK TERLARIS ---"');
    buffer.writeln('"Peringkat","Nama Produk","Kategori","Qty Terjual","Total Omset"');
    int rank = 1;
    for (final p in report.topProducts) {
      final name = p.productName.replaceAll('"', '""');
      final cat = (p.category ?? '-').replaceAll('"', '""');
      buffer.writeln('"$rank","$name","$cat","${p.quantitySold}","${currency.format(p.revenue)}"');
      rank++;
    }
    buffer.writeln('');

    // Riwayat Transaksi Kasir
    buffer.writeln('"--- DETAIL TRANSAKSI PENJUALAN KASIR ---"');
    buffer.writeln('"No","No. Nota","Tanggal","Pelanggan","Metode","Diskon","Total Bayar","Status"');
    int no = 1;
    for (final s in sales) {
      final dateStr = dateFormat.format(s.createdAt);
      final cust = (s.customerName ?? 'Pelanggan Umum').replaceAll('"', '""');
      final status = s.isVoided ? 'DIBATALKAN / VOID' : (s.isKasbon ? 'KASBON' : 'LUNAS');
      buffer.writeln('"$no","${s.invoiceNumber}","$dateStr","$cust","${s.paymentMethod}","${currency.format(s.discountAmount)}","${currency.format(s.finalAmount)}","$status"');
      no++;
    }

    return buffer.toString();
  }

  static String generateSummaryText({
    required String storeName,
    required ReportState report,
    required List<SaleModel> sales,
  }) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    const divider = '────────────────────────';
    final buffer = StringBuffer();

    buffer.writeln(divider);
    buffer.writeln('📊 *LAPORAN PENJUALAN TOKONA*');
    buffer.writeln('🏪 *${storeName.toUpperCase().trim()}*');
    buffer.writeln('📅 Periode : *${report.activeFilterLabel}*');
    buffer.writeln('🕒 Dicetak : ${dateFormat.format(DateTime.now())}');
    buffer.writeln(divider);
    buffer.writeln('💰 *RINGKASAN LABA & OMSET*');
    buffer.writeln('• Total Omset : *${currency.format(report.summary.totalRevenue)}*');
    buffer.writeln('• Laba Kotor  : *${currency.format(report.summary.grossProfit)}*');
    buffer.writeln('• Total Struk : ${report.summary.transactionCount} Transaksi');
    buffer.writeln('• Rata-rata   : ${currency.format(report.summary.averageBasket)} / nota');
    buffer.writeln(divider);

    if (report.topProducts.isNotEmpty) {
      buffer.writeln('🏆 *TOP 5 PRODUK TERLARIS*');
      int rank = 1;
      for (final p in report.topProducts.take(5)) {
        buffer.writeln('$rank. ${p.productName} (${p.quantitySold.toStringAsFixed(0)} terjual)');
        buffer.writeln('   Omset: ${currency.format(p.revenue)}');
        rank++;
      }
      buffer.writeln(divider);
    }

    final kasbonSales = sales.where((s) => s.isKasbon && !s.isVoided);
    final totalKasbon = kasbonSales.fold(0.0, (acc, s) => acc + s.finalAmount);
    buffer.writeln('⚠️ *STATUS PIUTANG KASBON*');
    buffer.writeln('• Belum Lunas : ${kasbonSales.length} Nota');
    buffer.writeln('• Total Kasbon: *${currency.format(totalKasbon)}*');
    buffer.writeln(divider);
    buffer.writeln('_Laporan resmi otomatis Tokona POS Retail_');

    return buffer.toString();
  }

  static Future<File> saveCsvFile({
    required String csvContent,
    String prefix = 'Laporan_Tokona',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${prefix}_$timestamp.csv';
    final file = File('${exportDir.path}/$fileName');

    await file.writeAsString(csvContent);
    return file;
  }

  static Future<bool> sendSummaryToWhatsApp({
    required String phone,
    required String summaryMessage,
  }) async {
    return await WhatsAppService.sendReceipt(
      phone: phone,
      message: summaryMessage,
    );
  }
}

