import 'package:flutter/material.dart';

import 'basebound_icons.dart';

abstract final class BaseboundColors {
  static const ink = Color(0xFF25334A);
  static const blue = Color(0xFF2C5F9B);
  static const sky = Color(0xFFEAF0F7);
  static const cream = Color(0xFFF7F5F0);
  static const peach = Color(0xFFF1EDE5);
  static const green = Color(0xFF327554);
  static const greenLight = Color(0xFFEDF5EF);
  static const coral = Color(0xFFB64242);
  static const coralLight = Color(0xFFFAEEEE);
  static const muted = Color(0xFF5E6A7A);
  static const border = Color(0xFFCED5DE);
}

abstract final class BaseboundTheme {
  static ThemeData training() => _build(help: false);

  /// Flat, restrained styling keeps the unreviewed help prototype distinct.
  static ThemeData help() => _build(help: true);

  static ThemeData _build({required bool help}) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BaseboundColors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primary: help ? BaseboundColors.ink : BaseboundColors.blue,
          onPrimary: Colors.white,
          secondary: BaseboundColors.green,
          onSurface: BaseboundColors.ink,
          surface: Colors.white,
          error: const Color(0xFFB52D36),
          outline: BaseboundColors.muted,
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Nunito',
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final text = base.textTheme.apply(
      bodyColor: BaseboundColors.ink,
      displayColor: BaseboundColors.ink,
    );
    return base.copyWith(
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const BaseboundIcon(BaseboundIconName.back),
        closeButtonIconBuilder: (_) =>
            const BaseboundIcon(BaseboundIconName.cross),
      ),
      scaffoldBackgroundColor: help
          ? const Color(0xFFF3F6FA)
          : BaseboundColors.cream,
      textTheme: text.copyWith(
        headlineLarge: text.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 18, height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: help ? const Color(0xFFF3F6FA) : BaseboundColors.cream,
        foregroundColor: BaseboundColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: BaseboundColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BaseboundColors.ink,
          backgroundColor: Colors.white,
          minimumSize: const Size(56, 56),
          side: const BorderSide(color: BaseboundColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BaseboundColors.ink,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: BaseboundColors.ink,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FBFF),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BaseboundColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: BaseboundColors.border),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BaseboundColors.blue,
      ),
    );
  }
}
