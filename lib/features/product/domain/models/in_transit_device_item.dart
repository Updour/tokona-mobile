import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class InTransitDeviceItem {
  final String deviceTag;
  final double quantity;
  final bool isShipping;
  final bool isPreOrder;
  final String invoiceNumber;
  final DateTime? estimatedArrival;

  const InTransitDeviceItem({
    required this.deviceTag,
    required this.quantity,
    required this.isShipping,
    required this.isPreOrder,
    required this.invoiceNumber,
    this.estimatedArrival,
  });

  String get statusLabel => isShipping ? 'OTW' : (isPreOrder ? 'PO' : 'Dalam Proses');

  static List<InTransitDeviceItem> fromActiveOrders(List<PurchaseModel> orders, String productId) {
    final Map<String, InTransitDeviceItem> grouped = {};
    for (final order in orders) {
      if (order.isReceived || order.isCancelled) continue;
      final dev = (order.deviceTag != null && order.deviceTag!.trim().isNotEmpty)
          ? order.deviceTag!.trim()
          : 'Device Belanja';

      for (final item in order.items) {
        if (item.productId == productId) {
          final qty = item.totalBaseQuantity;
          if (grouped.containsKey(dev)) {
            final prev = grouped[dev]!;
            grouped[dev] = InTransitDeviceItem(
              deviceTag: dev,
              quantity: prev.quantity + qty,
              isShipping: prev.isShipping || order.isShipping,
              isPreOrder: prev.isPreOrder || order.isPreOrder,
              invoiceNumber: prev.invoiceNumber,
              estimatedArrival: prev.estimatedArrival ?? order.estimatedArrival,
            );
          } else {
            grouped[dev] = InTransitDeviceItem(
              deviceTag: dev,
              quantity: qty,
              isShipping: order.isShipping,
              isPreOrder: order.isPreOrder,
              invoiceNumber: order.invoiceNumber,
              estimatedArrival: order.estimatedArrival,
            );
          }
        }
      }
    }
    return grouped.values.toList();
  }
}
