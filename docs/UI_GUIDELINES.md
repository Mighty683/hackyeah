# Safe Path screen guidelines

These rules govern the current screen revision. Read them together with `UX.md`.
They supersede the older visual treatments in `UI_IMPLEMENTATION_PLAN.md`.

## Direction

Build a calm, credible learning app for children, with the simplicity of a good
picture book. Illustrations explain the situation; controls explain the action.
Avoid the appearance of a mobile game advertisement.

## Shared visual rules

- Consume `BaseboundTheme` and `BaseboundColors` from `mobile/lib/ui/basebound_ui.dart`.
  Do not invent a screen-specific palette or button style.
- Use warm off-white backgrounds, white surfaces, dark slate text and a single
  muted blue action accent. Reserve green and red for feedback after a choice.
- Use flat surfaces. No gradients, glows, bevels, text shadows, heavy outlines,
  raised game buttons or decorative shadows on controls.
- Use 12 px button/input corners and 16 px panel corners. Borders are 1 px.
  Use 8, 12, 16, 24 and 32 px spacing; screen gutters are normally 24 px.
- Keep Nunito. Headings are usually 26–30 px, weight 700; body text 16–18 px;
  control labels 17–18 px, weight 600–700. Avoid all-caps headlines.
- Use 24 px icons in ordinary controls. One small illustration may support the
  main task; do not put a second large illustration inside every choice.

## Controls and hierarchy

- One filled primary action per screen. Secondary actions use an outlined or
  text button. Equivalent choices have identical neutral styling.
- Use `BaseboundActionTile` for role/activity/list choices. It supports `label`,
  optional `description`, `icon`, `onPressed` and `selected`; it is a flat,
  left-aligned row with a trailing navigation arrow.
- Buttons must have at least 48 px touch targets; normal action height is 56 px.
  Allow labels to wrap and controls to grow with text scaling.
- Keep one clear heading, a short instruction, content and the action area.
  Avoid panels inside panels, repeated headings and competing badges.
- Keep audio replay secondary. It must not look like the main decision.
- Put mission choices in an orderly action area below the illustration, using
  short left-aligned labels. Do not scatter gradient captions over rooms or
  obscure the hallway/two-wall illustration with button furniture.
- Show feedback with a symbol and a short explanation. Never pre-highlight the
  correct answer, add scores, or shame a child for choosing differently.

## Adult forms, maps and help

- Adult editors use the same quiet controls with a visible step heading, clear
  field labels and one save/next action. Avoid mascot-heavy form headers.
- Maps and photos remain the main content on map/landmark screens. Put tool
  controls in compact, consistent toolbars; preserve attribution and gestures.
- Help keeps its separate restrained theme and visible prototype warning.
  Preserve explicit phone-app taps; do not change procedures in a visual pass.
- Keep practice-only labels, local-data/demo explanations and unverified-place
  wording. Do not turn presentation improvements into safety claims.

## Mission artwork

- Use coherent, ordinary architecture. Doors belong in walls and share a
  continuous floor; never use a corridor inset that looks like a floor hatch.
- Prefer code-drawn architectural plans for room comparisons and two-wall
  explanations. Show real wall lines, window openings, doors and recognisable
  furniture; do not scatter oversized room icons on coloured floor tiles.
- A two-wall explanation must place the child on one side of both uninterrupted
  walls and outside on the other. Keep the existing qualified safety wording.
- Raster backgrounds use restrained matte colours and sparse detail. Keep
  people and UI separate from background art; preserve character placement.
- Store revised images as versioned siblings, register their use in code and
  record prompts and provenance. Keep original assets available for comparison.

## Agent ownership and verification

- Each screen has its own revision agent. Edit only the assigned screen and
  explicitly assigned supporting widgets. Shared UI and docs have one integrator.
- Preserve navigation, scenario choices, narration, persistence, validation,
  cancellation, error recovery and accessibility semantics.
- Reuse shared components rather than duplicating styles. Do not add packages,
  regenerate assets or expand product scope for this pass.
- Format assigned Dart files. The integrator runs analysis, existing relevant
  flow tests and an Android debug build. User appearance review remains the
  default; no screenshot check is required by this document.
