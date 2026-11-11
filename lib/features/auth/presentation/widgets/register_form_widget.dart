import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/dtos/register_dto.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterFormWidget extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function(RegisterDto dto) onSubmit;
  final VoidCallback onSwitchToLogin;

  const RegisterFormWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      final dto = RegisterDto(
        storeName: _storeNameController.text.trim(),
        ownerFullName: _ownerNameController.text.trim(),
        storePhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      widget.onSubmit(dto);
    }
  }

  Widget _buildSectionHeader(String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0D9488)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('LANGKAH 1', 'INFORMASI TOKO'),
          AuthTextField(
            controller: _storeNameController,
            label: 'Nama Toko / Usaha',
            hint: 'Contoh: Toko Berkah Mandiri',
            prefixIcon: Icons.store_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _ownerNameController,
            label: 'Nama Pemilik Toko',
            hint: 'Contoh: Rohman Pratama',
            prefixIcon: Icons.badge_outlined,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pemilik wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _phoneController,
            label: 'Nomor WhatsApp / HP Toko (Opsional)',
            hint: '081234567890',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _buildSectionHeader('LANGKAH 2', 'AKUN PENGELOLA (ADMIN)'),
          AuthTextField(
            controller: _usernameController,
            label: 'Nama Pengguna Admin',
            hint: 'Contoh: admin / nama_anda',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nama pengguna wajib diisi';
              if (v.trim().length < 3) return 'Minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _passwordController,
            label: 'Kata Sandi',
            hint: 'Minimal 6 karakter',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 22),
          AnimatedScale(
            scale: _isButtonPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: widget.isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: widget.isLoading ? const Color(0xFFCBD5E1) : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: widget.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: widget.isLoading ? null : (_) => setState(() => _isButtonPressed = true),
                  onTapUp: widget.isLoading
                      ? null
                      : (_) {
                          setState(() => _isButtonPressed = false);
                          _submit();
                        },
                  onTapCancel: () => setState(() => _isButtonPressed = false),
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: widget.isLoading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Menyiapkan Toko...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 17),
                              SizedBox(width: 8),
                              Text(
                                'Buka Toko Sekarang',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya toko?',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onSwitchToLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
