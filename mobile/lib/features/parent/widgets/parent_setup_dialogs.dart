import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../ui/basebound_ui.dart';
import '../../../ui/parent_setup_ui.dart';
import '../../game/location_permission_setup.dart';

Future<void> configureParentLocation(
  BuildContext context,
  LocationPermissionSetup permission,
) async {
  if (kIsWeb) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pozycja na mapie demo'),
        content: const Text(
          'Demo w przeglądarce używa fikcyjnej, stałej pozycji na mapie areny. '
          'Nie prosi o zgodę na GPS przeglądarki. Nie odczytuje prawdziwej pozycji.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
    return;
  }
  final status = await permission.check();
  if (!context.mounted) return;
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Lokalizacja mapy'),
      content: Text(_locationMessage(status)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Zamknij'),
        ),
        if (status != LocationPermissionStatus.granted)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              status == LocationPermissionStatus.settingsRequired
                  ? 'Otwórz ustawienia Androida'
                  : 'Zezwól na lokalizację',
            ),
          ),
      ],
    ),
  );
  if (proceed != true || !context.mounted) return;
  String message;
  if (status == LocationPermissionStatus.settingsRequired) {
    final opened = await permission.openSettings();
    message = opened
        ? 'Zezwól na lokalizację podczas używania aplikacji. Następnie otwórz ponownie Naszą mapę.'
        : 'Otwórz ustawienia aplikacji w Androidzie i zezwól na lokalizację podczas jej używania.';
  } else {
    message = _locationMessage(await permission.requestFromAdult());
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _locationMessage(LocationPermissionStatus status) => switch (status) {
  LocationPermissionStatus.granted => 'Lokalizacja jest dozwolona. Mapa i Pomoc mogą używać GPS, gdy są otwarte; trasa nie jest zapisywana.',
  LocationPermissionStatus.denied => 'Lokalizacja jest wyłączona. Włącz ją, aby zobaczyć niebieską kropkę na mapie. Zdjęcia i ćwiczenia działają bez niej.',
  LocationPermissionStatus.settingsRequired => 'Android wymaga włączenia lokalizacji w ustawieniach aplikacji. Wybierz dostęp podczas używania aplikacji. Zdjęcia i ćwiczenia działają bez niego.',
  LocationPermissionStatus.unavailable => 'Nie udało się sprawdzić zgody na lokalizację. Spróbuj ponownie; zdjęcia i ćwiczenia nadal działają.',
};

Future<bool> confirmParentDeletion(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: parentSetupTheme(),
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zachowaj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: BaseboundColors.coral,
              ),
              child: const Text('Usuń'),
            ),
          ],
        ),
      ),
    ) ??
    false;
