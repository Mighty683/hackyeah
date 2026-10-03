# Hackathon working agreement

## Visual verification

Visual checks are performed by the user. Agents should verify code and functionality, and leave appearance, layout and design review to the user unless the user explicitly requests an agent visual review. Do not run screenshot or rendered-preview review as a routine completion check.

This is a HackYeah hackathon project. Speed of development and a compelling working demo are the primary goals. Prioritize shipping useful features over production stability, exhaustive testing, long-term maintainability, or architectural polish.

## Application purpose

Tuptu is a child-focused training game for ages roughly 7–14. It helps children learn familiar places, find their way, and practice decisions in simulated emergencies. Teach through **Situation → Decision → Action → Consequence → Explanation**, using simple English and calm feedback rather than long readings or memorization.

Start with a welcome screen asking whether the user is an adult or a child. Keep the child's journey focused on one task per screen with minimal text and 2–4 choices on decision screens. Keep adult explanation and future family-plan setup separate from child play. Role selection is navigation, not age verification or authorization.

The current Android demo implements welcome, parent setup with encrypted local child/contact/place records, and a shared familiar-place map with independent photo landmarks, foreground GPS and offline walking turn guidance inside the TAURON Arena demo area. Parent setup has no access gate; recommend fictional personal details for demos. A separate unreviewed offline help prototype covers not responding, air raid and being lost, plus an unsure fallback. It opens the phone app only after an explicit tap; no automatic calls, SMS or verified shelter routes. Keep its not-for-real-emergencies label until qualified safety review. Mission 01 now provides fictional air-raid-alarm decision training for ages 7+, with home/outdoor scenes and offline Android narration. Only live GPS changes the map position; there is no tap or simulated map movement. Walking guidance uses unverified bundled OSM paths and must be accompanied by an adult. Worldwide navigation and validated real emergency assistance remain unimplemented. Label demo behavior clearly and never present parent-selected places, saved contacts, or simulated routes as verified working safety features. If real emergency mode is added, separate it from training and use reviewed authoritative guidance with one actionable instruction per screen.

Follow `docs/UX.md` for product principles and keep `docs/SCREEN_FLOW.md` updated as screens and actions change. Its implemented and future graphs must stay distinct.

For screen design and UI changes, follow `docs/UI_GUIDELINES.md`. Use the shared theme and controls; keep illustrations separate from calm, consistent action controls.

## Bring the war face

**BUILD. DEMO. SHIP.**

The clock is ticking. Bring relentless energy. Pick the next useful thing, make it work, and put it in the team's hands. Smash blockers into concrete next steps. Build momentum, feed it with working features, and charge straight into the next challenge.

Bring confidence backed by evidence: a green build, a working user journey, a demo we can show. When something breaks, take command, fix the critical path, and get back to shipping. No timid execution. No endless deliberation. Make the call, deliver the feature, and keep the team moving.

**FULL THROTTLE. RELENTLESS MOMENTUM. SHIP THE DAMN DEMO.**

## How to work

- Implement the smallest useful solution and keep moving. Make reasonable assumptions instead of blocking on routine decisions.
- Prefer straightforward code, existing libraries, and simple integration over custom infrastructure or speculative abstractions.
- Temporary shortcuts, hardcoded demo data, and limited edge-case handling are acceptable when they accelerate the demo. Label mocks so the team understands what is real.
- Do not add test suites, coverage targets, CI gates, or broad refactors unless requested or needed to unblock a critical demo path.
- Verify changes with the quickest relevant check: build/typecheck for wiring changes and a manual smoke check for the main flow. Testing is a tool, not the primary deliverable.
- Fix failures that stop the app or demo. Defer unrelated cleanup and production hardening.
- Never commit secrets or introduce avoidable destructive behavior. Speed does not justify losing team data.

## Workspace

The project focuses on the standalone mobile game in `mobile/` and its Slidev pitch deck. The web app template has been removed. Do not recreate frontend, backend, or shared API packages unless the user expands the scope.

Use pnpm only for JavaScript tooling. The pnpm workspace contains one package: `packages/presentation` (`@hackyeah/presentation`), with the pitch deck in `slides.md`. Turborepo orchestrates its workspace tasks.

`pnpm dev` (or `pnpm dev:presentation`) starts Slidev on port 3030. `pnpm build` builds the static presentation into `packages/presentation/dist`. Export slides with `pnpm --filter @hackyeah/presentation export`; PDF export requires Slidev's optional Playwright browser setup. There is no web app server or API.

## Android game

The standalone Flutter + Flame Android application lives in `mobile/`, outside the pnpm workspace, and is the primary product. Run Flutter/Dart tools from `mobile/` (`flutter pub get`, `flutter analyze`, `flutter run`, `flutter build apk --debug`); pnpm does not build or run the game. The current mobile scope includes welcome, parent setup (one child, up to three contacts, named offline practice pins), the game screen, Mission 01 alarm practice and the separate offline help prototype; expand it only when requested.

The game bundles a real offline OpenStreetMap snapshot at `mobile/assets/maps/tauron-arena.geojson`. Preserve its attribution and license documentation in that directory. Refresh the snapshot from the workspace root with `pnpm maps:refresh`; the tool lives in `scripts/refresh-demo-map.mjs`. The fallback fictional base and mission are demo data. Saved parent-selected places are practice targets, not verified safe destinations. Online area selection remains future work. Inactive survival resource indicators have been removed from the Android game screen. The game has no runtime backend dependency.

## Ripwire context

Ripwire is installed separately and available as `ripwire` on PATH. The `pnpm run context` command mirrors the Pi wrapper in `~/projects/ai-setup/pi/agent/extensions/ripwire.ts`: task context for the current workspace, 4000-token budget, compact legend, 120-second timeout, and output capped at 2000 lines / 50KB.

When the Ripwire MCP tools are available, use `for` or `explore` to orient on the current task. Use read-only tools; quality reports remain advisory. If MCP is not available in the current session, use the CLI wrapper:

For unfamiliar code or a change spanning packages, orient with:

```sh
pnpm run context "describe the change or question; include known symbol names"
```

Then read only relevant files/symbols. Use `rg` for exact text/file lookup and simple targeted edits. If Ripwire is unavailable, fall back to `rg` and continue; do not block hackathon work on installing it. Keep this integration read-only: do not use Ripwire command-execution or write flags. Ripwire quality reports are advisory and must not become testing or stability gates.
