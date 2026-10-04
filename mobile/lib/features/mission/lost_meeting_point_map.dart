import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/widgets/landmark_map.dart';
import '../landmarks/widgets/landmark_photo.dart';
import 'data/lost_practice_context.dart';

/// Reuses Our map's photo pins and gestures without GPS, routes or arrival claims.
class LostMeetingPointMap extends StatelessWidget {
  const LostMeetingPointMap({
    required this.target,
    required this.landmarks,
    required this.photoDirectory,
    required this.onSelected,
    required this.onHelp,
    this.map,
    super.key,
  });

  final LostPracticePlace target;
  final List<Landmark> landmarks;
  final String photoDirectory;
  final ValueChanged<String> onSelected;
  final VoidCallback onHelp;
  final DemoMap? map;

  Future<void> _places(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Miejsca na Naszej mapie',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              for (final place in landmarks) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelected(place.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        if (place.hasPhoto)
                          LandmarkPhoto(
                            fit: BoxFit.contain,
                            path: '$photoDirectory/${place.photoName}',
                            assetPath: place.photoAsset,
                            label: place.name,
                            height: 100,
                          ),
                        if (place.isDestination)
                          const BaseboundIcon(BaseboundIconName.home, size: 64),
                        Text(place.name),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LandmarkPhoto(
        fit: BoxFit.contain,
        path: target.photoPath,
        label: target.label,
        height: 110,
      ),
      const SizedBox(height: 12),
      LandmarkMap(
        map: map,
        landmarks: landmarks,
        photoDirectory: photoDirectory,
        onSelected: (place) => onSelected(place.id),
      ),
      const SizedBox(height: 12),
      const Text(
        'Znalezienie znacznika nie oznacza dotarcia na miejsce. Idź z dorosłym.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _places(context),
        icon: const BaseboundIcon(BaseboundIconName.map),
        label: const Text('Miejsca'),
      ),
      TextButton(onPressed: onHelp, child: const Text('Nie mogę znaleźć')),
    ],
  );
}
