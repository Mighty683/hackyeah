import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../child/child_onboarding_screen.dart';
import '../game/location_permission_setup.dart';
import '../parent/parent_screen.dart';

/// Role selection keeps adult information out of the child's first screen.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.locationPermission});

  final LocationPermissionSetup? locationPermission;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  late final _permission =
      widget.locationPermission ?? LocationPermissionSetup();
  bool _checkingLocation = true;
  LocationPermissionStatus? _locationStatus;
  Completer<void>? _permissionReady;

  bool get _canRequest =>
      mounted &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) &&
      (ModalRoute.of(context)?.isCurrent ?? true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupLocation());
  }

  Future<void> _setupLocation() async {
    if (!mounted) return;
    final status = await _permission.ensureRequestedOnce(
      beforeRequest: _awaitPermissionReady,
    );
    if (!mounted) return;
    setState(() {
      _checkingLocation = false;
      _locationStatus = status;
    });
  }

  Future<void> _awaitPermissionReady() {
    if (_canRequest) return Future<void>.value();
    return (_permissionReady ??= Completer<void>()).future;
  }

  void _releasePermissionGate() {
    if (!_canRequest) return;
    _permissionReady?.complete();
    _permissionReady = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _releasePermissionGate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionReady?.completeError(StateError('Ekran powitalny zamknięty'));
    _permissionReady = null;
    super.dispose();
  }

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
                child: _WelcomeChoices(
                  rolesEnabled: !_checkingLocation,
                  locationMessage: kIsWeb
                      ? 'Wypróbuj ekrany Androida z fikcyjnymi danymi. Funkcje urządzenia są symulowane.'
                      : _checkingLocation
                      ? 'Dorosły może włączyć lokalizację dla mapy i wskazówek o pobliskich miejscach w Pomocy. GPS działa tylko na otwartych ekranach.'
                      : _locationStatus == LocationPermissionStatus.granted
                      ? null
                      : 'Zdjęcia i ćwiczenia działają bez lokalizacji. Dorosły może ją włączyć w ustawieniach rodziny.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeChoices extends StatelessWidget {
  const _WelcomeChoices({
    required this.rolesEnabled,
    this.locationMessage,
  });

  final bool rolesEnabled;
  final String? locationMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _WelcomeIllustration()),
        const SizedBox(height: 24),
        const Text(
          'Witaj w Tuptu',
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
          'Jesteś osobą dorosłą czy dzieckiem?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            height: 1.4,
            color: BaseboundColors.muted,
          ),
        ),
        const SizedBox(height: 32),
        if (locationMessage != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              locationMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BaseboundColors.muted),
            ),
          ),
          const SizedBox(height: 16),
        ],
        BaseboundActionTile(
          label: "Jestem dzieckiem",
          description: 'Ćwicz i odkrywaj.',
          icon: BaseboundIconName.child,
          onPressed: rolesEnabled
              ? () => _openScreen(context, const ChildOnboardingScreen())
              : null,
        ),
        const SizedBox(height: 12),
        BaseboundActionTile(
          label: "Jestem osobą dorosłą",
          description: 'Przygotuj ćwiczenia.',
          icon: BaseboundIconName.adult,
          onPressed: rolesEnabled
              ? () => _openScreen(context, const ParentScreen())
              : null,
        ),
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

void _openScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
