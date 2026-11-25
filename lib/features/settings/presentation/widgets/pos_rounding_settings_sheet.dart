import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/settings/presentation/widgets/pos_rounding_live_simulator.dart';
import 'package:tokona/features/settings/presentation/widgets/pos_rounding_mode_selector.dart';
import 'package:tokona/features/settings/presentation/widgets/pos_rounding_step_selector.dart';

class PosRoundingSettingsSheet extends ConsumerStatefulWidget {
  const PosRoundingSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PosRoundingSettingsSheet(),
    );
  }

  @override
  ConsumerState<PosRoundingSettingsSheet> createState() => _PosRoundingSettingsSheetState();
}

class _PosRoundingSettingsSheetState extends ConsumerState<PosRoundingSettingsSheet> {
  late bool _enabled;
  late String _mode;
  late int _step;
  final _testAmountController = TextEditingController(text: '14.350');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(appPreferencesProvider);
    _enabled = prefs.posRoundingEnabled;
    _mode = prefs.posRoundingMode;
    _step = prefs.posRoundingStep;
    _testAmountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _testAmountController.dispose();
    super.dispose();
  }

  double get _simulatedRawAmount => CurrencyFormatter.parse(_testAmountController.text);

  double get _simulatedRounding {
    if (!_enabled || _step <= 0 || _simulatedRawAmount <= 0) return 0.0;
    final stepD = _step.toDouble();
    double rounded = _simulatedRawAmount;
    switch (_mode) {
      case 'round_up':
        rounded = (_simulatedRawAmount / stepD).ceil() * stepD;
        break;
      case 'round_down':
        rounded = (_simulatedRawAmount / stepD).floor() * stepD;
        break;
      case 'nearest':
      default:
        rounded = (_simulatedRawAmount / stepD).round() * stepD;
        break;
    }
    return rounded - _simulatedRawAmount;
  }

  double get _simulatedFinalAmount => _simulatedRawAmount + _simulatedRounding;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final current = ref.read(appPreferencesProvider);
      final updated = current.copyWith(
        posRoundingEnabled: _enabled,
        posRoundingMode: _mode,
        posRoundingStep: _step,
      );

      await ref.read(appPreferencesProvider.notifier).save(updated);
      if (mounted) {
        AppToast.showSuccess(context, 'Pengaturan pembulatan harga berhasil disimpan');
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: viewInsetsBottom),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuad,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Master Pembulatan Harga',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Atur Round Up, Round Down & kelipatan kasir',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _enabled ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _enabled ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.exposure_rounded,
                                        size: 18,
                                        color: _enabled ? const Color(0xFF16A34A) : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pembulatan Kasir',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: _enabled ? const Color(0xFF15803D) : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _enabled ? 'Aktif: Total kasir otomatis dibulatkan' : 'Nonaktif: Menggunakan nominal persis tanpa pembulatan',
                                    style: TextStyle(fontSize: 11, color: _enabled ? const Color(0xFF166534) : AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _enabled,
                              activeThumbColor: const Color(0xFF16A34A),
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _enabled = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Arah Pembulatan (Mode)',
                        style: AppTypography.labelMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      PosRoundingModeSelector(
                        selectedMode: _mode,
                        onModeChanged: (m) => setState(() => _mode = m),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kelipatan Pembulatan (Rupiah)',
                        style: AppTypography.labelMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      PosRoundingStepSelector(
                        selectedStep: _step,
                        onStepChanged: (s) => setState(() => _step = s),
                      ),
                      const SizedBox(height: 20),
                      PosRoundingLiveSimulator(
                        enabled: _enabled,
                        mode: _mode,
                        step: _step,
                        testAmountController: _testAmountController,
                        simulatedRawAmount: _simulatedRawAmount,
                        simulatedRounding: _simulatedRounding,
                        simulatedFinalAmount: _simulatedFinalAmount,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Pengaturan Pembulatan',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
