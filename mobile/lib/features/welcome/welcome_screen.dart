import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../child/child_onboarding_screen.dart';
import '../help/help_screen.dart';
import '../parent/parent_screen.dart';

/// Role selection keeps adult information out of the child's first screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: const _WelcomeChoices(),
              ),
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
        const Center(child: _WelcomeIllustration()),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Safe Path',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BaseboundColors.ink,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Are you an adult or a child?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            height: 1.4,
            color: BaseboundColors.muted,
          ),
        ),
        const SizedBox(height: 32),
        BaseboundActionTile(
          label: "I'm a child",
          description: 'Practice and explore.',
          icon: BaseboundIconName.child,
          onPressed: () => _openScreen(context, const ChildOnboardingScreen()),
        ),
        const SizedBox(height: 12),
        BaseboundActionTile(
          label: "I'm an adult",
          description: 'Set up practice.',
          icon: BaseboundIconName.adult,
          onPressed: () => _openScreen(context, const AdultScreen()),
        ),
        const SizedBox(height: 24),
        const HelpEntryButton(),
      ],
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 184,
      height: 136,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 0,
            left: 8,
            child: BaseboundIcon(BaseboundIconName.sun, size: 28),
          ),
          const Positioned(
            right: 0,
            bottom: 24,
            child: BaseboundIcon(BaseboundIconName.home, size: 48),
          ),
          const Positioned(
            left: 16,
            bottom: 0,
            child: BaseboundMascot(size: 124, pose: DinoPose.wave),
          ),
        ],
      ),
    ),
  );
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
