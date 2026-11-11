class SupplierModel {
  final String id;
  final String storeId;
  final String name;
  final String type;
  final String? platform;
  final String? contactName;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const SupplierModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.type = 'offline',
    this.platform,
    this.contactName,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isOnline => type.toLowerCase() == 'online';
  bool get isOffline => !isOnline;

  String get displaySubtitle {
    if (isOnline) {
      final p = platform ?? 'Online';
      return phone != null && phone!.isNotEmpty ? '$p • $phone' : p;
    }
    final contact = contactName != null && contactName!.isNotEmpty ? contactName! : 'Distributor Offline';
    return phone != null && phone!.isNotEmpty ? '$contact • $phone' : contact;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'type': type,
      'platform': platform,
      'contact_name': contactName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'offline',
      platform: map['platform'] as String?,
      contactName: map['contact_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }

  SupplierModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? type,
    String? platform,
    String? contactName,
    String? phone,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      type: type ?? this.type,
      platform: platform ?? this.platform,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
