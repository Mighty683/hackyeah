import 'package:flutter/material.dart';

import '../../widgets/basebound_mascot.dart';
import '../mission/practice_launcher.dart';
import '../help/help_screen.dart';
import '../parent/parent_screen.dart';

/// Role selection keeps adult information out of the child's first screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const _WelcomeChoices(),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeChoices extends StatelessWidget {
  const _WelcomeChoices();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: BaseboundMascot()),
        const SizedBox(height: 16),
        const Text(
          'Welcome to Basebound',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        const Text(
          'Are you an adult or a child?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(20),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () => _openScreen(context, const PracticeLauncher()),
          icon: const Icon(Icons.face_outlined),
          label: const Text("I'm a child"),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () => _openScreen(context, const AdultScreen()),
          icon: const Icon(Icons.person_outline),
          label: const Text("I'm an adult"),
        ),
        const SizedBox(height: 24),
        const HelpEntryButton(),
      ],
    );
  }
}

/// Retains the adult route while separating configuration from child play.
class AdultScreen extends StatelessWidget {
  const AdultScreen({super.key});

  @override
  Widget build(BuildContext context) => const ParentScreen();
}

void _openScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
