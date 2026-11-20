import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const ForgotPasswordActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          elevation: 0,
        ),
        icon: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class ForgotPasswordStep1 extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailPhoneController;
  final bool isLoading;
  final VoidCallback onRequestOtp;
  final VoidCallback onWhatsAppHelp;

  const ForgotPasswordStep1({
    super.key,
    required this.usernameController,
    required this.emailPhoneController,
    required this.isLoading,
    required this.onRequestOtp,
    required this.onWhatsAppHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: usernameController,
          label: 'Nama Pengguna',
          hint: 'Contoh: kasir / owner',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: emailPhoneController,
          label: 'Email / WhatsApp Pemilik',
          hint: 'Contoh: toko@gmail.com / 0812xxx',
          prefixIcon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 16),
        ForgotPasswordActionButton(
          label: 'Kirim Kode Verifikasi',
          icon: Icons.send_rounded,
          isLoading: isLoading,
          onTap: onRequestOtp,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onWhatsAppHelp,
          icon: const Icon(Icons.chat_rounded, size: 16, color: Color(0xFF16A34A)),
          label: const Text(
            'Khusus Kasir: Minta Bantuan Pemilik',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            side: const BorderSide(color: Color(0xFFBBF7D0), width: 0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordStep2 extends StatelessWidget {
  final String username;
  final TextEditingController otpController;
  final bool isLoading;
  final VoidCallback onVerifyOtp;
  final VoidCallback onResend;

  const ForgotPasswordStep2({
    super.key,
    required this.username,
    required this.otpController,
    required this.isLoading,
    required this.onVerifyOtp,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Kode OTP telah dibuat untuk akun $username. Silakan masukkan kode verifikasi 6-digit.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: otpController,
          label: 'Kode OTP 6-Digit',
          hint: '123456',
          prefixIcon: Icons.pin_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ForgotPasswordActionButton(
          label: 'Verifikasi Kode OTP',
          icon: Icons.check_circle_outline_rounded,
          isLoading: isLoading,
          onTap: onVerifyOtp,
        ),
        TextButton(
          onPressed: onResend,
          child: const Text('Ganti data atau kirim ulang', style: TextStyle(fontSize: 11.5, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class ForgotPasswordStep3 extends StatelessWidget {
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSavePassword;

  const ForgotPasswordStep3({
    super.key,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleVisibility,
    required this.onSavePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: newPasswordController,
          label: 'Kata Sandi Baru',
          hint: 'Minimal 6 karakter',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: obscurePassword,
          onToggleVisibility: onToggleVisibility,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: confirmPasswordController,
          label: 'Ulangi Kata Sandi Baru',
          hint: 'Masukkan kata sandi yang sama',
          prefixIcon: Icons.lock_reset_rounded,
          isPassword: true,
          obscureText: obscurePassword,
        ),
        const SizedBox(height: 16),
        ForgotPasswordActionButton(
          label: 'Simpan Kata Sandi Baru',
          icon: Icons.save_rounded,
          isLoading: isLoading,
          onTap: onSavePassword,
        ),
      ],
    );
  }
}

class ForgotPasswordStep4 extends StatelessWidget {
  final VoidCallback onFinish;

  const ForgotPasswordStep4({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 36),
        ),
        const SizedBox(height: 12),
        const Text(
          'Kata Sandi Berhasil Diperbarui!',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Silakan gunakan kata sandi baru Anda untuk masuk ke sistem Tokona.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ForgotPasswordActionButton(
          label: 'Kembali & Masuk Akun',
          icon: Icons.login_rounded,
          onTap: onFinish,
        ),
      ],
    );
  }
}
