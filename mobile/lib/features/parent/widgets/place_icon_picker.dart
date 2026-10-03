import 'package:flutter/material.dart';

/// Shared Unicode place symbols for family pins and photo landmarks.
class PlaceIconPicker extends StatelessWidget {
  const PlaceIconPicker({
    required this.selectedIcon,
    required this.onSelected,
    super.key,
  });

  final String selectedIcon;
  final ValueChanged<String> onSelected;

  static const _icons = {
    '📍': 'Place',
    '🏠': 'Home',
    '🏫': 'School',
    '🏪': 'Shop',
    '🌳': 'Park',
    '🛝': 'Playground',
    '🚏': 'Bus stop',
    '⛲': 'Fountain',
    '📚': 'Library',
    '⚽': 'Sports',
    '🏥': 'Hospital',
    '👪': 'Family',
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Choose a place icon',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final entry in _icons.entries)
            ChoiceChip(
              label: Text('${entry.key} ${entry.value}'),
              selected: selectedIcon == entry.key,
              onSelected: (_) => onSelected(entry.key),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
        ],
      ),
    ],
  );
}
