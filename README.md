# HackYeah — Tuptu

A Flutter + Flame Android game with a Slidev pitch deck. The mobile game is the primary product; the web app template has been removed.

| Directory | Purpose |
| --- | --- |
| `mobile/` | Standalone Flutter + Flame Android game |
| `packages/presentation/` | Slidev pitch deck, the only pnpm workspace package |

## Android game

### Download and install

Download [Tuptu for Android](https://github.com/Mighty683/hackyeah/raw/refs/heads/codex/android-release-apk/releases/tuptu-release.apk) on your Android phone. Open the APK, allow installation from your browser or file manager if Android asks, then tap **Install** and open **Tuptu**. No Flutter or development tools are required.

This is a demo release signed with the project's debug key. Use fictional personal details; training and the unreviewed help prototype are not for real emergencies. See [`releases/README.md`](releases/README.md) for build details.

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

The current demo includes parent setup, a shared photo-landmark map with foreground GPS and offline walking turn guidance around TAURON Arena Kraków, and Mission 01: visual air-raid-alarm practice for ages 7+. The mission includes a home tutorial, an outdoor simulation, calm retries, fictional messaging, and a completion recap. Narration requires an installed offline English Android voice. Alarm/lost training movement, shelter choices and messages are simulated. Map movement comes only from real GPS; its walking routes have unverified access and entrances and require an accompanying adult. The game has no runtime backend dependency.

Map data © OpenStreetMap contributors, ODbL 1.0. Attribution, area details, and refresh instructions live in [`mobile/assets/maps/README.md`](mobile/assets/maps/README.md). After installing the JavaScript tooling, `pnpm maps:refresh` updates the bundled snapshot.

## Pitch deck

Use Node.js 24 (see `.node-version`) and pnpm 12.3.4. Run from the workspace root:

```sh
pnpm install
pnpm dev
```

Open http://localhost:3030. `pnpm dev:presentation` also starts Slidev. Edit `packages/presentation/content.json` for pitch text and speaker notes, and `packages/presentation/slides.md` for layout. Components, styles, and the historical concept demo live alongside them. Turborepo orchestrates the presentation workspace tasks.

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
