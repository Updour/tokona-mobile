import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/settings/presentation/controllers/app_appearance_controller.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => buildLightTheme();

  static ThemeData buildLightTheme([AppAppearanceState appearance = const AppAppearanceState()]) {
    final preset = appearance.colorPreset;
    return _buildTheme(
      brightness: Brightness.light,
      preset: preset,
      fontFamily: appearance.fontFamily,
      scaffoldBg: AppColors.background,
      surface: AppColors.surface,
      inputFill: const Color(0xFFF1F5F9).withValues(alpha: 0.72),
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      borderColor: const Color(0xFFE2E8F0).withValues(alpha: 0.65),
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      statusBarBrightness: Brightness.dark,
    );
  }

  static ThemeData buildDarkTheme([AppAppearanceState appearance = const AppAppearanceState()]) {
    final preset = appearance.colorPreset;
    return _buildTheme(
      brightness: Brightness.dark,
      preset: preset,
      fontFamily: appearance.fontFamily,
      scaffoldBg: const Color(0xFF0B1120),
      surface: const Color(0xFF111827),
      inputFill: const Color(0xFF1E293B).withValues(alpha: 0.85),
      textPrimary: const Color(0xFFF8FAFC),
      textSecondary: const Color(0xFF94A3B8),
      borderColor: const Color(0xFF334155).withValues(alpha: 0.65),
      barrierColor: Colors.black.withValues(alpha: 0.65),
      statusBarBrightness: Brightness.light,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorPreset preset,
    required String? fontFamily,
    required Color scaffoldBg,
    required Color surface,
    required Color inputFill,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color barrierColor,
    required Brightness statusBarBrightness,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      splashFactory: InkSparkle.splashFactory,
      splashColor: preset.primary.withValues(alpha: 0.08),
      highlightColor: preset.primary.withValues(alpha: 0.03),
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: preset.primary,
        onPrimary: Colors.white,
        primaryContainer: isDark ? preset.primaryDark.withValues(alpha: 0.25) : preset.primaryContainer,
        onPrimaryContainer: isDark ? preset.primaryLight : preset.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
          statusBarBrightness: brightness,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: preset.primary, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13.5),
        labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.35 : 0.10),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 18,
        shadowColor: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.45 : 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: AppTypography.headingSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: textSecondary, height: 1.4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        selectedColor: preset.primary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: barrierColor,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: preset.primary,
          minimumSize: const Size(0, 50),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.button.copyWith(color: preset.primary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
