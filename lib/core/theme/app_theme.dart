import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF10251F);
  static const emerald = Color(0xFF0D6252);
  static const gold = Color(0xFFB9812E);
  static const canvas = Color(0xFFF5F1E8);
  static const paper = Color(0xFFFFFDF8);
  static const sage = Color(0xFFDDE9E3);
  static const outline = Color(0xFFD4D8D2);
  static const muted = Color(0xFF65716C);
  static const danger = Color(0xFFB34235);
  static const warning = Color(0xFFD28A22);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.light,
          surface: AppColors.paper,
        ).copyWith(
          primary: AppColors.emerald,
          secondary: AppColors.gold,
          error: AppColors.danger,
          onSurface: AppColors.ink,
          outline: AppColors.outline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.35),
        bodyMedium: TextStyle(fontSize: 14, height: 1.35),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.outline),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.paper,
        indicatorColor: AppColors.sage,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.outline),
        shape: StadiumBorder(),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
      ),
    );
  }
}
