# Safe Path — Android game

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

After integrating newer main changes, combined analysis remained clean, all 58 tests passed, and the Android debug APK rebuilt successfully. Alarm, lost, landmark and map practice are all retained, together with parent Walk together and offline pedestrian practice routing.

## Current scope

Welcome asks whether the player is an adult or a child. Adults start family onboarding; children choose alarm, lost, map or landmark practice. Onboarding asks for one action or detail per screen: intro → child name → age → address → support needs → trusted contacts → safe places → completion. Child details are optional; each contact uses name → phone → relationship, with up to three contacts. Each optional safe place uses name → offline map pin. Completed editor records save immediately. Parents can skip optional sections, review setup from the intro, edit or confirm deletion, then choose Play together on completion. Parents can also open Walk together to capture independent photo landmarks, and children open the same places in Our map.

Mission 01 is fictional air-raid-alarm practice for ages 7+, with a home tutorial and an outdoor simulation using two to four visual choices per decision. The MVP has no younger-child branch or age selection. The home premise is an interior fallback when the agreed shelter cannot be reached, not a guarantee that a home is safe. Children practice moving away from windows, choosing an interior place, sending a pretend message, staying through noise and silence, and waiting for an explicit all-clear. Outdoor mistakes teach getting down and protecting the head. Wrong choices get calm feedback and retries; the reward is for completion, with no score or timer.

Mission 02 is fictional lost practice for ages 7+, with explicit nearby-meeting-point and out-of-sight variants. Fresh installation configures the bundled Red corner shop photo as its meeting place; no extra demo button is required. Parent setup can link another existing Walk together photo landmark. Older installs without a selected place use the first available saved photo for practice without changing saved details. Training uses its current photo/name and stable ID, then introduces Our map through a photo-pin finding exercise. The saved Home practice point is also tappable when inside the demo map. The exercise uses the shared map and Places list with no GPS, route or real arrival claim. I cannot find it returns to staying nearby. Missing or deleted selected photos require parent setup or retry. Legacy illustrations remain labelled demo options. Contacts contribute display cards, including a labelled pretend second contact when needed. Failed reads never modify saved records.

The lost mission practices stop/look, nearby landmark recognition or staying nearby, asking at a public desk, declining to leave with an unknown person, pretend calls to two different contacts, waiting, reunion and an explicit I'M SAFE action. No call or notification is made; completion says no message was sent. It retains unreviewed/not-for-real-emergencies labels, calm retry feedback, seven-action recall and no score. Replay keeps the same variant/context; re-entry loads the current family plan. Contact photos, familiar-route training, younger-child support and parent-device notifications remain future work for Mission 02. See [`../docs/MISSION_02_IMPLEMENTATION_PLAN.md`](../docs/MISSION_02_IMPLEMENTATION_PLAN.md) for scope and verification.

Android narration requires an installed **offline English TTS voice**. Instructions play automatically and have a Replay audio control. Voice initialization/playback failure displays an adult-help message rather than silently claiming narration works. Official Polish warning/all-clear recordings play as short teaching excerpts at restrained volume; the complete source files are bundled unchanged. See [`assets/audio/mission01/README.md`](assets/audio/mission01/README.md) for attribution and licensing. The scene and message exchange are fictional. Alarm practice uses saved trusted-contact numbers only for a local pretend keypad with optional hints; entered digits are not saved. The outgoing SMS and pretend reply share one conversation screen. No calls or messages are sent and no shelter is verified. No network is needed once the speech voice is installed.

The safe-place editor reuses the offline OpenStreetMap snapshot of a 2 × 2 km area around TAURON Arena Kraków. Tap to select a pin, or use the arena-centre and direction buttons. Safe places can be edited or deleted. **Our map** opens independent photo landmarks and named saved pins together. Tap a pin for details, then choose **Walk here together**. Phone GPS supplies the only live position. Offline routes provide upcoming turns, metres and road names where available. Approximate, stale, denied, disabled and out-of-area GPS pause guidance. Routes use unverified OSM paths and local roads; walk with an adult. There is no fictional player spawn, random target, tap movement, automatic movement or synthetic blockage. Saved places have no safety or opening-hours check, and the app provides no real emergency assistance.

The family plan is stored locally using `flutter_secure_storage` (Android RSA-OAEP/AES-GCM defaults, no biometric requirement). Cloud backup and device-transfer exclusions are configured in the Android manifest and XML resources; recovery/migration is not promised. Failed reads show a retry/delete option rather than silently overwriting data. **Delete all saved details** removes the family-plan record, landmark metadata and saved app photo copies after confirmation. There is no parent lock: anyone using the app can view saved details. Use fictional personal information for demo sessions. Onboarding does not make calls.

Independent landmarks: **Adult → Walk together → Take a photo → camera or gallery → name → map pin → Save landmark**. Each point is separate from safe places; the feature records no path, sequence or movement history. It uses the current parent form theme, photo pins on the existing illustrated map and ordinary app-private photo copies; encrypted metadata stores names and coordinates. **Use my location** is optional, requests foreground location only, and rejects positions outside the demo map while allowing manual placement. Camera-cache photos are copied before saving and interrupted camera results can be recovered on reopening the parent library.

Fresh installations automatically receive three AI-generated fictional photo landmarks and one fictional **Home** practice pin. Child details and contacts stay empty. Existing saved records and edits are preserved, and deleting demo data does not restore it on relaunch. For a quick demo choose **Child activities → Our map → Find the photo pin**. Parent **Walk together → Load demo landmarks** can explicitly add missing photo examples. Children explore photo pins; lost practice uses saved photos for recognition, and walking guidance uses live GPS with offline narration. There is no assumed next landmark or fixed visiting order. Fictional demo pins cannot be selected for GPS walking guidance. Photo generation prompts are in [`assets/landmarks/prompts.json`](assets/landmarks/prompts.json).

A separate offline help prototype covers someone not responding, air raid, and being lost, with an unsure fallback. It is explicitly unreviewed and not for real emergencies. An explicit tap opens the phone app for 112 or an adult-configured trusted contact; no call is automatic and no connection or SMS delivery is claimed. The welcome and game screens offer help, including target/map loading and errors. Help reads the same encrypted family record as parent setup.

Online map area selection, verified pedestrian routing, Street View, multi-device sync and reviewed emergency assistance remain future work. Live GPS and local walking guidance now work within the bundled arena area. Landmark placement supports an optional one-shot foreground GPS fix inside the bundled map, with manual correction. Inactive resource cards remain removed; optional map details live behind the info button. See [`../docs/SCREEN_FLOW.md`](../docs/SCREEN_FLOW.md) for implemented and future journeys.

The child map uses real bundled street, path, tram, building, park and water outlines with a calm illustrated style. Nearby footprints, service roads, footpaths and play areas become clearer at close zoom; tiny details and overlapping labels are omitted. Arena, shop and base use illustrations, and decorative trees are not surveyed positions. The map remains incomplete: the GPS dot is real, while decorative artwork is illustrative and route access is unverified.

Location permission is requested once at first launch before role navigation; denial still permits practice. Parent Setup options offer explicit permission recovery. Tracking starts only on the map, without another permission prompt. Map controls: begin with the whole map. Drag/pinch with 1–8× zoom are the only camera controls; GPS updates the dot and accuracy circle without moving the camera. A Places selector opens on demand and one contextual panel contains the current action. Photo pins open details without moving the GPS dot. Entering Help, backgrounding or leaving the screen cancels GPS; returning while foreground obtains a fresh fix without requesting permission. No movement track or background location is recorded. Turn guidance requires a fix no older than 30 seconds and reported accuracy at most 25 m. Path endpoints are not verified entrances; accurate GPS within 20 m of the original pin offers recognition confirmation.

- `lib/app.dart`: Flutter application and theme.
- `lib/features/welcome/welcome_screen.dart`: role selection and adult setup entry.
- `lib/features/landmarks/`: independent photo capture/pin editing, demo import, local storage and child map recognition practice.
- `lib/features/parent/`: family onboarding, child/contact/safe-place steps, local models and encrypted repository.
- `lib/features/game/game_launcher.dart`: load photo landmarks, named parent pins and offline geography together.
- `lib/features/mission/`: practice selection, separate scenario models/content/sessions, display-only family context, and illustrated decisions. Screen widgets coordinate sessions; layout widgets and painters own presentation.
- `lib/audio/practice_audio.dart`: shared offline Android narration and cue playback for missions and walking guidance.
- `lib/ui/`: shared themes, action controls, adult setup styling, and icon artwork. Icon drawing stays separate from labels and actions.
- `lib/features/game/navigation_location.dart`: permission, foreground sensor lifecycle and freshness.
- `lib/features/game/walking_navigation.dart`: live GPS route session and progress.
- `lib/features/game/walking_route.dart`: route geometry, distance, and turn-by-turn instructions.
- `lib/features/game/game_screen.dart`: shared map, destination details and photo recall; help pauses GPS and narration.
- `lib/features/help/`: separate offline help prototype and explicit dialler handoff.
- `lib/widgets/basebound_mascot.dart`: static guide used by welcome and training screens.
- `lib/game/components/`: illustrated map rendering.
- `lib/game/maps/demo_map.dart`: offline map provider, coverage bounds, and geographic projection.
- `lib/game/maps/offline_router.dart`: offline A* pedestrian graph with directed segment tags.
- `lib/game/maps/schematic_map_scene.dart`: curated geography and custom landmark artwork.
- `lib/game/maps/map_geometry.dart`: projected paths and simplified map outlines.
- `assets/maps/tauron-arena.geojson`: real geography bundled for offline play.

Dependencies are locked in `pubspec.lock`. No API keys or network permissions are needed by the game scene. Help uses `url_launcher` to open the phone app and reads contacts through `flutter_secure_storage`. It requests neither direct-call nor SMS permission. Content remains available with no internet or telephone service; dialler launch is not evidence of network availability. Background SMS, automatic escalation, verified shelter routes and complete offline first aid are **not implemented**.

See [`../docs/EMERGENCY_HELP.md`](../docs/EMERGENCY_HELP.md) for primary sources, limitations and required review. Do not make test calls to emergency numbers.

Map data © OpenStreetMap contributors, ODbL 1.0. See [`assets/maps/README.md`](assets/maps/README.md) for the area, license and refresh command. The game has no runtime backend dependency.

References: [Flame](https://docs.flame-engine.org/latest/index.html), [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup).
