import 'package:tokona/core/database/database_tables.dart';

class PaymentAccountModel {
  final String id;
  final String storeId;
  final String name;
  final String type;
  final String? accountNumber;
  final String? holderName;
  final double initialBalance;
  final double currentBalance;
  final bool isActive;
  final DateTime createdAt;

  const PaymentAccountModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.type = 'bank',
    this.accountNumber,
    this.holderName,
    this.initialBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    required this.createdAt,
  });

  factory PaymentAccountModel.fromMap(Map<String, dynamic> map) {
    return PaymentAccountModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnAccountStoreId] as String,
      name: map[DatabaseTables.columnAccountName] as String,
      type: map[DatabaseTables.columnAccountType] as String? ?? 'bank',
      accountNumber: map[DatabaseTables.columnAccountNumber] as String?,
      holderName: map[DatabaseTables.columnAccountHolderName] as String?,
      initialBalance: (map[DatabaseTables.columnAccountInitialBalance] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map[DatabaseTables.columnAccountCurrentBalance] as num?)?.toDouble() ?? 0.0,
      isActive: (map[DatabaseTables.columnAccountIsActive] as int?) != 0,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnAccountStoreId: storeId,
      DatabaseTables.columnAccountName: name,
      DatabaseTables.columnAccountType: type,
      DatabaseTables.columnAccountNumber: accountNumber,
      DatabaseTables.columnAccountHolderName: holderName,
      DatabaseTables.columnAccountInitialBalance: initialBalance,
      DatabaseTables.columnAccountCurrentBalance: currentBalance,
      DatabaseTables.columnAccountIsActive: isActive ? 1 : 0,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  PaymentAccountModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? type,
    String? accountNumber,
    String? holderName,
    double? initialBalance,
    double? currentBalance,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PaymentAccountModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      type: type ?? this.type,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
