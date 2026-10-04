import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';

class HelpEntryButton extends StatelessWidget {
  const HelpEntryButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed ?? () => openHelpScreen(context),
    style: FilledButton.styleFrom(
      backgroundColor: BaseboundColors.coral,
      foregroundColor: Colors.white,
    ),
    icon: const BaseboundIcon(BaseboundIconName.help),
    label: const Text('Potrzebuję pomocy', textAlign: TextAlign.center),
  );
}

Future<void> openHelpScreen(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HelpScreen()));

/// Preview of planned child guidance; scenario choices only open a placeholder.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _showGuidePreview = false;

  void _back() {
    if (_showGuidePreview) {
      setState(() => _showGuidePreview = false);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: BaseboundTheme.help(),
    child: PopScope<Object?>(
      canPop: !_showGuidePreview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _back,
            icon: const BaseboundIcon(BaseboundIconName.back, calm: true),
            tooltip: _showGuidePreview
                ? 'Wróć do wyboru scenariusza'
                : 'Zamknij pomoc',
          ),
          title: const Text('Pomoc · prototyp'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SoftPanel(
                      child: Text(
                        'Funkcja w przygotowaniu. Nie do prawdziwych zagrożeń.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        _showGuidePreview
                            ? 'Interaktywny przewodnik'
                            : 'Co się dzieje?',
                        style: const TextStyle(
                          color: BaseboundColors.ink,
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_showGuidePreview) ...[
                      const Text(
                        'Tutaj pojawi się interaktywny przewodnik dla dzieci. '
                        'Pokaże krok po kroku, co zrobić w tej sytuacji.',
                        style: TextStyle(fontSize: 18, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _back,
                        child: const Text('Wróć do wyboru scenariusza'),
                      ),
                    ] else ...[
                      _scenario(
                        'Ktoś nie reaguje',
                        BaseboundIconName.unresponsive,
                      ),
                      _scenario('Słyszysz syrenę', BaseboundIconName.alarm),
                      _scenario(
                        'Nie wiem, gdzie jestem',
                        BaseboundIconName.lost,
                      ),
                      _scenario('Nie wiem', BaseboundIconName.unsure),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _scenario(String label, BaseboundIconName icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: BaseboundActionTile(
      label: label,
      icon: icon,
      onPressed: () => setState(() => _showGuidePreview = true),
    ),
  );
}
