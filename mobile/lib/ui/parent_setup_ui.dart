import 'package:flutter/material.dart';

import 'basebound_icons.dart';
import 'basebound_ui.dart';

/// A calmer variant of the game palette for editing device-local records.
ThemeData parentSetupTheme() {
  final theme = BaseboundTheme.training();
  const fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: BaseboundColors.border),
  );
  return theme.copyWith(
    scaffoldBackgroundColor: BaseboundColors.cream,
    appBarTheme: theme.appBarTheme.copyWith(
      backgroundColor: Colors.white,
      foregroundColor: BaseboundColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: BaseboundColors.blue, width: 2),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.muted,
        fontSize: 16,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(fontFamily: 'Nunito', color: BaseboundColors.muted),
      prefixIconColor: BaseboundColors.muted,
      counterStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.muted,
      ),
    ),
  );
}

class ParentEditorNote extends StatelessWidget {
  const ParentEditorNote({
    required this.message,
    required this.icon,
    super.key,
  });

  final String message;
  final BaseboundIconName icon;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: BaseboundColors.sky,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseboundIcon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: BaseboundColors.ink,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}
