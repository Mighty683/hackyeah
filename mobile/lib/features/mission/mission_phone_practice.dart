import 'package:flutter/material.dart';

import '../parent/data/family_plan.dart';
import 'practice_phone_keypad.dart';

class MissionPhonePractice extends StatelessWidget {
  const MissionPhonePractice({
    super.key,
    required this.contacts,
    required this.narration,
    required this.loadFailed,
    required this.onComplete,
    required this.onInstructionChanged,
    required this.onRetry,
    required this.audioControls,
  });

  final List<TrustedContact>? contacts;
  final String narration;
  final bool loadFailed;
  final VoidCallback onComplete;
  final ValueChanged<String> onInstructionChanged;
  final VoidCallback onRetry;
  final Widget audioControls;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contacts case final loadedContacts?)
          PracticePhoneKeypad(
            contacts: loadedContacts,
            onComplete: onComplete,
            onInstructionChanged: onInstructionChanged,
          )
        else ...[
          const Text(
            'Wpisz numer telefonu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              narration,
              style: const TextStyle(fontSize: 17, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          if (loadFailed) ...[
            FilledButton(
              onPressed: onRetry,
              child: const Text('Wczytaj ponownie'),
            ),
            TextButton(
              onPressed: onComplete,
              child: const Text('Ćwicz dalej bez numeru'),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
        audioControls,
      ],
    ),
  );
}
