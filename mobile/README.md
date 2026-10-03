# Basebound — Android game

Standalone Flutter + Flame application and the primary product. The pnpm workspace contains only the Slidev presentation; this app uses Flutter/Dart tooling separately.

## Requirements

- Flutter 3.47.6 stable / Dart 3.13.5 or compatible newer stable versions.
- Android SDK and Java 17 or newer supported by the generated Gradle configuration.
- An Android device with USB debugging enabled, or an Android emulator.

## Run

From this directory:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

## Verify and build

```sh
dart format lib
flutter analyze
flutter build apk --debug
```

The debug APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`.
Release signing is not configured; the generated release configuration uses the debug key for local development.

## Current scope

Welcome asks whether the player is an adult or a child. Adults open parent setup; children open the practice game. Parent setup saves one child's optional full name, age, address and support notes, up to three trusted contacts (optional name, phone and relationship), and named practice places. No photo feature is included.

The place editor reuses the offline OpenStreetMap snapshot of a 2 × 2 km area around TAURON Arena Kraków. Tap to select a pin, or use the arena-centre and direction buttons. Places can be edited or deleted. Each game launch/replay randomly chooses a valid saved pin; repeats are possible. With no places, the northeast fictional base remains the target. The character starts at the arena and moves toward tapped points. Movement is simulated, not a walking route, and parent-selected places are not verified safe destinations.

The family plan is stored locally using `flutter_secure_storage` (Android RSA-OAEP/AES-GCM defaults, no biometric requirement). Cloud backup and device-transfer exclusions are configured in the Android manifest and XML resources; recovery/migration is not promised. Failed reads show a retry/delete option rather than silently overwriting data. **Delete all saved details** removes the family-plan record after confirmation. There is no parent lock: anyone using the app can view saved details. Use fictional personal information for demo sessions. The setup screen does not make calls.

Online map area selection, GPS, road routing, Street View, multi-device sync and emergency assistance are outside this branch. Inactive resource cards remain removed; optional map details live behind the info button. See [`../docs/SCREEN_FLOW.md`](../docs/SCREEN_FLOW.md) for implemented and future journeys.

- `lib/app.dart`: Flutter application and theme.
- `lib/features/welcome/welcome_screen.dart`: role selection and adult setup entry.
- `lib/features/parent/`: child/contact/place editors, local models and encrypted repository.
- `lib/features/game/game_launcher.dart`: load saved places and randomly select a valid practice target.
- `lib/features/game/game_screen.dart`: game screen and Flutter UI.
- `lib/game/neighborhood_game.dart`: Flame scene and demo mission.
- `lib/game/components/`: map rendering, touch input and player movement.
- `lib/game/maps/demo_map.dart`: offline map provider and geographic projection.
- `assets/maps/tauron-arena.geojson`: real geography bundled for offline play.

Dependencies are locked in `pubspec.lock`. No API keys or network permissions are needed by the game scene.

Map data © OpenStreetMap contributors, ODbL 1.0. See [`assets/maps/README.md`](assets/maps/README.md) for the area, license and refresh command. The game has no runtime backend dependency.

References: [Flame](https://docs.flame-engine.org/latest/index.html), [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup).
