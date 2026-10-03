import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';
import '../../../ui/parent_setup_ui.dart';
import '../../game/location_permission_setup.dart';

Future<void> configureParentLocation(
  BuildContext context,
  LocationPermissionSetup permission,
) async {
  final status = await permission.check();
  if (!context.mounted) return;
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Map location'),
      content: Text(_locationMessage(status)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Close'),
        ),
        if (status != LocationPermissionStatus.granted)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              status == LocationPermissionStatus.settingsRequired
                  ? 'Open Android settings'
                  : 'Allow location',
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
        ? 'Allow location while using the app. Reopen Our map when ready.'
        : 'Open Android app settings to allow location while using the app.';
  } else {
    message = _locationMessage(await permission.requestFromAdult());
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _locationMessage(LocationPermissionStatus status) => switch (status) {
  LocationPermissionStatus.granted => 'Location is allowed. The map and Help can use GPS while open; no track is saved.',
  LocationPermissionStatus.denied => 'Location is off. Allow it to show the map’s blue dot. Photos and practice work without it.',
  LocationPermissionStatus.settingsRequired => 'Android requires app settings to allow location. Choose location access while using the app. Photos and practice work without it.',
  LocationPermissionStatus.unavailable => 'Could not check location permission. You can retry; photos and practice still work.',
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
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: BaseboundColors.coral,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    ) ??
    false;
