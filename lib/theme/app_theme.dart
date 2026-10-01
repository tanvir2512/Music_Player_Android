import 'package:flutter/material.dart';

/// Central color palette for Pulse Music — a purple & black modern theme.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0710);
  static const Color surface = Color(0xFF150F1E);
  static const Color surfaceElevated = Color(0xFF1E1730);
  static const Color card = Color(0xFF1A1424);
  static const Color cardAlt = Color(0xFF221A32);

  static const Color primary = Color(0xFF9B5CFF);
  static const Color primaryDark = Color(0xFF6C2BD9);
  static const Color primaryLight = Color(0xFFC49BFF);

  static const Color vinylYellow = Color(0xFFFFC93C);
  static const Color vinylBlack = Color(0xFF0D0D0D);

  static const Color textPrimary = Color(0xFFF5F3FA);
  static const Color textSecondary = Color(0xFFA79BC0);
  static const Color textMuted = Color(0xFF6E6482);

  static const Color divider = Color(0xFF2A2338);
  static const Color error = Color(0xFFFF5A7A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B2FE0), Color(0xFFB06CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF150F22), Color(0xFF0B0710)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient vinylGradient = RadialGradient(
    colors: [Color(0xFF232323), Color(0xFF060606)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.vinylYellow,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.divider,
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      splashColor: AppColors.primary.withOpacity(0.12),
      highlightColor: Colors.transparent,
      dividerColor: AppColors.divider,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}