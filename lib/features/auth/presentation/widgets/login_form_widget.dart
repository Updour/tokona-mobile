import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/auth/presentation/widgets/forgot_password_bottom_sheet.dart';

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
            label: 'Username atau No. HP',
            hint: 'Contoh: budi atau 081234567890',
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username atau nomor HP wajib diisi ya';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Masukkan password Anda',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onToggleVisibility: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ForgotPasswordBottomSheet.show(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  'Lupa Password?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedScale(
            scale: _isButtonPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 50,
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
                          color: const Color(0xFF0D9488).withValues(alpha: 0.28),
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
                                'Sebentar, lagi dicek...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          )
                        : const Text(
                            'Masuk Sekarang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Baru pakai Tokona?',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onSwitchToRegister,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Buat Toko Sekarang',
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
