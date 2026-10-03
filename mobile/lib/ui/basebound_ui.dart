/// Shared visual language for fictional practice; help uses a quieter variant.
library;

import 'package:flutter/material.dart';

import '../widgets/basebound_mascot.dart';
import 'basebound_icons.dart';

abstract final class BaseboundColors {
  static const ink = Color(0xFF112568);
  static const blue = Color(0xFF0967DA);
  static const sky = Color(0xFFE6F2FF);
  static const cream = Color(0xFFFFF6E7);
  static const peach = Color(0xFFFFE5C3);
  static const green = Color(0xFF19853B);
  static const greenLight = Color(0xFFE8F8DF);
  static const coral = Color(0xFFE54949);
  static const coralLight = Color(0xFFFFEEEE);
  static const muted = Color(0xFF536184);
  static const border = Color(0xFFDDE5F1);
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
      borderRadius: BorderRadius.circular(help ? 16 : 24),
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
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 18, height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: help
            ? const Color(0xFFF3F6FA)
            : const Color(0xFFF5F9FF),
        foregroundColor: BaseboundColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BaseboundColors.ink,
          backgroundColor: Colors.white,
          minimumSize: const Size(56, 56),
          side: const BorderSide(color: BaseboundColors.border, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: BaseboundColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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

/// Decorative sky or warm room tint; content and scrolling remain caller-owned.
class IllustratedBackdrop extends StatelessWidget {
  const IllustratedBackdrop({
    super.key,
    required this.child,
    this.warm = false,
  });

  final Widget child;
  final bool warm;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: warm
            ? [BaseboundColors.cream, BaseboundColors.peach]
            : [
                const Color(0xFFF4F9FF),
                BaseboundColors.sky,
                BaseboundColors.cream,
              ],
      ),
    ),
    child: SizedBox.expand(child: child),
  );
}

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: borderColor ?? Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D112568),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

class BaseboundBadge extends StatelessWidget {
  const BaseboundBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = BaseboundColors.blue,
  });

  final String label;
  final BaseboundIconName? icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          BaseboundIcon(icon!, size: 18, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Calm practice feedback; a symbol supplements color for every outcome.
class BaseboundGuide extends StatelessWidget {
  const BaseboundGuide({
    super.key,
    required this.message,
    this.positive = true,
    this.pose,
    this.mascotOnRight = false,
  });

  final String message;
  final bool positive;
  final DinoPose? pose;
  final bool mascotOnRight;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        textDirection: mascotOnRight ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (constraints.maxWidth >= 220 &&
              MediaQuery.textScalerOf(context).scale(1) < 1.6) ...[
            BaseboundMascot(
              size: 76,
              pose: pose ?? (positive ? DinoPose.celebrate : DinoPose.calm),
              faceLeft: mascotOnRight,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseboundIcon(
                  positive ? BaseboundIconName.check : BaseboundIconName.idea,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
