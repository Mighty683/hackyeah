import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';

/// Shared celebration and illustrated reminders for scenario recall and completion.
class PracticeRecap extends StatelessWidget {
  const PracticeRecap({
    super.key,
    this.title,
    required this.praise,
    required this.points,
    required this.pointIcons,
    this.titleKey,
  }) : assert(points.length == pointIcons.length);

  final String? title;
  final String praise;
  final List<({String title, String description})> points;

  /// Illustrations in the same order as the displayed and narrated reminders.
  final List<BaseboundIconName> pointIcons;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (title != null) ...[
        Text(
          title!,
          key: titleKey,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
      ],
      BaseboundGuide(message: praise),
      const SizedBox(height: 16),
      for (var index = 0; index < points.length; index++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _point(index),
        ),
    ],
  );

  Widget _point(int index) {
    final point = points[index];
    return _PracticeRecapPoint(
      number: index + 1,
      icon: pointIcons[index],
      title: point.title,
      description: point.description,
    );
  }
}

class _PracticeRecapPoint extends StatelessWidget {
  const _PracticeRecapPoint({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final int number;
  final BaseboundIconName icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SoftPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _illustration(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _illustration() => Column(
    children: [
      BaseboundIcon(icon, size: 48),
      const SizedBox(height: 8),
      Text(
        '$number.',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: BaseboundColors.blue,
        ),
      ),
    ],
  );
}
