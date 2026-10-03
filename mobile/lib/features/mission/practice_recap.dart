import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Shared celebration and numbered reminders for scenario recall and completion.
class PracticeRecap extends StatelessWidget {
  const PracticeRecap({
    super.key,
    required this.title,
    required this.praise,
    required this.points,
    this.titleKey,
  });

  final String title;
  final String praise;
  final List<({String title, String description})> points;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        key: titleKey,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      const SizedBox(height: 12),
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
    return SoftPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BaseboundColors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  point.description,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
