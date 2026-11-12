import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

final notificationListProvider = Provider<List<AppNotificationItem>>((ref) {
  final sales = ref.watch(saleHistoryControllerProvider).sales;
  final products = ref.watch(productListProvider).products;
  final heldOrders = ref.watch(heldCartProvider);
  final activeOrders = ref.watch(activeOrdersProvider);
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  final List<AppNotificationItem> items = [];

  // 1. Kasbon Jatuh Tempo & Mendekati Tempo
  for (final s in sales) {
    if (!s.isKasbon || s.isVoided || s.dueDate == null) continue;
    final due = s.dueDate!;
    final dueDay = DateTime(due.year, due.month, due.day);

    if (dueDay.isBefore(todayDate)) {
      final daysLate = todayDate.difference(dueDay).inDays;
      items.add(AppNotificationItem(
        id: 'kasbon_late_${s.id}',
        title: 'Kasbon Telat $daysLate Hari: ${s.customerName ?? "Pelanggan"}',
        body: 'Tagihan kasbon ${CurrencyFormatter.format(s.finalAmount)} telah lewat jatuh tempo.',
        type: AppNotificationType.kasbonOverdue,
        createdAt: due,
        targetPayload: 'kasbon',
      ));
    } else {
      final daysRemaining = dueDay.difference(todayDate).inDays;
      if (daysRemaining <= 3) {
        final whenText = daysRemaining == 0 ? 'hari ini' : 'dalam $daysRemaining hari';
        items.add(AppNotificationItem(
          id: 'kasbon_due_${s.id}',
          title: 'Kasbon Jatuh Tempo $whenText: ${s.customerName ?? "Pelanggan"}',
          body: 'Tagihan ${CurrencyFormatter.format(s.finalAmount)} jatuh tempo $whenText.',
          type: AppNotificationType.kasbonDueSoon,
          createdAt: due,
          targetPayload: 'kasbon',
        ));
      }
    }
  }

  // 2. Stok Habis & Menipis
  for (final p in products) {
    if (p.isOutOfStock) {
      items.add(AppNotificationItem(
        id: 'stock_empty_${p.id}',
        title: 'Stok Habis: ${p.name}',
        body: 'Stok fisik habis (0 ${p.baseUnit}). Segera pesan ke supplier untuk kasir.',
        type: AppNotificationType.stockEmpty,
        createdAt: p.updatedAt,
        targetPayload: 'stock',
      ));
    } else if (p.isLowStock) {
      items.add(AppNotificationItem(
        id: 'stock_low_${p.id}',
        title: 'Stok Menipis: ${p.name}',
        body: 'Sisa stok tinggal ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit} (batas min: ${p.minStockAlert.toStringAsFixed(0)}).',
        type: AppNotificationType.stockLow,
        createdAt: p.updatedAt,
        targetPayload: 'stock',
      ));
    }
  }

  // 3. Pesanan Booking yang Siap Hari Ini / Mendekati Jam / Waktunya Kirim WA
  for (final h in heldOrders) {
    if (h.plannedDate != null) {
      final planTime = h.plannedDate!;
      final planDay = DateTime(planTime.year, planTime.month, planTime.day);
      final isSameDay = planDay.isAtSameMomentAs(todayDate);

      if (isSameDay) {
        final timeStr = DateFormat('HH:mm').format(planTime);
        final diffMinutes = planTime.difference(now).inMinutes;

        if (now.isAfter(planTime) && h.isWaPending) {
          // Waktu telah tiba dan belum dikirim
          items.add(AppNotificationItem(
            id: 'booking_alarm_${h.id}',
            title: '⏰ Waktunya Kirim WA: ${h.customerName} ($timeStr)',
            body: 'Jadwal pengambilan jam $timeStr telah tiba! Ketuk untuk kirim pengingat WhatsApp ke ${h.customerPhone ?? "pelanggan"}.',
            type: AppNotificationType.bookingReady,
            createdAt: planTime,
            targetPayload: 'booking',
          ));
        } else if (diffMinutes >= 0 && diffMinutes <= 45) {
          // 45 menit sebelum jadwal
          items.add(AppNotificationItem(
            id: 'booking_soon_${h.id}',
            title: '🔔 Pengingat $diffMinutes Menit Lagi (Jam $timeStr): ${h.customerName}',
            body: 'Pesanan ${h.deliveryMethodLabel} (${CurrencyFormatter.format(h.finalAmount)}). Siapkan barang & pesan WA.',
            type: AppNotificationType.bookingReady,
            createdAt: planTime,
            targetPayload: 'booking',
          ));
        } else if (planDay.isBefore(todayDate)) {
          // Lewat hari
          items.add(AppNotificationItem(
            id: 'booking_late_${h.id}',
            title: 'Lewat Jadwal Ambil: ${h.customerName ?? "Pelanggan"}',
            body: 'Pesanan ${h.totalItemCount} item (${CurrencyFormatter.format(h.finalAmount)}). Ketuk untuk langsung kirim pesan WA.',
            type: AppNotificationType.bookingReady,
            createdAt: planTime,
            targetPayload: 'booking',
          ));
        }
      }
    }
  }

  // 4. Pesanan Kulakan Masuk / Berjalan
  for (final ord in activeOrders) {
    items.add(AppNotificationItem(
      id: 'active_order_${ord.id}',
      title: 'Pesanan Masuk: ${ord.supplierName ?? ord.invoiceNumber}',
      body: 'Stok kulakan ${ord.isPreOrder ? "PO" : "dalam kirim"} (${CurrencyFormatter.format(ord.grandTotal)}). Cek jika tiba.',
      type: AppNotificationType.bookingReady,
      createdAt: ord.createdAt,
      targetPayload: 'incoming',
    ));
  }

  // Sort: High priority first
  items.sort((a, b) => _priorityScore(b.type).compareTo(_priorityScore(a.type)));
  return items;
});

int _priorityScore(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.kasbonOverdue:
      return 100;
    case AppNotificationType.bookingReady:
      return 90;
    case AppNotificationType.stockEmpty:
      return 80;
    case AppNotificationType.purchaseRefund:
      return 70;
    case AppNotificationType.kasbonDueSoon:
      return 60;
    case AppNotificationType.stockLow:
      return 40;
    case AppNotificationType.generalInfo:
      return 20;
  }
}

class ReadNotificationIdsNotifier extends StateNotifier<Set<String>> {
  ReadNotificationIdsNotifier() : super({}) {
    _load();
  }

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_read_notifications.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = (jsonDecode(content) as List).map((e) => e.toString()).toSet();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    _save();
  }

  Future<void> markAllAsRead(Iterable<String> ids) async {
    state = {...state, ...ids};
    _save();
  }

  Future<void> _save() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.toList()));
    } catch (_) {}
  }
}

final readNotificationIdsProvider = StateNotifierProvider<ReadNotificationIdsNotifier, Set<String>>((ref) {
  return ReadNotificationIdsNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationListProvider);
  final readIds = ref.watch(readNotificationIdsProvider);
  return notifs.where((n) => !readIds.contains(n.id)).length;
});
