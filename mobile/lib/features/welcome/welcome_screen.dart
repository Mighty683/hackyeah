import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
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
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
          'Welcome to Basebound',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BaseboundColors.ink,
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Are you an adult or a child?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: BaseboundColors.muted),
        ),
        const SizedBox(height: 28),
        _RoleCard(
          label: "I'm a child",
          icon: Icons.face_rounded,
          color: BaseboundColors.blue,
          tint: BaseboundColors.sky,
          onPressed: () => _openScreen(context, const PracticeLauncher()),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          label: "I'm an adult",
          icon: Icons.person_outline_rounded,
          color: BaseboundColors.ink,
          tint: BaseboundColors.cream,
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
      width: 240,
      height: 178,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 220,
              height: 80,
              decoration: const BoxDecoration(
                color: BaseboundColors.greenLight,
                borderRadius: BorderRadius.all(Radius.elliptical(110, 40)),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 10,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 42,
              color: Color(0xFFF2BE46),
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 28,
            child: Icon(
              Icons.home_rounded,
              size: 72,
              color: BaseboundColors.peach,
            ),
          ),
          const BaseboundMascot(size: 156),
        ],
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: BaseboundColors.ink.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: BaseboundColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    color: BaseboundColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
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
