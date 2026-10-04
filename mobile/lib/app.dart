import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/demo/data/demo_data_seeder.dart';
import 'features/demo/web_demo_shell.dart';
import 'platform/demo_session.dart';
import 'features/help/help_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'ui/basebound_ui.dart';

class BaseboundApp extends StatelessWidget {
  const BaseboundApp({super.key, this.initialize});

  final Future<void> Function()? initialize;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _WebAppSession(initialize: initialize);
    return MaterialApp(
      title: 'Tuptu',
      locale: const Locale('pl', 'PL'),
      supportedLocales: const [Locale('pl', 'PL')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: BaseboundTheme.training(),
      home: _AppStartup(initialize: initialize),
    );
  }
}

/// Replacing the whole navigator also clears routes and their temporary edits.
class _WebAppSession extends StatefulWidget {
  const _WebAppSession({this.initialize});

  final Future<void> Function()? initialize;

  @override
  State<_WebAppSession> createState() => _WebAppSessionState();
}

class _WebAppSessionState extends State<_WebAppSession> {
  var _revision = 0;

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();
    DemoSession.instance.reset();
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: ValueKey(_revision),
    title: 'Tuptu — demo w przeglądarce',
    locale: const Locale('pl', 'PL'),
    supportedLocales: const [Locale('pl', 'PL')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false,
    theme: BaseboundTheme.training(),
    builder: (context, child) =>
        WebDemoShell(onReset: _reset, child: child ?? const SizedBox.shrink()),
    home: _AppStartup(initialize: widget.initialize),
  );
}

class _AppStartup extends StatefulWidget {
  const _AppStartup({this.initialize});

  final Future<void> Function()? initialize;

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  late Future<void> _ready = _initialize();
  bool _helpOpen = false;

  Future<void> _initialize() =>
      widget.initialize?.call() ?? DemoDataSeeder().seed();

  Future<void> _help() async {
    if (_helpOpen) return;
    setState(() => _helpOpen = true);
    try {
      await openHelpScreen(context);
    } finally {
      if (mounted) setState(() => _helpOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _ready,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError &&
          !_helpOpen) {
        return const WelcomeScreen();
      }
      return Scaffold(
        body: SafeArea(
          child: IllustratedBackdrop(
            warm: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: snapshot.hasError
                      ? SoftPanel(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Nie udało się przygotować ćwiczenia.',
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Zapisane dane zostały zachowane. Spróbuj ponownie.',
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => setState(() {
                                  _ready = _initialize();
                                }),
                                child: const Text('Spróbuj ponownie'),
                              ),
                            ],
                          ),
                        )
                      : const CircularProgressIndicator(
                          semanticsLabel: 'Przygotowywanie ćwiczenia',
                        ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: HelpEntryButton(onPressed: _help),
          ),
        ),
      );
    },
  );
}
