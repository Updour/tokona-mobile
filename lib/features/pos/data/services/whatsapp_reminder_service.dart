import 'package:intl/intl.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/domain/models/wa_message_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/wa_history_controller.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_thermal_formatter.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class WhatsAppReminderService {
  WhatsAppReminderService._();

  /// Format struk jadwal pengambilan pesanan bergaya cetak struk fisik resmi (monospaced)
  static String formatReceiptBooking({
    required HeldCartModel order,
    required String storeName,
    int width = 32,
  }) {
    final customer = order.customerName?.trim().isNotEmpty == true ? order.customerName!.trim() : 'Pelanggan';
    final customerPhone = order.customerPhone?.trim().isNotEmpty == true ? order.customerPhone!.trim() : null;
    final dateStr = order.plannedDate != null
        ? DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(order.plannedDate!)
        : 'Hari ini';

    final col = width.clamp(28, 48);
    final divider = '-' * col;
    final doubleDivider = '=' * col;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final b = StringBuffer();
    b.writeln(ReceiptThermalFormatter.centerMultiLine('JADWAL AMBIL PESANAN', col));
    b.writeln(ReceiptThermalFormatter.centerMultiLine(storeName.toUpperCase().trim(), col));
    b.writeln(doubleDivider);

    final shortId = order.id.length > 12 ? order.id.substring(order.id.length - 8).toUpperCase() : order.id.toUpperCase();
    b.writeln(ReceiptThermalFormatter.twoColumn('Order: #$shortId', dateStr, col));
    b.writeln('Layanan  : ${order.deliveryMethodLabel}');
    final phoneSuffix = customerPhone != null ? ' ($customerPhone)' : '';
    b.writeln('Plg      : $customer$phoneSuffix');
    b.writeln(divider);

    int idx = 1;
    for (final it in order.items) {
      final name = '$idx. ${it.product.name}';
      for (final line in ReceiptThermalFormatter.wrapText(name, col)) {
        b.writeln(line);
      }
      final qtyStr = it.quantity == it.quantity.roundToDouble()
          ? it.quantity.toInt().toString()
          : it.quantity.toStringAsFixed(1);
      final qtyPrice = '   $qtyStr ${it.unitName} x ${currency.format(it.unitPrice)}';
      final sub = currency.format(it.subtotal);
      b.writeln(ReceiptThermalFormatter.twoColumn(qtyPrice, sub, col));
      idx++;
    }

    b.writeln(divider);
    b.writeln(ReceiptThermalFormatter.twoColumn('TOTAL', CurrencyFormatter.format(order.finalAmount), col));
    b.writeln(ReceiptThermalFormatter.twoColumn('STATUS', 'SIAP DIAMBIL', col));
    b.writeln(doubleDivider);
    b.writeln(ReceiptThermalFormatter.centerMultiLine('Harap simpan struk saat pengambilan', col));

    final msg = StringBuffer();
    msg.writeln('Halo Kak *$customer*!');
    msg.writeln('Berikut rincian jadwal pengambilan pesanan Anda di *$storeName*:');
    msg.writeln('```');
    msg.writeln(b.toString().trim());
    msg.writeln('```');
    msg.writeln('Pesanan Anda sudah siap di toko. Ditunggu kedatangannya ya Kak. Terima kasih!');
    return msg.toString();
  }

  static String formatMessage({
    required HeldCartModel order,
    required String storeName,
    String? template,
    bool useReceiptStyle = true,
  }) {
    if (useReceiptStyle) {
      return formatReceiptBooking(order: order, storeName: storeName);
    }

    final customer = order.customerName?.trim().isNotEmpty == true ? order.customerName!.trim() : 'Pelanggan';
    final dateStr = order.plannedDate != null
        ? DateFormat('EEEE, d MMM yyyy, jam HH:mm', 'id_ID').format(order.plannedDate!)
        : 'hari ini';

    final itemsSummary = order.items.isNotEmpty
        ? order.items.take(3).map((it) {
            final qty = it.quantity == it.quantity.roundToDouble() ? it.quantity.toInt().toString() : it.quantity.toString();
            return '• ${it.product.name} ($qty ${it.unitName})';
          }).join('\n')
        : (order.note != null ? '• ${order.note}' : '• Pesanan Booking');

    final extraItems = order.items.length > 3 ? '\n• ...dan ${order.items.length - 3} item lainnya' : '';

    return AppPreferences.renderTemplate(
      template ?? AppPreferences.defaultBookingTemplate,
      {
        'nama': customer,
        'toko': storeName,
        'daftar_barang': '$itemsSummary$extraItems',
        'total': CurrencyFormatter.format(order.finalAmount),
        'jadwal': dateStr,
        'metode': order.deliveryMethodLabel,
      },
    );
  }

  static Future<bool> sendReminder({
    required WidgetRef ref,
    required HeldCartModel order,
    required String storeName,
  }) async {
    final rawPhone = order.customerPhone?.trim() ?? '';
    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 9) {
      ref.read(heldCartProvider.notifier).markWaFailed(
            order.id,
            reason: 'Nomor handphone tidak terdaftar/kurang dari 9 digit ($rawPhone)',
          );
      return false;
    }

    final cleanPhone = WhatsAppService.sanitizePhoneNumber(rawPhone);
    final prefs = ref.read(appPreferencesProvider);
    final message = prefs.printerMonospaceWhatsApp
        ? formatReceiptBooking(order: order, storeName: storeName, width: prefs.printerColumnWidth)
        : formatMessage(order: order, storeName: storeName, template: prefs.waBookingTemplate, useReceiptStyle: false);

    try {
      final success = await WhatsAppService.sendReceipt(
        phone: cleanPhone,
        message: message,
      );

      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm • d MMM', 'id_ID').format(now);

      if (success) {
        ref.read(heldCartProvider.notifier).markWaSent(
              order.id,
              phone: cleanPhone,
              logMessage: 'Berhasil dikirim ke WhatsApp (+$cleanPhone) pada $timeStr',
            );
        ref.read(waHistoryProvider.notifier).recordLog(WaMessageLog(
              id: 'wa_${DateTime.now().millisecondsSinceEpoch}',
              recipientName: order.customerName ?? 'Pelanggan',
              phone: cleanPhone,
              category: 'booking',
              message: message,
              status: 'sent',
              referenceId: 'booking_${order.id}',
              createdAt: now,
              sentAt: now,
            ));
        return true;
      } else {
        ref.read(heldCartProvider.notifier).markWaFailed(
              order.id,
              reason: 'Gagal membuka aplikasi WhatsApp di perangkat',
            );
        ref.read(waHistoryProvider.notifier).recordLog(WaMessageLog(
              id: 'wa_${DateTime.now().millisecondsSinceEpoch}',
              recipientName: order.customerName ?? 'Pelanggan',
              phone: cleanPhone,
              category: 'booking',
              message: message,
              status: 'failed',
              errorReason: 'Gagal membuka aplikasi WhatsApp',
              referenceId: 'booking_${order.id}',
              createdAt: now,
            ));
        return false;
      }
    } catch (e) {
      ref.read(heldCartProvider.notifier).markWaFailed(
            order.id,
            reason: 'Error saat dialihkan ke WA: $e',
          );
      return false;
    }
  }
}

