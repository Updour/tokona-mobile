import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/data/services/forgot_password_service.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/forgot_password_step_views.dart';

class ForgotPasswordBottomSheet extends ConsumerStatefulWidget {
  const ForgotPasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ForgotPasswordBottomSheet(),
    );
  }

  @override
  ConsumerState<ForgotPasswordBottomSheet> createState() => _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends ConsumerState<ForgotPasswordBottomSheet> {
  int _step = 1;
  bool _isLoading = false;
  String? _errorMessage;

  final _usernameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _generatedOtp;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    final user = _usernameController.text.trim();
    var dest = _emailPhoneController.text.trim();
    if (user.isEmpty) {
      setState(() => _errorMessage = 'Masukkan nama pengguna akun Anda');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1. Cek di Database Lokal SQLite dulu, jika tidak ada baru arahkan ke Supabase!
    final check = await ForgotPasswordService.checkUserLocation(user);
    if (!check.exists) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Akun "$user" tidak ditemukan di database lokal maupun Cloud.';
      });
      return;
    }

    if (dest.isEmpty && check.phone != null && check.phone!.isNotEmpty) {
      dest = check.phone!;
      _emailPhoneController.text = dest;
    }

    if (dest.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Masukkan nomor handphone terdaftar untuk pengiriman OTP';
      });
      return;
    }

    try {
      final otp = await ForgotPasswordService.generateAndSendOtp(
        username: user,
        emailOrPhone: dest,
      );
      if (!mounted) return;
      setState(() {
        _generatedOtp = otp;
        _isLoading = false;
        _step = 2;
      });
      final source = check.isLocal ? 'Database Lokal' : 'Cloud';
      AppToast.showSuccess(context, 'Akun ditemukan di $source (${check.roleLabel ?? "User"})');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP 6-Digit: $otp (Berlaku 10 menit)'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memproses OTP: $e';
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode OTP verifikasi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isValid = await ForgotPasswordService.verifyOtp(
      username: _usernameController.text.trim(),
      otpCode: otp,
      expectedFallbackOtp: _generatedOtp,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (isValid) {
        _step = 3;
      } else {
        _errorMessage = 'Kode OTP salah atau telah kadaluarsa';
      }
    });
  }

  Future<void> _handleSaveNewPassword() async {
    final pw = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (pw.length < 6) {
      setState(() => _errorMessage = 'Kata sandi minimal 6 karakter');
      return;
    }
    if (pw != confirm) {
      setState(() => _errorMessage = 'Konfirmasi kata sandi tidak cocok');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).resetPassword(
      username: _usernameController.text.trim(),
      newPassword: pw,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _step = 4);
    } else {
      final err = ref.read(authProvider).errorMessage;
      setState(() => _errorMessage = err ?? 'Gagal mengatur ulang kata sandi');
    }
  }

  Future<void> _openWhatsAppToOwner() async {
    final user = _usernameController.text.trim();
    final phone = await ForgotPasswordService.getOwnerPhone();
    if (phone == null || phone.isEmpty) {
      setState(() => _errorMessage = 'Nomor handphone pemilik toko belum tersimpan');
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final target = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
    final text = Uri.encodeComponent('Halo Pemilik Toko, saya ($user) lupa kata sandi Tokona. Mohon bantuan reset kata sandi.');
    final url = Uri.parse('https://wa.me/$target?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      setState(() => _errorMessage = 'Gagal membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 4 ? 'Berhasil Diperbarui' : 'Pemulihan Kata Sandi',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        _step == 1 ? 'Langkah 1: Identifikasi Akun' : _step == 2 ? 'Langkah 2: Masukkan Kode OTP' : _step == 3 ? 'Langkah 3: Buat Kata Sandi Baru' : 'Akun Anda siap digunakan kembali',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFFFECACA), width: 0.6)),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 11.5, fontWeight: FontWeight.w600))),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            if (_step == 1)
              ForgotPasswordStep1(
                usernameController: _usernameController,
                emailPhoneController: _emailPhoneController,
                isLoading: _isLoading,
                onRequestOtp: _handleRequestOtp,
                onWhatsAppHelp: _openWhatsAppToOwner,
              ),
            if (_step == 2)
              ForgotPasswordStep2(
                username: _usernameController.text,
                otpController: _otpController,
                isLoading: _isLoading,
                onVerifyOtp: _handleVerifyOtp,
                onResend: () => setState(() => _step = 1),
              ),
            if (_step == 3)
              ForgotPasswordStep3(
                newPasswordController: _newPasswordController,
                confirmPasswordController: _confirmPasswordController,
                obscurePassword: _obscurePassword,
                isLoading: _isLoading,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                onSavePassword: _handleSaveNewPassword,
              ),
            if (_step == 4)
              ForgotPasswordStep4(
                onFinish: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}
