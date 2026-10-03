import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../child/child_onboarding_screen.dart';
import '../game/location_permission_setup.dart';
import '../help/help_screen.dart';
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
  bool _helpOpen = false;

  bool get _canRequest =>
      mounted &&
      !_helpOpen &&
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

  Future<void> _openHelp() async {
    if (_helpOpen) return;
    _helpOpen = true;
    try {
      await openHelpScreen(context);
    } finally {
      _helpOpen = false;
      if (mounted) _releasePermissionGate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _releasePermissionGate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionReady?.completeError(StateError('Welcome closed'));
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
                  onHelp: _openHelp,
                  rolesEnabled: !_checkingLocation,
                  locationMessage: kIsWeb
                      ? 'Try the Android screens with fictional demo details. Device features are mocked.'
                      : _checkingLocation
                      ? 'An adult can allow location for the map and nearby-place hints in Help. GPS runs only while these screens are open.'
                      : _locationStatus == LocationPermissionStatus.granted
                      ? null
                      : 'Photos and practice still work without location. An adult can enable it in Family setup.',
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
    required this.onHelp,
    this.locationMessage,
  });

  final bool rolesEnabled;
  final VoidCallback onHelp;
  final String? locationMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _WelcomeIllustration()),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Tuptu',
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
          label: "I'm a child",
          description: 'Practice and explore.',
          icon: BaseboundIconName.child,
          onPressed: rolesEnabled
              ? () => _openScreen(context, const ChildOnboardingScreen())
              : null,
        ),
        const SizedBox(height: 12),
        BaseboundActionTile(
          label: "I'm an adult",
          description: 'Set up practice.',
          icon: BaseboundIconName.adult,
          onPressed: rolesEnabled
              ? () => _openScreen(context, const ParentScreen())
              : null,
        ),
        const SizedBox(height: 24),
        HelpEntryButton(onPressed: onHelp),
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
