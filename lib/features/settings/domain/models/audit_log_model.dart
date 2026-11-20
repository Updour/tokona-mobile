enum AuditActionType {
  auth('auth', 'Autentikasi & Akun'),
  pairing('pairing', 'Pairing Perangkat'),
  transaction('transaction', 'Transaksi Kasir'),
  shift('shift', 'Tutup Shift / Kasir'),
  rbac('rbac', 'Hak Akses & RBAC'),
  inventory('inventory', 'Inventaris & Stok'),
  product('product', 'Master Produk & Harga'),
  purchase('purchase', 'Pembelian & Terima Barang'),
  finance('finance', 'Kasbon & Keuangan'),
  security('security', 'Kunci & Keamanan');

  final String key;
  final String label;
  const AuditActionType(this.key, this.label);

  static AuditActionType fromKey(String key) {
    return AuditActionType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => AuditActionType.auth,
    );
  }
}

class AuditLogModel {
  final String id;
  final String storeId;
  final String userId;
  final String userName;
  final String userRole;
  final AuditActionType actionType;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? deviceTag;

  const AuditLogModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.actionType,
    required this.title,
    required this.description,
    required this.timestamp,
    this.deviceTag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'action_type': actionType.key,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'device_tag': deviceTag,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] as String,
      storeId: (map['store_id'] as String?) ?? '',
      userId: (map['user_id'] as String?) ?? '',
      userName: (map['user_name'] as String?) ?? 'Sistem',
      userRole: (map['user_role'] as String?) ?? 'User',
      actionType: AuditActionType.fromKey((map['action_type'] as String?) ?? 'auth'),
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      timestamp: DateTime.tryParse((map['timestamp'] as String?) ?? '') ?? DateTime.now(),
      deviceTag: map['device_tag'] as String?,
    );
  }
}
