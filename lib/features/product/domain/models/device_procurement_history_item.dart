import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class DeviceProcurementHistoryItem {
  final String deviceTag;
  final double quantity;
  final String status; // 'received', 'shipping', 'pre_order'
  final String invoiceNumber;
  final String? supplierName;
  final String? trackingNumber;
  final DateTime date; // updatedAt for received, createdAt for shipping/po
  final DateTime? estimatedArrival;
  final DateTime? estimatedArrivalEnd;
  final bool isAutoReceived;

  const DeviceProcurementHistoryItem({
    required this.deviceTag,
    required this.quantity,
    required this.status,
    required this.invoiceNumber,
    this.supplierName,
    this.trackingNumber,
    required this.date,
    this.estimatedArrival,
    this.estimatedArrivalEnd,
    this.isAutoReceived = false,
  });

  bool get isReceived => status == 'received';
  bool get isShipping => status == 'shipping';
  bool get isPreOrder => status == 'pre_order';

  String get statusLabel => isReceived ? 'Diterima' : (isShipping ? 'OTW' : 'PO');

  static List<DeviceProcurementHistoryItem> fromPurchases(List<PurchaseModel> purchases, String productId) {
    final List<DeviceProcurementHistoryItem> list = [];
    for (final p in purchases) {
      if (p.isCancelled) continue;
      final dev = (p.deviceTag != null && p.deviceTag!.trim().isNotEmpty)
          ? p.deviceTag!.trim()
          : 'Device Belanja';

      for (final item in p.items) {
        if (item.productId == productId) {
          list.add(DeviceProcurementHistoryItem(
            deviceTag: dev,
            quantity: item.totalBaseQuantity,
            status: p.status,
            invoiceNumber: p.invoiceNumber,
            supplierName: p.supplierName,
            trackingNumber: p.trackingNumber,
            date: p.isReceived ? p.updatedAt : p.createdAt,
            estimatedArrival: p.estimatedArrival,
            estimatedArrivalEnd: p.estimatedArrivalEnd,
            isAutoReceived: p.isAutoReceived,
          ));
        }
      }
    }
    // Sort descending by date (most recent first)
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
