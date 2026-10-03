import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';
import 'landmark_photo.dart';

class SelectedLandmarkCard extends StatelessWidget {
  const SelectedLandmarkCard({
    required this.entry,
    required this.photoDirectory,
    required this.onEdit,
    super.key,
  });
  final Landmark entry;
  final String photoDirectory;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LandmarkPhoto(
            path: '$photoDirectory/${entry.photoName}',
            label: entry.name,
          ),
          const SizedBox(height: 12),
          Text(
            entry.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          ),
          if (entry.isDemo)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Fictional demo photo and pin · recognition only',
                style: TextStyle(color: BaseboundColors.muted),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const BaseboundIcon(BaseboundIconName.edit),
              label: const Text('Edit landmark'),
            ),
          ),
        ],
      ),
    ),
  );
}

class LandmarkLibraryEntry extends StatelessWidget {
  const LandmarkLibraryEntry({
    required this.entry,
    required this.photoDirectory,
    required this.onMap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final Landmark entry;
  final String photoDirectory;
  final bool onMap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: SizedBox(
          width: 64,
          child: LandmarkPhoto(
            path: '$photoDirectory/${entry.photoName}',
            label: entry.name,
            height: 56,
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        subtitleTextStyle: const TextStyle(
          color: BaseboundColors.muted,
          fontSize: 16,
          height: 1.4,
        ),
        subtitle: !onMap
            ? const Text('Outside this demo map')
            : entry.isDemo
            ? const Text('Fictional demo landmark')
            : null,
        onTap: onEdit,
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: 'Delete ${entry.name}',
          icon: const BaseboundIcon(BaseboundIconName.delete),
        ),
      ),
    ),
  );
}
