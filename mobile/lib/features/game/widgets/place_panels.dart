import 'package:flutter/material.dart';

import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';
import '../../landmarks/data/landmark.dart';
import '../../landmarks/widgets/landmark_photo.dart';
import '../walking_route.dart';

class SelectedPlacePanel extends StatelessWidget {
  const SelectedPlacePanel({
    required this.place,
    required this.map,
    required this.photoDirectory,
    required this.hasDirections,
    required this.onClose,
    required this.onNavigate,
    super.key,
  });
  final Landmark place;
  final DemoMap map;
  final String photoDirectory;
  final bool hasDirections;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.isDestination
                      ? '${place.icon} ${place.name}'
                      : place.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Zamknij miejsce',
                icon: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
          if (place.hasPhoto)
            LandmarkPhoto(
              path: '$photoDirectory/${place.photoName}',
              assetPath: place.photoAsset,
              label: place.name,
              height: 120,
            ),
          const SizedBox(height: 8),
          if (!place.isDemo && !map.contains(place.latitude, place.longitude))
            const Text('Poza pobraną mapą. Wskazówki spaceru są niedostępne.')
          else if (!place.isDemo)
            FilledButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.directions_walk, size: 24),
              label: const Text('Idźcie tutaj razem'),
            ),
          if (hasDirections)
            TextButton(
              onPressed: onClose,
              child: const Text('Wróć do wskazówek'),
            ),
        ],
      ),
    ),
  );
}

class WalkingRoutePanel extends StatelessWidget {
  const WalkingRoutePanel({
    required this.target,
    required this.photoDirectory,
    required this.hasRoute,
    required this.remaining,
    required this.nearPlace,
    required this.recognised,
    required this.onRecognise,
    required this.onStop,
    super.key,
  });
  final Landmark target;
  final String photoDirectory;
  final bool hasRoute;
  final double remaining;
  final bool nearPlace;
  final bool recognised;
  final VoidCallback onRecognise;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Do miejsca: ${target.name}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (target.hasPhoto) ...[
            const SizedBox(height: 8),
            LandmarkPhoto(
              path: '$photoDirectory/${target.photoName}',
              assetPath: target.photoAsset,
              label: target.name,
              height: 80,
            ),
          ],
          if (hasRoute) ...[
            Text('Do końca zaznaczonej ścieżki: ${metres(remaining)}'),
            const Text(
              'Ścieżka kończy się blisko znacznika. Sprawdź z dorosłym.',
              style: TextStyle(fontSize: 12),
            ),
          ],
          if (nearPlace && !recognised)
            FilledButton(
              onPressed: onRecognise,
              child: const Text('Rozpoznaję to miejsce'),
            ),
          TextButton(
            onPressed: onStop,
            child: const Text('Zatrzymaj wskazówki'),
          ),
        ],
      ),
    ),
  );
}
