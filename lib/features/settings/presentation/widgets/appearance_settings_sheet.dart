import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/modern_sheet_widgets.dart';
import 'package:tokona/features/settings/presentation/controllers/app_appearance_controller.dart';

class AppearanceSettingsSheet extends ConsumerWidget {
  const AppearanceSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppearanceSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appAppearanceProvider);
    final notifier = ref.read(appAppearanceProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF111827) : Colors.white;
    final subtleBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 28, offset: const Offset(0, -6)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModernSheetHeader(
              title: 'Tema & Tampilan',
              subtitle: 'Mode layar, gradien warna & font',
              icon: Icons.palette_rounded,
              accentColor: state.colorPreset.primary,
              onClose: () => Navigator.of(context).pop(),
              trailingAction: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.reset();
                  AppToast.showInfo(context, 'Tampilan dikembalikan ke default');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: subtleBg, borderRadius: BorderRadius.circular(12)),
                  child: Text('Reset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textSecondary)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: state.colorPreset.gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: state.colorPreset.primary.withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(state.themeMode.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pratinjau ${state.colorPreset.label}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: state.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${state.themeMode.label} • ${state.fontOption.label}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: state.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('MODE LAYAR', textSecondary),
            Row(
              children: AppThemeModeOption.values.map((mode) {
                final selected = state.themeMode == mode;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: mode != AppThemeModeOption.dark ? 8 : 0),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setThemeMode(mode);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? state.colorPreset.primary : subtleBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [BoxShadow(color: state.colorPreset.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(mode.icon, size: 20, color: selected ? Colors.white : textSecondary),
                            const SizedBox(height: 5),
                            Text(
                              mode.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? Colors.white : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('WARNA GRADIEN', textSecondary),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppColorPreset.values.map((preset) {
                final selected = state.colorPreset == preset;
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.setColorPreset(preset);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: preset.gradient,
                          shape: BoxShape.circle,
                          border: selected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: [
                            BoxShadow(
                              color: preset.primary.withValues(alpha: selected ? 0.45 : 0.18),
                              blurRadius: selected ? 14 : 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? state.colorPreset.primary : textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('GAYA FONT', textSecondary),
            Row(
              children: AppFontOption.values.map((font) {
                final selected = state.fontOption == font;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: font != AppFontOption.system ? 8 : 0),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setFontOption(font);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: selected ? state.colorPreset.primary : subtleBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [BoxShadow(color: state.colorPreset.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Aa',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                fontFamily: font.family,
                                color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              font.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                fontFamily: font.family,
                                color: selected ? Colors.white : textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.6),
      ),
    );
  }
}
