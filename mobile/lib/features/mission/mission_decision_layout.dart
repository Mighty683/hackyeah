import 'package:flutter/material.dart';

/// Gives portrait scenes the full content width without cropping their targets.
class MissionDecisionLayout extends StatelessWidget {
  const MissionDecisionLayout({
    super.key,
    required this.instruction,
    required this.scene,
    required this.feedback,
    required this.hasFeedback,
    this.scrollController,
  });

  final Widget instruction;
  final Widget scene;
  final Widget feedback;
  final bool hasFeedback;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
      if (largeText || constraints.maxWidth <= constraints.maxHeight) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [instruction, const SizedBox(height: 16), scene],
                ),
              ),
            ),
            if (hasFeedback) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .35,
                ),
                child: SingleChildScrollView(child: feedback),
              ),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: instruction,
                  ),
                ),
                if (hasFeedback)
                  Flexible(child: SingleChildScrollView(child: feedback)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Center(child: scene)),
        ],
      );
    },
  );
}
