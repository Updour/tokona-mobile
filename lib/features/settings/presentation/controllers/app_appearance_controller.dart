import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum AppThemeModeOption {
  system('Default', Icons.brightness_auto_rounded),
  light('Siang', Icons.light_mode_rounded),
  dark('Malam', Icons.dark_mode_rounded);

  final String label;
  final IconData icon;
  const AppThemeModeOption(this.label, this.icon);
}

enum AppColorPreset {
  teal('Teal', Color(0xFF0D9488), Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFFCCFBF1)),
  ocean('Ocean', Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF38BDF8), Color(0xFFE0F2FE)),
  indigo('Indigo', Color(0xFF4F46E5), Color(0xFF4338CA), Color(0xFF818CF8), Color(0xFFE0E7FF)),
  rose('Rose', Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFFFB7185), Color(0xFFFFE4E6)),
  amber('Amber', Color(0xFFD97706), Color(0xFFB45309), Color(0xFFFBBF24), Color(0xFFFEF3C7));

  final String label;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryContainer;

  const AppColorPreset(
    this.label,
    this.primary,
    this.primaryDark,
    this.primaryLight,
    this.primaryContainer,
  );

  LinearGradient get gradient => LinearGradient(
        colors: [primaryDark, primary, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

enum AppFontOption {
  jakarta('Jakarta Sans', 'PlusJakartaSans'),
  inter('Inter', 'Inter'),
  system('Bawaan HP', null);

  final String label;
  final String? family;
  const AppFontOption(this.label, this.family);
}

class AppAppearanceState {
  final AppThemeModeOption themeMode;
  final AppColorPreset colorPreset;
  final AppFontOption fontOption;

  const AppAppearanceState({
    this.themeMode = AppThemeModeOption.system,
    this.colorPreset = AppColorPreset.teal,
    this.fontOption = AppFontOption.jakarta,
  });

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeModeOption.light:
        return ThemeMode.light;
      case AppThemeModeOption.dark:
        return ThemeMode.dark;
      case AppThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  String? get fontFamily => fontOption.family;

  AppAppearanceState copyWith({
    AppThemeModeOption? themeMode,
    AppColorPreset? colorPreset,
    AppFontOption? fontOption,
  }) {
    return AppAppearanceState(
      themeMode: themeMode ?? this.themeMode,
      colorPreset: colorPreset ?? this.colorPreset,
      fontOption: fontOption ?? this.fontOption,
    );
  }

  Map<String, dynamic> toMap() => {
        'theme_mode': themeMode.name,
        'color_preset': colorPreset.name,
        'font_option': fontOption.name,
      };

  factory AppAppearanceState.fromMap(Map<String, dynamic> map) {
    return AppAppearanceState(
      themeMode: AppThemeModeOption.values.firstWhere(
        (e) => e.name == map['theme_mode'],
        orElse: () => AppThemeModeOption.system,
      ),
      colorPreset: AppColorPreset.values.firstWhere(
        (e) => e.name == map['color_preset'],
        orElse: () => AppColorPreset.teal,
      ),
      fontOption: AppFontOption.values.firstWhere(
        (e) => e.name == map['font_option'],
        orElse: () => AppFontOption.jakarta,
      ),
    );
  }
}

final appAppearanceProvider = StateNotifierProvider<AppAppearanceController, AppAppearanceState>((ref) {
  return AppAppearanceController();
});

class AppAppearanceController extends StateNotifier<AppAppearanceState> {
  AppAppearanceController() : super(const AppAppearanceState()) {
    _load();
  }

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_appearance_settings.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        state = AppAppearanceState.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(AppThemeModeOption mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> setColorPreset(AppColorPreset preset) async {
    state = state.copyWith(colorPreset: preset);
    await _persist();
  }

  Future<void> setFontOption(AppFontOption font) async {
    state = state.copyWith(fontOption: font);
    await _persist();
  }

  Future<void> reset() async {
    state = const AppAppearanceState();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.toMap()));
    } catch (_) {}
  }
}
