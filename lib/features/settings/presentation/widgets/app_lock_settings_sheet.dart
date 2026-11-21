import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/settings/presentation/controllers/app_lock_controller.dart';

class AppLockSettingsSheet extends ConsumerStatefulWidget {
  const AppLockSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppLockSettingsSheet(),
    );
  }

  @override
  ConsumerState<AppLockSettingsSheet> createState() => _AppLockSettingsSheetState();
}

class _AppLockSettingsSheetState extends ConsumerState<AppLockSettingsSheet> {
  Future<void> _promptSetPin({bool isChanging = false}) async {
    final pin1 = await _showPinInputDialog(
      title: isChanging ? 'Buat PIN Baru' : 'Atur PIN Keamanan',
      subtitle: 'Masukkan 6 digit angka PIN pengunci',
    );
    if (pin1 == null || pin1.length != 6) return;

    if (!mounted) return;
    final pin2 = await _showPinInputDialog(
      title: 'Konfirmasi PIN',
      subtitle: 'Masukkan kembali 6 digit PIN Anda',
    );
    if (pin2 == null) return;

    if (pin1 != pin2) {
      if (mounted) AppToast.showError(context, 'Konfirmasi PIN tidak cocok!');
      return;
    }

    await ref.read(appLockProvider.notifier).setPin(pin1);
    if (mounted) {
      AppToast.showSuccess(context, 'PIN pengunci aplikasi berhasil disimpan');
    }
  }

  Future<String?> _showPinInputDialog({required String title, required String subtitle}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Lanjut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final isEnabled = lockState.config.isEnabled && lockState.config.hasPin;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kunci Aplikasi (PIN 6 Digit)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Amankan akses kasir dengan 6 digit nomor PIN', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: isEnabled,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Aktifkan Kunci PIN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Minta 6-digit PIN saat aplikasi dibuka', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  onChanged: (val) async {
                    if (val) {
                      await _promptSetPin();
                    } else {
                      await ref.read(appLockProvider.notifier).disableLock();
                      if (context.mounted) AppToast.showInfo(context, 'Kunci aplikasi dinonaktifkan');
                    }
                  },
                ),
                if (isEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 20),
                    title: const Text('Ubah 6-Digit PIN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Ganti nomor PIN pengunci aplikasi saat ini', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
                    onTap: () => _promptSetPin(isChanging: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
