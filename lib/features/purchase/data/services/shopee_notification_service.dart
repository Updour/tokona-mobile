import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/native_push_notification_service.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/models/captured_notification_event.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

final shopeeNotificationServiceProvider = Provider<ShopeeNotificationService>((ref) {
  return ShopeeNotificationService(ref);
});

class ShopeeNotificationService {
  final Ref _ref;
  static const MethodChannel _methodChannel = MethodChannel('com.tokona.app/native_notifications');
  static const EventChannel _eventChannel = EventChannel('com.tokona.app/shopee_notification_stream');

  StreamSubscription? _subscription;
  bool _isListening = false;

  ShopeeNotificationService(this._ref);

  Future<bool> isListenerEnabled() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('isNotificationListenerEnabled');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationListenerSettings');
    } catch (_) {}
  }

  void startListening(String storeId) {
    if (_isListening) return;
    _isListening = true;

    _subscription = _eventChannel.receiveBroadcastStream().listen((data) {
      if (data is Map) {
        final event = CapturedNotificationEvent.fromMap(data);
        _handleNotificationEvent(event, storeId);
      }
    }, onError: (err) {
      debugPrint('ShopeeNotificationService error: $err');
    });
  }

  Future<void> _handleNotificationEvent(CapturedNotificationEvent event, String storeId) async {
    final activeOrders = _ref.read(activeOrdersProvider);
    if (activeOrders.isEmpty) return;

    final trackingNum = event.extractTrackingNumber();
    final orderNum = event.extractOrderNumber();
    final fullText = '${event.title} ${event.text}'.toLowerCase();

    for (final order in activeOrders) {
      bool isMatch = false;

      // 1. Cek kecocokan Resi
      if (trackingNum != null && order.trackingNumber != null && order.trackingNumber!.trim().isNotEmpty) {
        if (order.trackingNumber!.toLowerCase().contains(trackingNum.toLowerCase())) {
          isMatch = true;
        }
      }

      // 2. Cek kecocokan Nomor Invoice / Order
      if (!isMatch && orderNum != null && order.invoiceNumber.contains(orderNum)) {
        isMatch = true;
      }

      // 3. Cek kecocokan nomor faktur persis dalam teks
      if (!isMatch && fullText.contains(order.invoiceNumber.toLowerCase())) {
        isMatch = true;
      }

      if (isMatch) {
        await _processMatchedOrder(order, event, storeId, extractedResi: trackingNum);
        break;
      }
    }
  }

  Future<void> _processMatchedOrder(
    PurchaseModel order,
    CapturedNotificationEvent event,
    String storeId, {
    String? extractedResi,
  }) async {
    final repo = _ref.read(purchaseRepositoryProvider);

    // Kasus A: Notifikasi menyatakan barang telah sampai / diterima
    if (event.isDelivered && order.status != 'received') {
      final autoNote = 'Diterima otomatis dari notifikasi Shopee: "${event.title}"';
      await repo.confirmReceived(order.id, isAutoReceived: true, autoNote: autoNote);

      await _refreshAppState(storeId);
      await NativePushNotificationService.showPushNotification(
        id: order.id.hashCode,
        title: 'Pesanan Shopee Diterima!',
        body: 'Faktur ${order.invoiceNumber} otomatis diterima & stok toko bertambah.',
      );
    }
    // Kasus B: Notifikasi pesanan dikirim / update resi
    else if (event.isDeliveryUpdate && order.isPreOrder) {
      await repo.markAsShipped(order.id, trackingNumber: extractedResi ?? order.trackingNumber);
      await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
      await NativePushNotificationService.showPushNotification(
        id: order.id.hashCode,
        title: 'Pesanan Sedang Dikirim',
        body: 'Paket ${order.invoiceNumber} sedang dalam perjalanan.${extractedResi != null ? " Resi: $extractedResi" : ""}',
      );
    }
    // Kasus C: Tambahkan resi jika sebelumnya kosong
    else if (extractedResi != null && (order.trackingNumber == null || order.trackingNumber!.isEmpty)) {
      await repo.updateTrackingNumber(order.id, extractedResi);
      await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
    }
  }

  Future<void> _refreshAppState(String storeId) async {
    await _ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
    await _ref.read(purchaseControllerProvider.notifier).loadPurchases(storeId);
    await _ref.read(productListProvider.notifier).loadProducts(storeId);
    _ref.read(reportControllerProvider.notifier).loadReport(storeId);
    await _ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }
}

