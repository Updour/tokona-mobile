import 'package:tokona/core/database/database_tables.dart';

class CustomerReceivablePaymentModel {
  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime paymentDate;
  final String? accountId;
  final String? accountName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerReceivablePaymentModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentDate,
    this.accountId,
    this.accountName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnPaymentStoreId: storeId,
      DatabaseTables.columnPaymentCustomerId: customerId,
      DatabaseTables.columnPaymentCustomerName: customerName,
      DatabaseTables.columnPaymentAmount: amount,
      DatabaseTables.columnPaymentDate: paymentDate.toIso8601String(),
      DatabaseTables.columnPaymentAccountId: accountId,
      DatabaseTables.columnPaymentAccountName: accountName,
      DatabaseTables.columnPaymentNotes: notes,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory CustomerReceivablePaymentModel.fromMap(Map<String, dynamic> map) {
    return CustomerReceivablePaymentModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnPaymentStoreId] as String,
      customerId: map[DatabaseTables.columnPaymentCustomerId] as String,
      customerName: map[DatabaseTables.columnPaymentCustomerName] as String,
      amount: (map[DatabaseTables.columnPaymentAmount] as num).toDouble(),
      paymentDate: DateTime.parse(map[DatabaseTables.columnPaymentDate] as String),
      accountId: map[DatabaseTables.columnPaymentAccountId] as String?,
      accountName: map[DatabaseTables.columnPaymentAccountName] as String?,
      notes: map[DatabaseTables.columnPaymentNotes] as String?,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseTables.columnUpdatedAt] as String),
    );
  }
}
