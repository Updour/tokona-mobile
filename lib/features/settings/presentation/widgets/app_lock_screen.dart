import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/settings/presentation/controllers/app_lock_controller.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _inputPin = '';
  String? _errorMessage;

  void _onKeyPress(String val) {
    if (_inputPin.length >= 6) return;
    HapticFeedback.selectionClick();
    setState(() {
      _inputPin += val;
      _errorMessage = null;
    });

    if (_inputPin.length == 6) {
      _validatePin();
    }
  }

  void _onBackspace() {
    if (_inputPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      _errorMessage = null;
    });
  }

  void _onClear() {
    if (_inputPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _inputPin = '';
      _errorMessage = null;
    });
  }

  void _validatePin() {
    final valid = ref.read(appLockProvider.notifier).unlockWithPin(_inputPin);
    if (!valid) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'PIN salah, silakan coba lagi';
        _inputPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeName = ref.watch(authProvider).currentStore?.name ?? 'Tokona POS';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.lock_rounded, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                storeName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aplikasi terkunci. Masukkan 6-digit PIN',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _inputPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    width: isFilled ? 16 : 14,
                    height: isFilled ? 16 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.primary : const Color(0xFF94A3B8),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
              const Spacer(flex: 3),
              _buildKeypad(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 14),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 14),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionKey(
              icon: Icons.clear_all_rounded,
              color: const Color(0xFF64748B),
              onTap: _onClear,
            ),
            _buildNumberKey('0'),
            _buildActionKey(
              icon: Icons.backspace_outlined,
              color: const Color(0xFF64748B),
              onTap: _onBackspace,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberKey(n)).toList(),
    );
  }

  Widget _buildNumberKey(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(number),
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(35),
        child: SizedBox(
          width: 68,
          height: 68,
          child: Center(
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
