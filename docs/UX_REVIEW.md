# Android UX review — 2026-10-03

Scope: the current Flutter/Flame application, including its previously untracked source. Reviewed against the unchanged [UX.md](UX.md), using the `hackyeah-ux-review` skill. The earlier Android screenshot is historical evidence; source inspection establishes current behavior. Pitch screens were inspected only to distinguish prototypes from implemented Android features.

## Findings and disposition

### P2 — Inactive resource cards distract from moving the character (fixed)

The original game screen showed water, energy and warmth, a mission label, a long instruction, map details and two restart controls. The resource cards had no values or effect on play, so a child had several apparent tasks before the first map action. UX §2 and §4 require one instruction, minimal text and one primary task per screen.

Fix: `mobile/lib/features/game/game_screen.dart` now shows one goal, one short movement instruction and the map. It keeps one restart control per state. The information dialog holds optional demo details; map attribution remains visible.

### P2 — Launch skipped the requested adult/child decision (fixed)

`mobile/lib/app.dart` previously opened the map immediately. That left no place to separate adult context from the child's journey. UX §4 calls for simple navigation and a clear task on each screen.

Fix: `mobile/lib/features/welcome/welcome_screen.dart` asks “Are you an adult or a child?” with two large, labeled buttons. Child opens the game. Adult opens a short introduction with “Play together.” Back navigation permits changing roles. Adult setup is not claimed to exist.

### P2 — Map movement does not yet teach emergency decisions (remaining)

Location: [`neighborhood_game.dart`](../mobile/lib/game/neighborhood_game.dart), line 45 (`_movePlayer`) and line 60 (`update`); [`game_screen.dart`](../mobile/lib/features/game/game_screen.dart), line 94 (result copy).

Tapping any point moves the character directly there, and reaching the base ends the mission. No concrete emergency situation, meaningful action choices, consequence of a decision or explanation is modeled. This is a navigation demo, not yet the training loop required by UX §1, §3 and §8.

Smallest next feature: introduce one concrete simulated situation, 2–4 plausible actions and a brief outcome/explanation before returning to the map. Use reviewed sources if the scenario teaches safety procedures. The current simplification deliberately retains the movement demo and labels it as practice.

### P2 — The map has no equivalent accessible controls (remaining)

Location: [`neighborhood_component.dart`](../mobile/lib/game/components/neighborhood_component.dart), line 41 (`onTapDown`) and line 88 (`render`).

The goal and character are painted onto a Flame canvas; movement only accepts map-coordinate taps. There are no semantic map landmarks or alternative controls for a screen-reader user to select a destination. Flutter button labels and the result announcement improve the surrounding screens, but do not make the game itself accessible. This conflicts with UX §4's accessibility requirement.

Smallest useful follow-up: provide labeled destinations and an equivalent way to choose them, backed by the same movement logic. Check the complete journey with TalkBack before claiming screen-reader accessibility.

## Product decision

Start with welcome → role → one task. Keep child play separate from adult explanation and future family setup. Remove inactive indicators, marketing copy and detailed map metadata from the main game view. Defer backpack selection, walking mode and emergency assistance until their behavior exists. [SCREEN_FLOW.md](SCREEN_FLOW.md) separates the working Android flow from future product screens.

## Verification

- Flutter analysis passed with no issues.
- Both Mermaid graphs passed a grammar check with the installed Mermaid parser; rendered diagram layout was not verified.
- Temporary Flutter widget smoke check passed: both role routes, back navigation, offline map load, tap movement to the base, replay and the information dialog.
- The smoke check also passed at 320 × 480 logical pixels with doubled text scaling and no layout exceptions. Welcome and game widget renders were inspected; test-font fallback limits visual verification of some labels. An on-device smoke check and TalkBack remain unperformed.
- No emergency procedures were added or endorsed, so there is no safety-source verification claim.
- A live pitch preview could not start inside the restricted environment. Pitch visual layout and actual TalkBack behavior were not verified.
