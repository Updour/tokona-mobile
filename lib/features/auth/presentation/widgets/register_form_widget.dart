import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
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
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      final rawOwner = _ownerNameController.text.trim();
      final rawPhone = _phoneController.text.trim();
      final sanitizedPhone = rawPhone.isNotEmpty ? WhatsAppService.sanitizePhoneNumber(rawPhone) : null;

      final dto = RegisterDto(
        storeName: 'Toko $rawOwner',
        ownerFullName: rawOwner,
        storePhone: sanitizedPhone,
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
            controller: _ownerNameController,
            label: 'Nama',
            hint: 'Budi Santoso',
            prefixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi nama dulu' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _phoneController,
            label: 'No. HP / WA',
            hint: '08123456789',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Isi no. HP / WA';
              }
              if (!WhatsAppService.isValidWhatsAppNumber(v.trim())) {
                return 'No. HP minimal 10 digit';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Min. 6 karakter',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Isi password';
              if (v.length < 6) return 'Min. 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0D9488)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Nama toko & alamat diisi nanti',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedScale(
            scale: _isButtonPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 110),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: widget.isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: widget.isLoading ? const Color(0xFFCBD5E1) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.32),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                  borderRadius: BorderRadius.circular(16),
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
                                'Menyimpan...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.2),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun?',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onSwitchToLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Masuk',
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
