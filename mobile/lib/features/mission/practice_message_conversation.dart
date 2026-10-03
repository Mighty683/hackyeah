import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// The fictional message and reply shown after local phone-number practice.
class PracticeMessageConversation extends StatelessWidget {
  const PracticeMessageConversation({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'A pretend conversation',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Practice only. Nothing was sent.',
          style: textTheme.bodyMedium?.copyWith(color: BaseboundColors.muted),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _MessageBubble(
            sender: 'You',
            message: 'I am away from windows.',
            color: BaseboundColors.sky,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: _MessageBubble(
            sender: 'Trusted adult',
            message: 'Good. Stay there and wait for the all-clear.',
            color: BaseboundColors.peach,
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.sender,
    required this.message,
    required this.color,
  });

  final String sender;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: SoftPanel(
        color: color,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(sender, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
