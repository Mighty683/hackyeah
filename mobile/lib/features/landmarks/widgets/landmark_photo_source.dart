import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'photo_action_icon.dart';

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
            'Save a recognisable place',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const PhotoActionIcon(),
            label: const Text('Take a photo'),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const PhotoActionIcon(gallery: true),
            label: const Text('Choose from gallery'),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  ),
);
