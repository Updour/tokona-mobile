import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/pos/domain/models/sale_item_model.dart';

class SaleModel {
  final String id;
  final String storeId;
  final String userId;
  final String? customerId;
  final String invoiceNumber;
  final String? customerName;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final double cashPaid;
  final double changeAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime? dueDate;
  final List<SaleItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const SaleModel({
    required this.id,
    required this.storeId,
    required this.userId,
    this.customerId,
    required this.invoiceNumber,
    this.customerName,
    required this.totalAmount,
    this.discountAmount = 0.0,
    required this.finalAmount,
    required this.cashPaid,
    required this.changeAmount,
    this.paymentMethod = 'CASH',
    this.status = 'COMPLETED',
    this.notes,
    this.dueDate,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isVoided => status.toUpperCase() == 'VOIDED';
  bool get isKasbon => paymentMethod.toUpperCase() == 'KASBON';
  bool get isOverdue => isKasbon && !isVoided && dueDate != null && DateTime.now().isAfter(dueDate!);
  int? get daysUntilDue => dueDate != null ? dueDate!.difference(DateTime.now()).inDays : null;

  double get totalProfit {
    if (isVoided) return 0.0;
    double profit = 0.0;
    for (final item in items) {
      profit += item.totalProfit;
    }
    return profit - discountAmount;
  }

  double get totalItemQuantity {
    double qty = 0;
    for (final item in items) {
      qty += item.quantity;
    }
    return qty;
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, {List<SaleItemModel> items = const []}) {
    return SaleModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnSaleStoreId] as String,
      userId: map[DatabaseTables.columnSaleUserId] as String,
      customerId: map[DatabaseTables.columnSaleCustomerId] as String?,
      invoiceNumber: map[DatabaseTables.columnSaleInvoiceNumber] as String,
      customerName: map[DatabaseTables.columnSaleCustomerName] as String?,
      totalAmount: (map[DatabaseTables.columnSaleTotalAmount] as num).toDouble(),
      discountAmount: (map[DatabaseTables.columnSaleDiscountAmount] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map[DatabaseTables.columnSaleFinalAmount] as num).toDouble(),
      cashPaid: (map[DatabaseTables.columnSaleCashPaid] as num).toDouble(),
      changeAmount: (map[DatabaseTables.columnSaleChangeAmount] as num).toDouble(),
      paymentMethod: map[DatabaseTables.columnSalePaymentMethod] as String? ?? 'CASH',
      status: map[DatabaseTables.columnSaleStatus] as String? ?? 'COMPLETED',
      notes: map[DatabaseTables.columnSaleNotes] as String?,
      dueDate: map[DatabaseTables.columnSaleDueDate] != null
          ? DateTime.tryParse(map[DatabaseTables.columnSaleDueDate] as String)
          : null,
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
      DatabaseTables.columnSaleStoreId: storeId,
      DatabaseTables.columnSaleUserId: userId,
      DatabaseTables.columnSaleCustomerId: customerId,
      DatabaseTables.columnSaleInvoiceNumber: invoiceNumber,
      DatabaseTables.columnSaleCustomerName: customerName,
      DatabaseTables.columnSaleTotalAmount: totalAmount,
      DatabaseTables.columnSaleDiscountAmount: discountAmount,
      DatabaseTables.columnSaleFinalAmount: finalAmount,
      DatabaseTables.columnSaleCashPaid: cashPaid,
      DatabaseTables.columnSaleChangeAmount: changeAmount,
      DatabaseTables.columnSalePaymentMethod: paymentMethod,
      DatabaseTables.columnSaleStatus: status,
      DatabaseTables.columnSaleNotes: notes,
      DatabaseTables.columnSaleDueDate: dueDate?.toIso8601String(),
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.columnUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.columnSyncedAt: syncedAt?.toIso8601String(),
    };
  }

  SaleModel copyWith({
    String? id,
    String? storeId,
    String? userId,
    String? customerId,
    String? invoiceNumber,
    String? customerName,
    double? totalAmount,
    double? discountAmount,
    double? finalAmount,
    double? cashPaid,
    double? changeAmount,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? dueDate,
    List<SaleItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      cashPaid: cashPaid ?? this.cashPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
