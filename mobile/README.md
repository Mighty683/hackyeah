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
flutter test
flutter build apk --debug
```

The debug APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`.
Release signing is not configured; the generated release configuration uses the debug key for local development.

## Mission 02 verification — 2026-10-03

Combined Flutter analysis found no issues; all 39 tests passed; the Android debug APK built successfully. Tests include both complete lost branches, narration recovery/lifecycle, launcher entry/return and parent-record compatibility/preservation. The connected phone was locked, so an on-device walkthrough and actual voice playback were not verified. Appearance review is left to the user.

## Current scope

Welcome asks whether the player is an adult or a child. Adults start family onboarding; children choose alarm practice, lost practice or the map game. Onboarding asks for one action or detail per screen: intro → child name → age → address → support needs → trusted contacts → safe places → completion. Child details are optional; each contact uses name → phone → relationship, with up to three contacts. Each optional safe place uses name → offline map pin. Completed editor records save immediately. Parents can skip optional sections, review setup from the intro, edit or confirm deletion, then choose Play together on completion. No photo feature is included.

Mission 01 is fictional air-raid-alarm practice for ages 7+, with a home tutorial and an outdoor simulation using two to four visual choices per decision. The MVP has no younger-child branch or age selection. The home premise is an interior fallback when the agreed shelter cannot be reached, not a guarantee that a home is safe. Children practice moving away from windows, choosing an interior place, sending a pretend message, staying through noise and silence, and waiting for an explicit all-clear. Outdoor mistakes teach getting down and protecting the head. Wrong choices get calm feedback and retries; the reward is for completion, with no score or timer.

Mission 02 is fictional lost practice for ages 7+, with explicit nearby-meeting-point and out-of-sight variants. Parent setup can add an optional practice Fountain or Information desk illustration and name within the safe-places stage; it is independent of map pins and is not a real-location photograph. Training shows the same landmark picture/name and trusted-person display cards. Missing details use labelled pretend family cards, including a second contact for the unanswered-call lesson. Failed reads offer retry or explicit pretend practice without modifying saved records.

The lost mission practices stop/look, nearby landmark recognition or staying nearby, asking at a public desk, declining to leave with an unknown person, pretend calls to two different contacts, waiting, reunion and an explicit I'M SAFE action. No call or notification is made; completion says no message was sent. It retains unreviewed/not-for-real-emergencies labels, calm retry feedback, seven-action recall and no score. Replay keeps the same variant/context; re-entry loads the current family plan. Actual photos, routes, younger-child support and parent-device notifications remain future work. See [`../docs/MISSION_02_IMPLEMENTATION_PLAN.md`](../docs/MISSION_02_IMPLEMENTATION_PLAN.md) for scope and verification.

Android narration requires an installed **offline English TTS voice**. Instructions play automatically and have a Replay audio control. Voice initialization/playback failure displays an adult-help message rather than silently claiming narration works. Official Polish warning/all-clear recordings play as short teaching excerpts at restrained volume; the complete source files are bundled unchanged. See [`assets/audio/mission01/README.md`](assets/audio/mission01/README.md) for attribution and licensing. The scene and message exchange are fictional and never use real contact numbers, send messages, or verify shelters. No network is needed once the speech voice is installed.

The safe-place editor reuses the offline OpenStreetMap snapshot of a 2 × 2 km area around TAURON Arena Kraków. Tap to select a pin, or use the arena-centre and direction buttons. Safe places can be edited or deleted. Each game launch/replay randomly chooses a valid saved pin; repeats are possible. With no safe places, the northeast fictional base remains the target. The character starts at the arena and moves toward tapped points. Movement is simulated, not a walking route. Safe places are parent-selected family destinations; the demo does not check their safety or opening hours and provides no real emergency assistance.

The family plan is stored locally using `flutter_secure_storage` (Android RSA-OAEP/AES-GCM defaults, no biometric requirement). Cloud backup and device-transfer exclusions are configured in the Android manifest and XML resources; recovery/migration is not promised. Failed reads show a retry/delete option rather than silently overwriting data. **Delete all saved details** removes the family-plan record after confirmation. There is no parent lock: anyone using the app can view saved details. Use fictional personal information for demo sessions. Onboarding does not make calls.

A separate offline help prototype covers someone not responding, air raid, and being lost, with an unsure fallback. It is explicitly unreviewed and not for real emergencies. An explicit tap opens the phone app for 112 or an adult-configured trusted contact; no call is automatic and no connection or SMS delivery is claimed. The welcome and game screens offer help, including target/map loading and errors. Help reads the same encrypted family record as parent setup.

Online map area selection, GPS, road routing, Street View, multi-device sync and validated emergency assistance are outside this branch. Inactive resource cards remain removed; optional map details live behind the info button. See [`../docs/SCREEN_FLOW.md`](../docs/SCREEN_FLOW.md) for implemented and future journeys.

The child map uses real bundled street, path, tram, building, park and water outlines with a calm illustrated style. Nearby footprints, service roads, footpaths and play areas become clearer at close zoom; tiny details and overlapping labels are omitted. Arena, shop and base use illustrations, and decorative trees are not surveyed positions. The map remains incomplete and is for practice, never real navigation.

Map controls: the game starts at **4× zoom**, showing roughly 500 × 500 metres near the character. The view follows character movement. An arrow at the map edge points towards an offscreen practice target; it is a bearing, not a walking route. Tap nearby to move; drag to pan; pinch or use the zoom buttons to zoom 1–8×. Panning/pinching pauses following, and a new movement tap resumes it. **Show me** restores 4× zoom around the character. **Show whole map** restores the full source area without resetting the character. **Start again / Play again** reloads saved safe places, randomly picks a target, and resets the character and close view (or uses the fictional fallback when no valid pins exist). Dragging/pinching does not select a destination. After arrival, the map remains explorable without accepting new movement, and the direction arrow disappears. This is practice only, not real navigation.

- `lib/app.dart`: Flutter application and theme.
- `lib/features/welcome/welcome_screen.dart`: role selection and adult setup entry.
- `lib/features/parent/`: family onboarding, child/contact/safe-place steps, local models and encrypted repository.
- `lib/features/game/game_launcher.dart`: load saved safe places and randomly select a valid target for the practice game.
- `lib/features/mission/`: practice selection, air-raid/lost scenario state, display-only family context, illustrated decisions and offline Android audio.
- `lib/features/game/game_screen.dart`: game screen and Flutter UI; help pauses the game.
- `lib/features/help/`: separate offline help prototype and explicit dialler handoff.
- `lib/widgets/basebound_mascot.dart`: static guide shared by welcome, game and help.
- `lib/game/neighborhood_game.dart`: Flame scene and demo mission.
- `lib/game/components/`: map rendering and player movement.
- `lib/game/maps/demo_map.dart`: offline map provider and geographic projection.
- `lib/game/maps/schematic_map_scene.dart`: curated geography, simplified outlines and custom landmark artwork.
- `assets/maps/tauron-arena.geojson`: real geography bundled for offline play.

Dependencies are locked in `pubspec.lock`. No API keys or network permissions are needed by the game scene. Help uses `url_launcher` to open the phone app and reads contacts through `flutter_secure_storage`. It requests neither direct-call nor SMS permission. Content remains available with no internet or telephone service; dialler launch is not evidence of network availability. Background SMS, automatic escalation, verified shelter routes and complete offline first aid are **not implemented**.

See [`../docs/EMERGENCY_HELP.md`](../docs/EMERGENCY_HELP.md) for primary sources, limitations and required review. Do not make test calls to emergency numbers.

Map data © OpenStreetMap contributors, ODbL 1.0. See [`assets/maps/README.md`](assets/maps/README.md) for the area, license and refresh command. The game has no runtime backend dependency.

References: [Flame](https://docs.flame-engine.org/latest/index.html), [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup).
