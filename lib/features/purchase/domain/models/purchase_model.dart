import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/purchase/domain/models/purchase_item_model.dart';

class PurchaseModel {
  final String id;
  final String storeId;
  final String userId;
  final String invoiceNumber;
  final String? supplierId;
  final String? supplierName;
  final String purchaseType;
  final String? platform;
  final String? deviceTag;
  final String? paymentAccount;
  final double serviceFee;
  final double shippingFee;
  final String status;
  final int? poDays;
  final DateTime? estimatedArrival;
  final String refundStatus;
  final double totalAmount;
  final String? notes;
  final List<PurchaseItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const PurchaseModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.invoiceNumber,
    this.supplierId,
    this.supplierName,
    this.purchaseType = 'offline',
    this.platform,
    this.deviceTag,
    this.paymentAccount,
    this.serviceFee = 0.0,
    this.shippingFee = 0.0,
    this.status = 'received',
    this.poDays,
    this.estimatedArrival,
    this.refundStatus = 'none',
    required this.totalAmount,
    this.notes,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isOnline => purchaseType.toLowerCase() == 'online';
  bool get isPreOrder => status == 'pre_order';
  bool get isShipping => status == 'shipping';
  bool get isReceived => status == 'received';
  bool get isCancelled => status == 'cancelled';
  bool get hasPendingRefund => refundStatus == 'pending_refund';
  double get grandTotal => totalAmount + serviceFee + shippingFee;

  factory PurchaseModel.fromMap(Map<String, dynamic> map, {List<PurchaseItemModel> items = const []}) {
    return PurchaseModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnPurchaseStoreId] as String,
      userId: map[DatabaseTables.columnPurchaseUserId] as String,
      invoiceNumber: map[DatabaseTables.columnPurchaseInvoiceNumber] as String,
      supplierId: map[DatabaseTables.columnPurchaseSupplierId] as String?,
      supplierName: map[DatabaseTables.columnPurchaseSupplierName] as String?,
      purchaseType: map[DatabaseTables.columnPurchaseType] as String? ?? 'offline',
      platform: map[DatabaseTables.columnPurchasePlatform] as String?,
      deviceTag: map[DatabaseTables.columnPurchaseDeviceTag] as String?,
      paymentAccount: map[DatabaseTables.columnPurchasePaymentAccount] as String?,
      serviceFee: (map[DatabaseTables.columnPurchaseServiceFee] as num? ?? 0.0).toDouble(),
      shippingFee: (map[DatabaseTables.columnPurchaseShippingFee] as num? ?? 0.0).toDouble(),
      status: map[DatabaseTables.columnPurchaseStatus] as String? ?? 'received',
      poDays: map[DatabaseTables.columnPurchasePoDays] as int?,
      estimatedArrival: map[DatabaseTables.columnPurchaseEstimatedArrival] != null
          ? DateTime.tryParse(map[DatabaseTables.columnPurchaseEstimatedArrival].toString())
          : null,
      refundStatus: map[DatabaseTables.columnPurchaseRefundStatus] as String? ?? 'none',
      totalAmount: (map[DatabaseTables.columnPurchaseTotalAmount] as num).toDouble(),
      notes: map[DatabaseTables.columnPurchaseNotes] as String?,
      items: items,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseTables.columnUpdatedAt] as String),
      syncedAt: map[DatabaseTables.columnSyncedAt] != null
          ? DateTime.parse(map[DatabaseTables.columnSyncedAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnPurchaseStoreId: storeId,
      DatabaseTables.columnPurchaseUserId: userId,
      DatabaseTables.columnPurchaseInvoiceNumber: invoiceNumber,
      DatabaseTables.columnPurchaseSupplierId: supplierId,
      DatabaseTables.columnPurchaseSupplierName: supplierName,
      DatabaseTables.columnPurchaseType: purchaseType,
      DatabaseTables.columnPurchasePlatform: platform,
      DatabaseTables.columnPurchaseDeviceTag: deviceTag,
      DatabaseTables.columnPurchasePaymentAccount: paymentAccount,
      DatabaseTables.columnPurchaseServiceFee: serviceFee,
      DatabaseTables.columnPurchaseShippingFee: shippingFee,
      DatabaseTables.columnPurchaseStatus: status,
      DatabaseTables.columnPurchasePoDays: poDays,
      DatabaseTables.columnPurchaseEstimatedArrival: estimatedArrival?.toIso8601String(),
      DatabaseTables.columnPurchaseRefundStatus: refundStatus,
      DatabaseTables.columnPurchaseTotalAmount: totalAmount,
      DatabaseTables.columnPurchaseNotes: notes,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.columnUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.columnSyncedAt: syncedAt?.toIso8601String(),
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? storeId,
    String? userId,
    String? invoiceNumber,
    String? supplierId,
    String? supplierName,
    String? purchaseType,
    String? platform,
    String? deviceTag,
    String? paymentAccount,
    double? serviceFee,
    double? shippingFee,
    String? status,
    int? poDays,
    DateTime? estimatedArrival,
    String? refundStatus,
    double? totalAmount,
    String? notes,
    List<PurchaseItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      purchaseType: purchaseType ?? this.purchaseType,
      platform: platform ?? this.platform,
      deviceTag: deviceTag ?? this.deviceTag,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      serviceFee: serviceFee ?? this.serviceFee,
      shippingFee: shippingFee ?? this.shippingFee,
      status: status ?? this.status,
      poDays: poDays ?? this.poDays,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      refundStatus: refundStatus ?? this.refundStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
