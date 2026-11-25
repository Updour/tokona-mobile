import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/local_push_notification_service.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/data/services/shipment_tracking_service.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class JtCargoSyncService {
  static final Set<String> _notifiedWaybills = {};

  static bool _isSupportedJtCargo(String? courierTag, bool strictPrefix) {
    if (!strictPrefix || courierTag == null || courierTag.trim().isEmpty) return true;
    final tag = courierTag.trim().toLowerCase();
    return tag.contains('j&t') || tag.contains('jnt') || tag.contains('cargo');
  }

  static Future<int> checkActiveDeliveries({
    required List<PurchaseModel> activeOrders,
    required String storeId,
    required Ref ref,
  }) async {
    final prefs = ref.read(appPreferencesProvider);
    final shippingOrders = activeOrders.where((o) => o.isShipping && o.trackingNumber != null && o.trackingNumber!.trim().isNotEmpty).toList();
    if (shippingOrders.isEmpty) return 0;

    int completedCount = 0;
    for (final order in shippingOrders) {
      final rawTracking = order.trackingNumber!.trim();
      String waybill = rawTracking;
      String? courierTag;
      final bracket = RegExp(r'^\[([^\]]+)\]\s*(.*)$').firstMatch(rawTracking);
      if (bracket != null) {
        courierTag = bracket.group(1)?.trim();
        waybill = bracket.group(2)?.trim() ?? rawTracking;
      }

      if (waybill.isEmpty || !_isSupportedJtCargo(courierTag, prefs.strictCourierPrefixDetection)) continue;

      try {
        final trackingResult = await ShipmentTrackingService.trackWaybill(
          waybillNo: waybill,
          courier: courierTag ?? 'J&T Cargo',
          forceRefresh: true,
        );

        if (trackingResult.isSuccess && trackingResult.isDelivered) {
          if (prefs.autoReceiveOnDelivered) {
            final autoNote = 'Paket terkonfirmasi diterima via kurir J&T Cargo ($waybill)';
            await ref.read(purchaseRepositoryProvider).confirmReceived(
                  order.id,
                  isAutoReceived: true,
                  autoNote: autoNote,
                );
            completedCount++;
          }

          if (prefs.pushDeliveryEnabled && !_notifiedWaybills.contains(waybill)) {
            _notifiedWaybills.add(waybill);
            final notifId = waybill.hashCode.abs() % 100000;
            final supName = order.supplierName ?? 'Supplier';
            LocalPushNotificationService.instance.showDeliveryNotification(
              id: notifId,
              title: 'Paket J&T Cargo Diterima!',
              body: prefs.autoReceiveOnDelivered
                  ? 'Paket $supName (Resi: $waybill) berhasil diantar. Stok toko telah bertambah.'
                  : 'Paket $supName (Resi: $waybill) sudah tiba. Silakan cek fisik & konfirmasi terima.',
              payload: 'purchase_${order.id}',
            );
          }
        }
      } catch (_) {}
    }

    if (completedCount > 0) {
      ref.read(productListProvider.notifier).loadProducts(storeId);
      ref.read(purchaseControllerProvider.notifier).loadPurchases(storeId);
      ref.read(reportControllerProvider.notifier).loadReport(storeId);
    }

    return completedCount;
  }
}

