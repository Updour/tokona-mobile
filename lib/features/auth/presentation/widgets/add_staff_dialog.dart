import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

class AddStaffDialog extends ConsumerStatefulWidget {
  final String storeId;
  final VoidCallback onStaffAdded;

  const AddStaffDialog({super.key, required this.storeId, required this.onStaffAdded});

  static void show(BuildContext context, {required String storeId, required VoidCallback onStaffAdded}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AddStaffDialog(storeId: storeId, onStaffAdded: onStaffAdded),
    );
  }

  @override
  ConsumerState<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends ConsumerState<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.cashier;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.createStaffUser(
        storeId: widget.storeId,
        username: _usernameController.text.trim(),
        fullName: _nameController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      final activeUser = ref.read(authProvider).currentUser;
      AuditLogService.log(
        storeId: widget.storeId,
        userId: activeUser?.id ?? '',
        userName: activeUser?.fullName ?? 'Owner',
        userRole: activeUser?.role.label ?? 'Owner',
        actionType: AuditActionType.rbac,
        title: 'Daftar Pengguna Baru',
        description: 'Mendaftarkan ${_selectedRole == UserRole.cashier ? "Kasir" : "Admin"}: ${_nameController.text.trim()} (@${_usernameController.text.trim()})',
      );

      if (!mounted) return;
      AppToast.showSuccess(context, 'Pengguna "${_nameController.text}" berhasil didaftarkan');
      widget.onStaffAdded();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20, 20, 20, mediaQuery.viewInsets.bottom > 0 ? 16 : 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Staf', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Text('Buat akun kasir atau admin', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Nama Lengkap', Icons.badge_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Username Login', Icons.alternate_email_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
                    if (v.trim().length < 3) return 'Minimal 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Kata Sandi Awal', Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Kata sandi minimal 6 karakter' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  isExpanded: true,
                  decoration: _inputDecoration('Jabatan', Icons.shield_outlined),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.cashier,
                      child: Text('Kasir (Transaksi & Nota)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: UserRole.manager,
                      child: Text('Admin (Operasional)', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
