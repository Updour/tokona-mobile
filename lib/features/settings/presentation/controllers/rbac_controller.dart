import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/app_permission.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

final rbacProvider = StateNotifierProvider<RbacController, RolePermissionConfig>((ref) {
  return RbacController();
});

class RbacController extends StateNotifier<RolePermissionConfig> {
  RbacController() : super(RolePermissionConfig.defaults()) {
    _load();
  }

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_rbac_permissions.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        state = RolePermissionConfig.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.toMap()));
    } catch (_) {}
  }

  bool hasPermission(UserModel? user, AppPermission permission) {
    if (user == null) return false;
    if (user.isOwner) return true;
    return state.hasPermission(user.role.key, permission.key);
  }

  bool canAccessShortcut(UserModel? user, String shortcutId) {
    if (user == null) return false;
    if (user.isOwner) return true;

    final perm = _mapShortcutToPermission(shortcutId);
    if (perm == null) return true;
    return hasPermission(user, perm);
  }

  AppPermission? _mapShortcutToPermission(String shortcutId) {
    switch (shortcutId) {
      case 'kasir':
        return AppPermission.posCheckout;
      case 'jadwal_wa':
        return AppPermission.holdCart;
      case 'jatuh_tempo':
        return AppPermission.viewKasbonDue;
      case 'pesanan_masuk':
      case 'riwayat_kulakan':
      case 'dana_refund':
        return AppPermission.purchaseHistory;
      case 'riwayat_transaksi':
        return AppPermission.salesHistory;
      case 'tutup_toko':
        return AppPermission.closingShift;
      case 'katalog':
        return AppPermission.viewProducts;
      case 'tambah_produk':
      case 'kategori':
        return AppPermission.manageProducts;
      case 'restok':
        return AppPermission.restockPurchase;
      case 'stok_perangkat':
      case 'hp_belanja':
        return AppPermission.deviceStock;
      case 'rekening_bank':
        return AppPermission.paymentAccounts;
      case 'modal_prive':
        return AppPermission.storeCapital;
      case 'pelanggan':
        return AppPermission.manageCustomers;
      case 'supplier':
        return AppPermission.manageSuppliers;
      case 'printer_struk':
      case 'pengaturan_dinamis':
      case 'backup':
        return AppPermission.storeSettings;
      default:
        return null;
    }
  }

  Future<void> togglePermission({
    required String roleKey,
    required AppPermission permission,
    required bool isAllowed,
  }) async {
    state = state.copyWithPermission(
      roleKey: roleKey,
      permissionKey: permission.key,
      isAllowed: isAllowed,
    );
    await _persist();
    AuditLogService.log(
      storeId: 'default',
      userId: 'OWNER',
      userName: 'Pemilik Toko',
      userRole: 'owner',
      actionType: AuditActionType.rbac,
      title: 'Perubahan Hak Akses (${roleKey.toUpperCase()})',
      description: 'Izin "${permission.label}" ${isAllowed ? "diaktifkan" : "dinonaktifkan"}.',
    );
  }

  Future<void> setAllForRole(String roleKey, bool allowed) async {
    final updatedMap = <String, Set<String>>{};
    for (final entry in state.permissionsByRole.entries) {
      updatedMap[entry.key] = Set<String>.from(entry.value);
    }

    if (allowed) {
      updatedMap[roleKey] = {for (final p in AppPermission.values) p.key};
    } else {
      updatedMap[roleKey] = <String>{};
    }

    state = RolePermissionConfig(permissionsByRole: updatedMap);
    await _persist();
  }

  Future<void> resetToDefaults(String roleKey) async {
    final defaultConf = RolePermissionConfig.defaults();
    final updatedMap = <String, Set<String>>{};
    for (final entry in state.permissionsByRole.entries) {
      updatedMap[entry.key] = Set<String>.from(entry.value);
    }
    updatedMap[roleKey] = defaultConf.permissionsByRole[roleKey] ?? <String>{};

    state = RolePermissionConfig(permissionsByRole: updatedMap);
    await _persist();
  }
}
