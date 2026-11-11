import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';

class LoginFormWidget extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function(LoginDto dto) onSubmit;
  final VoidCallback onSwitchToRegister;

  const LoginFormWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onSwitchToRegister,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      final dto = LoginDto(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      widget.onSubmit(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _usernameController,
            label: 'Nama Pengguna / Akun',
            hint: 'Contoh: kasir1 / admin',
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pengguna wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            label: 'Kata Sandi',
            hint: 'Masukkan kata sandi',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onToggleVisibility: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi wajib diisi';
              }
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
                                'Memverifikasi...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Masuk ke Toko',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 15, color: Color(0xFF0D9488)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data tersimpan aman & bekerja 100% offline di perangkat ini.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum punya toko?',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onSwitchToRegister,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Buka Toko Baru',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
