import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/settings/domain/models/app_permission.dart';
import 'package:tokona/features/settings/presentation/controllers/rbac_controller.dart';

class RbacManagementSheet extends ConsumerStatefulWidget {
  const RbacManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RbacManagementSheet(),
    );
  }

  @override
  ConsumerState<RbacManagementSheet> createState() => _RbacManagementSheetState();
}

class _RbacManagementSheetState extends ConsumerState<RbacManagementSheet> {
  String _selectedRole = 'cashier';

  final List<String> _categories = [
    'Kasir & Penjualan',
    'Produk & Inventaris',
    'Pengadaan & Kulakan',
    'Keuangan & Laporan',
    'Pelanggan & Relasi',
    'Pengaturan & Sistem',
  ];

  @override
  Widget build(BuildContext context) {
    final rbacConfig = ref.watch(rbacProvider);
    final rbacNotifier = ref.read(rbacProvider.notifier);
    final isOwnerRole = _selectedRole == 'owner';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          _buildHeader(),
          const SizedBox(height: 14),
          _buildRoleSelector(),
          const SizedBox(height: 12),
          if (!isOwnerRole) _buildQuickActionRow(rbacNotifier),
          const Divider(height: 18),
          Expanded(
            child: isOwnerRole
                ? _buildOwnerPermanentView()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: _categories.map((cat) {
                      final items = AppPermission.values.where((p) => p.category == cat).toList();
                      return _buildCategorySection(cat, items, rbacConfig, rbacNotifier);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryDark, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hak Akses & Izin Menu', style: AppTypography.headingSmall.copyWith(fontSize: 15.5)),
              const Text('Atur menu yang boleh diakses Kasir dan Admin', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildRoleButton('cashier', 'Kasir', Icons.point_of_sale_rounded),
          _buildRoleButton('manager', 'Admin', Icons.manage_accounts_rounded),
          _buildRoleButton('owner', 'Owner', Icons.verified_user_rounded),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String roleKey, String label, IconData icon) {
    final isSelected = _selectedRole == roleKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedRole = roleKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionRow(RbacController notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Izin Aktif Role: ${_selectedRole == "cashier" ? "Kasir" : "Admin"}',
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
        ),
        Row(
          children: [
            InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                await notifier.setAllForRole(_selectedRole, true);
                if (mounted) AppToast.showSuccess(context, 'Semua izin diaktifkan');
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text('Beri Semua', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
              ),
            ),
            const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
            InkWell(
              onTap: () async {
                final ok = await AppDialog.showConfirmation(
                  context,
                  title: 'Reset Izin',
                  message: 'Kembalikan hak akses role ini ke standar bawaan?',
                  confirmText: 'Ya, Reset',
                );
                if (ok == true) {
                  await notifier.resetToDefaults(_selectedRole);
                  if (mounted) AppToast.showSuccess(context, 'Izin direset ke standar');
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text('Reset Default', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFE11D48))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<AppPermission> items, RolePermissionConfig config, RbacController notifier) {
    final activeCount = items.where((p) => config.hasPermission(_selectedRole, p.key)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: activeCount > 0 ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$activeCount / ${items.length} Aktif',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: activeCount > 0 ? const Color(0xFF0F766E) : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ...items.map((perm) {
            final isAllowed = config.hasPermission(_selectedRole, perm.key);
            return SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              activeThumbColor: const Color(0xFF0F766E),
              value: isAllowed,
              title: Text(perm.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              subtitle: Text(perm.description, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
              onChanged: (val) {
                HapticFeedback.lightImpact();
                notifier.togglePermission(roleKey: _selectedRole, permission: perm, isAllowed: val);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOwnerPermanentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFFD97706), size: 40),
            ),
            const SizedBox(height: 14),
            const Text('Role Owner: Hak Akses Penuh Permanen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Sebagai pemilik toko (HP Pusat), akun Owner selalu memiliki akses 100% tanpa batas ke seluruh menu, laporan laba, dan data sensitif.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
