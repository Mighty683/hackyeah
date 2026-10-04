import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Shared instruction hierarchy for fictional practice scenes.
class PracticeStepHeader extends StatelessWidget {
  const PracticeStepHeader({
    super.key,
    required this.title,
    this.narration,
    this.hint,
    this.audioControls = const SizedBox.shrink(),
    this.notice,
    this.titleKey,
  });

  final String title;
  final String? narration;
  final String? hint;
  final Widget audioControls;
  final Widget? notice;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (notice != null) ...[notice!, const SizedBox(height: 12)],
      Text(
        title,
        key: titleKey,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      if (narration != null) ...[
        const SizedBox(height: 8),
        Text(narration!, style: const TextStyle(fontSize: 17, height: 1.4)),
      ],
      if (hint != null) ...[
        const SizedBox(height: 8),
        Text(hint!, style: const TextStyle(color: BaseboundColors.muted)),
      ],
      audioControls,
    ],
  );
}
