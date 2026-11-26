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
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _storeNameController.dispose();
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
        storeName: _storeNameController.text.trim(),
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
            controller: _storeNameController,
            label: 'Nama Toko',
            hint: 'Contoh: Warung Maju Jaya',
            prefixIcon: Icons.store_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama toko jangan dikosongkan ya' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _ownerNameController,
            label: 'Nama Pemilik (Untuk Login)',
            hint: 'Contoh: Budi Santoso',
            prefixIcon: Icons.badge_outlined,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pemilik wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _phoneController,
            label: 'No. WhatsApp Aktif',
            hint: 'Contoh: 081234567890',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                if (!WhatsAppService.isValidWhatsAppNumber(v.trim())) {
                  return 'Format nomor WA belum pas (minimal 10 digit)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: 'Buat Password',
            hint: 'Minimal 6 karakter',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Buat password dulu ya';
              if (v.length < 6) return 'Minimal 6 karakter ya';
              return null;
            },
          ),
          const SizedBox(height: 20),
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
                                'Lagi nyiapin tokomu...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          )
                        : const Text(
                            'Mulai Buka Toko',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
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
                'Sudah punya akun toko?',
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
                  'Masuk di Sini',
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
