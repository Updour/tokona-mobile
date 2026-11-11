import 'package:tokona/core/database/database_tables.dart';

class CustomerModel {
  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? address;
  final String customerType; // 'umum', 'member', 'grosir'
  final String? notes;
  final double receivableBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const CustomerModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.address,
    this.customerType = 'umum',
    this.notes,
    this.receivableBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isMember => customerType.toLowerCase() == 'member';
  bool get isGrosir => customerType.toLowerCase() == 'grosir';
  bool get isUmum => !isMember && !isGrosir;
  bool get hasReceivable => receivableBalance > 0;

  String get typeLabel {
    switch (customerType.toLowerCase()) {
      case 'member':
        return 'Member Langganan';
      case 'grosir':
        return 'Pelanggan Grosir';
      default:
        return 'Pelanggan Umum';
    }
  }

  String get displaySubtitle {
    final parts = <String>[];
    if (phone != null && phone!.isNotEmpty) parts.add(phone!);
    if (address != null && address!.isNotEmpty) parts.add(address!);
    return parts.isEmpty ? typeLabel : parts.join(' • ');
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnCustomerStoreId: storeId,
      DatabaseTables.columnCustomerName: name,
      DatabaseTables.columnCustomerPhone: phone,
      DatabaseTables.columnCustomerAddress: address,
      DatabaseTables.columnCustomerType: customerType,
      DatabaseTables.columnCustomerNotes: notes,
      DatabaseTables.columnCustomerReceivableBalance: receivableBalance,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.columnUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.columnSyncedAt: syncedAt?.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnCustomerStoreId] as String,
      name: map[DatabaseTables.columnCustomerName] as String,
      phone: map[DatabaseTables.columnCustomerPhone] as String?,
      address: map[DatabaseTables.columnCustomerAddress] as String?,
      customerType: (map[DatabaseTables.columnCustomerType] as String?) ?? 'umum',
      notes: map[DatabaseTables.columnCustomerNotes] as String?,
      receivableBalance: (map[DatabaseTables.columnCustomerReceivableBalance] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseTables.columnUpdatedAt] as String),
      syncedAt: map[DatabaseTables.columnSyncedAt] != null
          ? DateTime.tryParse(map[DatabaseTables.columnSyncedAt] as String)
          : null,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? phone,
    String? address,
    String? customerType,
    String? notes,
    double? receivableBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      notes: notes ?? this.notes,
      receivableBalance: receivableBalance ?? this.receivableBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

