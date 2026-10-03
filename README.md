# HackYeah — Basebound

A Flutter + Flame Android game with a Slidev pitch deck. The mobile game is the primary product; the web app template has been removed.

| Directory | Purpose |
| --- | --- |
| `mobile/` | Standalone Flutter + Flame Android game |
| `packages/presentation/` | Slidev pitch deck, the only pnpm workspace package |

## Android game

Install Flutter and the Android SDK, then run:

```sh
cd mobile
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Verify and build an installable debug APK from `mobile/`:

```sh
flutter analyze
flutter build apk --debug
```

The APK is generated at `mobile/build/app/outputs/flutter-apk/app-debug.apk`. See [`mobile/README.md`](mobile/README.md) for prerequisites and development details.

The current demo includes parent setup, a touch-controlled offline map game around TAURON Arena Kraków, and Mission 01: visual air-raid-alarm practice for ages 7+. The mission includes a home tutorial, an outdoor simulation, calm retries, fictional messaging, and a completion recap. Narration requires an installed offline English Android voice. All training movement, shelter choices and messages are simulated. The game has no runtime backend dependency.

Map data © OpenStreetMap contributors, ODbL 1.0. Attribution, area details, and refresh instructions live in [`mobile/assets/maps/README.md`](mobile/assets/maps/README.md). After installing the JavaScript tooling, `pnpm maps:refresh` updates the bundled snapshot.

## Pitch deck

Use Node.js 24 (see `.node-version`) and pnpm 12.3.4. Run from the workspace root:

```sh
pnpm install
pnpm dev
```

Open http://localhost:3030. `pnpm dev:presentation` also starts Slidev. Edit `packages/presentation/slides.md`; the existing components, styles, and demo slides live alongside it. Turborepo orchestrates the presentation workspace tasks.

```sh
pnpm build
```

The static deck is generated in `packages/presentation/dist`. PDF export is available with `pnpm --filter @hackyeah/presentation export` and requires Slidev's optional Playwright browser setup. Flutter builds and runs the mobile game separately.

## Ripwire

With `ripwire` installed on PATH:

```sh
pnpm run context "understand the mobile game screen and offline map"
```

This read-only helper follows our Pi setup: 4000-token task context, compact output, 120-second timeout, and a 2000-line / 50KB output cap. Ripwire is optional and is not downloaded by `pnpm install`; use `rg` when it is unavailable.

See `AGENTS.md` for the speed-first hackathon working agreement.
