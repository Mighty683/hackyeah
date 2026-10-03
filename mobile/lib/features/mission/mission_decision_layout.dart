import 'package:flutter/material.dart';

/// Keeps scene position steady while allowing instructions and feedback to scroll.
class MissionDecisionLayout extends StatelessWidget {
  const MissionDecisionLayout({
    super.key,
    required this.instruction,
    required this.scene,
    required this.feedback,
    required this.hasFeedback,
  });

  final Widget instruction;
  final Widget scene;
  final Widget feedback;
  final bool hasFeedback;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
      if (largeText) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              instruction,
              const SizedBox(height: 16),
              scene,
              if (hasFeedback) ...[const SizedBox(height: 12), feedback],
            ],
          ),
        );
      }
      if (constraints.maxWidth > constraints.maxHeight) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SingleChildScrollView(child: instruction)),
                  if (hasFeedback)
                    Flexible(child: SingleChildScrollView(child: feedback)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Center(child: scene)),
          ],
        );
      }
      // Reserve the same footer before and after a tap so wrong answers do not
      // resize the scene or shift the child's on-screen position.
      final feedbackHeight = (constraints.maxHeight * .22).clamp(96.0, 160.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height:
                (constraints.maxHeight -
                        constraints.maxWidth * 1.5 -
                        feedbackHeight -
                        24)
                    .clamp(64.0, constraints.maxHeight * .35),
            child: SingleChildScrollView(child: instruction),
          ),
          const SizedBox(height: 12),
          Expanded(child: Center(child: scene)),
          const SizedBox(height: 12),
          SizedBox(
            height: feedbackHeight,
            child: SingleChildScrollView(
              child: hasFeedback ? feedback : const SizedBox.shrink(),
            ),
          ),
        ],
      );
    },
  );
}
