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
            'Rozmowa na niby',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tylko ćwiczenie. Nic nie wysłano.',
          style: textTheme.bodyMedium?.copyWith(color: BaseboundColors.muted),
        ),
        const SizedBox(height: 24),
        const _MessageBubble(
          sender: 'Ty',
          message: 'Jestem z dala od okien.',
          color: BaseboundColors.sky,
        ),
        const SizedBox(height: 16),
        const _MessageBubble(
          sender: 'Zaufana osoba dorosła',
          message: 'Dobrze. Zostań tam i czekaj na odwołanie alarmu.',
          color: BaseboundColors.peach,
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
