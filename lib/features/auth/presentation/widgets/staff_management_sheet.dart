import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/add_staff_dialog.dart';
import 'package:tokona/features/auth/presentation/widgets/staff_pairing_qr_dialog.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

class StaffManagementSheet extends ConsumerStatefulWidget {
  const StaffManagementSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StaffManagementSheet(),
    );
  }

  @override
  ConsumerState<StaffManagementSheet> createState() => _StaffManagementSheetState();
}

class _StaffManagementSheetState extends ConsumerState<StaffManagementSheet> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final store = ref.read(authProvider).currentStore;
    if (store == null) return;
    try {
      final repo = ref.read(authRepositoryProvider);
      final users = await repo.getStoreUsers(store.id);
      if (mounted) setState(() { _users = users; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStaff(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Karyawan?'),
        content: Text('Yakin ingin menghapus akses untuk ${user.fullName} (@${user.username})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(authRepositoryProvider);
        await repo.deleteStaffUser(user.id);
        final activeUser = ref.read(authProvider).currentUser;
        final store = ref.read(authProvider).currentStore;
        if (store != null) {
          AuditLogService.log(
            storeId: store.id,
            userId: activeUser?.id ?? '',
            userName: activeUser?.fullName ?? 'Owner',
            userRole: activeUser?.role.label ?? 'Owner',
            actionType: AuditActionType.rbac,
            title: 'Hapus Akses Karyawan',
            description: 'Mencabut akses ${user.role.label}: ${user.fullName} (@${user.username})',
          );
        }
        if (mounted) {
          AppToast.showSuccess(context, 'Karyawan berhasil dihapus');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) AppToast.showError(context, 'Gagal menghapus: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.group_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manajemen Karyawan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Daftar kasir, admin & pairing offline', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: store == null ? null : () => AddStaffDialog.show(context, storeId: store.id, onStaffAdded: _loadUsers),
            icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
            label: const Text('+ Daftarkan Karyawan Baru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('Belum ada staf terdaftar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                    : ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _buildUserCard(_users[index], store),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, StoreModel? store) {
    final isOwner = user.isOwner;
    final isCashier = user.role == UserRole.cashier;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isOwner ? const Color(0xFFFEF3C7) : isCashier ? const Color(0xFFCCFBF1) : AppColors.primaryContainer,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isOwner ? const Color(0xFFD97706) : isCashier ? AppColors.primary : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOwner ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.label,
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: isOwner ? const Color(0xFFB45309) : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                Text('@${user.username}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (!isOwner && store != null) ...[
            IconButton(
              icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 22),
              tooltip: 'QR Pairing HP Kasir (Offline)',
              onPressed: () => StaffPairingQrDialog.show(context, staff: user, store: store),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
              tooltip: 'Hapus Akses',
              onPressed: () => _deleteStaff(user),
            ),
          ],
        ],
      ),
    );
  }
}
