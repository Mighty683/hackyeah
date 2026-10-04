import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'photo_action_icon.dart';
import '../data/demo_landmarks.dart';

Future<ImageSource?> chooseLandmarkPhotoSource(
  BuildContext context,
) => showModalBottomSheet<ImageSource>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Zapisz rozpoznawalne miejsce',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const PhotoActionIcon(),
            label: const Text('Zrób zdjęcie'),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const PhotoActionIcon(gallery: true),
            label: const Text('Wybierz z galerii'),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  ),
);

/// Browser demo substitutes bundled fictional photos for camera/gallery access.
Future<String?> chooseDemoLandmarkPhoto(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wybierz przykładowe zdjęcie',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Fikcyjne przykłady zastępują tutaj aparat Androida.'),
              const SizedBox(height: 16),
              for (final demo in demoLandmarks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    icon: const PhotoActionIcon(gallery: true),
                    label: Text(demo.landmark.name),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => Navigator.pop(context, demo.asset),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
