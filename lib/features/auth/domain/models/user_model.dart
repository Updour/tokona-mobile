enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  owner('owner', 'Pemilik Toko'),
  manager('manager', 'Manajer'),
  cashier('cashier', 'Kasir');

  final String key;
  final String label;

  const UserRole(this.key, this.label);

  static UserRole fromString(String roleKey) {
    return UserRole.values.firstWhere(
      (element) => element.key == roleKey,
      orElse: () => UserRole.cashier,
    );
  }
}

class UserModel {
  final String id;
  final String storeId;
  final String username;
  final String fullName;
  final String passwordHash;
  final String salt;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const UserModel({
    required this.id,
    required this.storeId,
    required this.username,
    required this.fullName,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isOwner => role == UserRole.owner || role == UserRole.superAdmin;
  bool get canManageInventory => role != UserRole.cashier;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'username': username,
      'full_name': fullName,
      'password_hash': passwordHash,
      'salt': salt,
      'role': role.key,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      role: UserRole.fromString(map['role'] as String),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }
}
