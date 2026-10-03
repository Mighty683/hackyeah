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

Welcome asks whether the player is an adult or a child. Children open the game directly; adults see a short introduction before playing together. The game uses an offline OpenStreetMap snapshot of a 2 × 2 km area around TAURON Arena Kraków, rendered by Flame. The character starts at the arena and moves toward tapped points; the base in the northeast is fictional. Movement is free across the map. Inactive resource cards are removed, and optional map details live behind the info button. GPS, road routing, building collisions, Street View, family-plan setup and emergency assistance are outside this phase. See [`../docs/SCREEN_FLOW.md`](../docs/SCREEN_FLOW.md) for implemented and future journeys.

The child map is a custom schematic, not an OSM image or detailed street-map style. It uses the same geographic extent and projected locations, but keeps only broad park/pond/river outlines and a few major roads. Arena, shop and base are illustrated landmarks; trees are decorative, not surveyed positions. Small streets, building footprints and POIs are omitted even when zoomed in. Secondary labels are hidden in very small overviews or when they would overlap; zooming reveals them. This intentionally incomplete diagram is for practice, never real navigation.

Map controls: tap to move the character; drag to pan; pinch or use the zoom buttons to zoom 1–4×. **Show whole map** restores the full source area without resetting the character. **Start again / Play again** resets both character and overview. Dragging/pinching does not select a destination. After arrival, the map remains explorable without accepting new movement. This is practice only, not real navigation.

- `lib/app.dart`: Flutter application and theme.
- `lib/features/welcome/welcome_screen.dart`: role selection and adult introduction.
- `lib/features/game/game_screen.dart`: game screen and Flutter UI.
- `lib/game/neighborhood_game.dart`: Flame scene and demo mission.
- `lib/game/components/`: map rendering and player movement.
- `lib/game/maps/demo_map.dart`: offline map provider and geographic projection.
- `lib/game/maps/schematic_map_scene.dart`: curated geography, simplified outlines and custom landmark artwork.
- `assets/maps/tauron-arena.geojson`: real geography bundled for offline play.

Dependencies are locked in `pubspec.lock`. No API keys or network permissions are needed by the game scene.

Map data © OpenStreetMap contributors, ODbL 1.0. See [`assets/maps/README.md`](assets/maps/README.md) for the area, license and refresh command. The game has no runtime backend dependency.

References: [Flame](https://docs.flame-engine.org/latest/index.html), [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup).
