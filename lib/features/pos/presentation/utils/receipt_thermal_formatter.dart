import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class ReceiptThermalFormatter {
  ReceiptThermalFormatter._();

  static String _center(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final left = (width - text.length) ~/ 2;
    final right = width - text.length - left;
    return '${' ' * left}$text${' ' * right}';
  }

  static String _twoColumn(String left, String right, int width) {
    final available = width - right.length;
    if (available <= 0) return '$left $right';
    if (left.length > available - 1) {
      left = '${left.substring(0, available - 2)}.';
    }
    final spaces = width - left.length - right.length;
    return '$left${' ' * (spaces > 0 ? spaces : 1)}$right';
  }

  static String formatThermalReceipt({
    required SaleModel sale,
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
    int paperWidth = 58,
    String footerMessage = 'Terima kasih atas kunjungan Anda!',
  }) {
    final col = paperWidth == 80 ? 48 : 32;
    final divider = '-' * col;
    final doubleDivider = '=' * col;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final b = StringBuffer();

    b.writeln(_center(storeName.toUpperCase(), col));
    if (storeAddress != null && storeAddress.trim().isNotEmpty) {
      b.writeln(_center(storeAddress.trim(), col));
    }
    if (storePhone != null && storePhone.trim().isNotEmpty) {
      b.writeln(_center('Telp: ${storePhone.trim()}', col));
    }
    b.writeln(doubleDivider);

    b.writeln(_twoColumn('Nota: ${sale.invoiceNumber}', dateFormat.format(sale.createdAt), col));
    if (cashierName != null && cashierName.isNotEmpty) {
      b.writeln(_twoColumn('Kasir: $cashierName', sale.paymentMethod, col));
    }
    if (sale.customerName != null && sale.customerName!.isNotEmpty) {
      b.writeln('Plg : ${sale.customerName}');
    }
    b.writeln(divider);

    for (final it in sale.items) {
      final name = it.productName ?? 'Barang';
      b.writeln(name.length > col ? name.substring(0, col) : name);
      final qtyPrice = '${it.quantity.toStringAsFixed(0)} ${it.unitName} x ${currency.format(it.sellingPrice)}';
      final subtotal = currency.format(it.subtotal);
      b.writeln(_twoColumn('  $qtyPrice', subtotal, col));
    }

    b.writeln(divider);
    b.writeln(_twoColumn('Subtotal', currency.format(sale.totalAmount), col));
    if (sale.discountAmount > 0) {
      b.writeln(_twoColumn('Diskon', '-${currency.format(sale.discountAmount)}', col));
    }
    b.writeln(_twoColumn('TOTAL', currency.format(sale.finalAmount), col));
    b.writeln(_twoColumn('Bayar (${sale.paymentMethod})', currency.format(sale.cashPaid), col));

    if (sale.paymentMethod.toUpperCase() == 'KASBON') {
      b.writeln(_twoColumn('Status', 'KASBON BELUM LUNAS', col));
    } else {
      b.writeln(_twoColumn('Kembalian', currency.format(sale.changeAmount), col));
    }

    b.writeln(doubleDivider);
    b.writeln(_center(footerMessage, col));
    b.writeln(_center('Simpan struk sebagai bukti resmi', col));
    b.writeln('\n\n');

    return b.toString();
  }

  static List<int> generateEscPosBytes({
    required SaleModel sale,
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
    int paperWidth = 58,
    String footerMessage = 'Terima kasih atas kunjungan Anda!',
  }) {
    final text = formatThermalReceipt(
      sale: sale,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: cashierName,
      paperWidth: paperWidth,
      footerMessage: footerMessage,
    );

    final bytes = <int>[];
    // ESC @: Initialize printer
    bytes.addAll([0x1B, 0x40]);
    // Encode text to latin1/ascii
    bytes.addAll(latin1.encode(text));
    // Feed and cut paper: GS V 66 0
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]);
    return bytes;
  }
}
