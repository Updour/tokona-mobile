import 'package:intl/intl.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class ReceiptTextFormatter {
  ReceiptTextFormatter._();

  static String formatReceipt({
    required SaleModel sale,
    required String storeName,
    String? cashierName,
    String? customerName,
    String? customerPhone,
    String? storeAddress,
    String? storePhone,
  }) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dueDateShortFormat = DateFormat('dd/MM/yyyy');
    final buffer = StringBuffer();

    const divider = '────────────────────────';

    buffer.writeln(divider);
    buffer.writeln('🏪 *${storeName.toUpperCase().trim()}*');
    if (storeAddress != null && storeAddress.trim().isNotEmpty) {
      buffer.writeln('📍 ${storeAddress.trim()}');
    }
    if (storePhone != null && storePhone.trim().isNotEmpty) {
      buffer.writeln('📞 Telp: ${storePhone.trim()}');
    }
    buffer.writeln(divider);
    buffer.writeln('No. Nota : *${sale.invoiceNumber}*');
    buffer.writeln('Tanggal  : ${dateFormat.format(sale.createdAt)}');
    if (cashierName != null && cashierName.trim().isNotEmpty) {
      buffer.writeln('Kasir    : $cashierName');
    }
    if (customerName != null && customerName.trim().isNotEmpty) {
      final phoneSuffix = (customerPhone != null && customerPhone.trim().isNotEmpty)
          ? ' ($customerPhone)'
          : '';
      buffer.writeln('Pelanggan: $customerName$phoneSuffix');
    }
    buffer.writeln('Metode   : *${sale.paymentMethod}*');
    buffer.writeln(divider);
    buffer.writeln('📦 *RINCIAN BELANJA*');

    int index = 1;
    for (final item in sale.items) {
      final name = item.productName ?? 'Produk';
      final qtyStr = '${item.quantity.toStringAsFixed(0)} ${item.unitName}';
      final priceStr = currency.format(item.sellingPrice);
      final subtotalStr = currency.format(item.subtotal);

      buffer.writeln('$index. $name');
      buffer.writeln('   $qtyStr x $priceStr = *$subtotalStr*');
      index++;
    }

    buffer.writeln(divider);
    buffer.writeln('Subtotal   : ${currency.format(sale.totalAmount)}');
    if (sale.discountAmount > 0) {
      buffer.writeln('Diskon     : -${currency.format(sale.discountAmount)}');
    }
    buffer.writeln('*TOTAL*    : *${currency.format(sale.finalAmount)}*');
    buffer.writeln('Bayar      : ${currency.format(sale.cashPaid)}');

    if (sale.paymentMethod.toUpperCase() == 'KASBON') {
      buffer.writeln('Status     :  *KASBON*');
      if (sale.dueDate != null) {
        final days = sale.dueDate!.difference(DateTime.now()).inDays + 1;
        final dueText = days <= 0
            ? 'Hari Ini Jatuh Tempo!'
            : (days == 1 ? 'Besok (1 Hari Lagi)' : '$days Hari Lagi');
        buffer.writeln('Jatuh Tempo: *${dueDateShortFormat.format(sale.dueDate!)} ($dueText)*');
      }
    } else {
      buffer.writeln('Kembalian  : *${currency.format(sale.changeAmount)}*');
      buffer.writeln('Status     :  *LUNAS*');
    }

    buffer.writeln(divider);
    buffer.writeln('🙏 *Terima Kasih Atas Kunjungan Anda!*');
    buffer.writeln('_Simpan bukti nota ini sebagai bukti transaksi resmi._');
    buffer.writeln(divider);

    return buffer.toString();
  }
}
