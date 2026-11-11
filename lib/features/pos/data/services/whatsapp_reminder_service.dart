import 'package:intl/intl.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';

class WhatsAppReminderService {
  WhatsAppReminderService._();

  static String formatMessage({
    required HeldCartModel order,
    required String storeName,
  }) {
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

    return 'Halo Kak *$customer*! 👋\n\n'
        'Mengingatkan pesanan Anda di *$storeName*:\n'
        '$itemsSummary$extraItems\n\n'
        '💰 Total: *${CurrencyFormatter.format(order.finalAmount)}*\n'
        '📅 Jadwal: *$dateStr*\n'
        '📍 Layanan: ${order.deliveryMethodLabel}\n\n'
        'Pesanan sudah siap disiapkan di toko. Ditunggu kedatangannya ya Kak. Terima kasih! 🙏';
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
            reason: 'Nomor WhatsApp tidak terdaftar/kurang dari 9 digit ($rawPhone)',
          );
      return false;
    }

    final cleanPhone = WhatsAppService.sanitizePhoneNumber(rawPhone);
    final message = formatMessage(order: order, storeName: storeName);

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
        return true;
      } else {
        ref.read(heldCartProvider.notifier).markWaFailed(
              order.id,
              reason: 'Gagal membuka aplikasi WhatsApp di perangkat',
            );
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

