# Basebound visual design and parallel implementation plan

The Android demo uses the supplied alarm-training image as its visual reference: warm illustrated rooms, navy rounded text, large white cards, blue audio controls and a friendly green guide. This work upgrades appearance across the existing screens. Game content, narration, decisions, navigation, storage and phone behavior remain the existing demo.

The attached product-flow concept is background context. It does not expand this visual implementation into additional missions, messaging, age branches or verified emergency assistance.

## Shared design system

The shared implementation is `mobile/lib/ui/basebound_ui.dart`. All screen teams consume this file, so palette, typography and controls have one owner.

| Element | Implementation |
| --- | --- |
| Main text | Navy `#112568`; muted supporting text `#536184` |
| Primary action and audio | Blue `#0967DA`; explicit action labels; white text contrast 5.30:1 |
| Training backdrop | Cream `#FFF6E7`, peach `#FFE5C3` and sky `#E6F2FF` |
| Correct feedback | Green `#19853B`, light green surface and check symbol |
| Caution feedback | Coral surface and cross or explanation symbol |
| Typography | Bundled Nunito; bold headings, readable labels, existing text scaling |
| Cards and panels | White, 22–32 px corners, subtle shadows and generous spacing |
| Touch controls | At least 48 px; primary buttons generally 56 px |
| Guide | Editable vector green dinosaur; six static poses and optional mirroring |
| Icons | Bespoke colourful vector pictograms; no Material icon font glyphs |
| Scenes | Portrait 2:3 environment artwork, separate scene-character pose sheet and native controls |

Reusable components are `IllustratedBackdrop`, `SoftPanel`, `BaseboundBadge` and `BaseboundGuide`. `BaseboundTheme.training()` supplies the global theme. `BaseboundTheme.help()` supplies a flat cool variant, with navy actions and restrained surfaces.

## Current refinement — integration in progress

The refinement gives each existing screen a distinct composition while keeping the same words, decisions and return paths. The combined app and final portrait assets are awaiting integrator verification. The earlier passing checks below apply to the committed baseline, not this refinement.

### Dinosaur poses

`mobile/lib/widgets/basebound_mascot.dart` exposes `DinoPose {wave, point, think, listen, celebrate, calm}` and `BaseboundMascot(size, pose, faceLeft)`. The default remains `wave`; `faceLeft` mirrors the complete drawing. Each pose changes the arms, expression and stance or accents. The mascot is decorative, static and excluded from screen-reader output; instructions remain understandable without it.

| Pose | Composition and use |
| --- | --- |
| Wave | Grounded welcome hero beside a small home illustration |
| Point | Practice heading beside the choices; map guide beside the instruction |
| Think | Mission decision or short reflection |
| Listen | Narration and loading states |
| Celebrate | Correct practice feedback, map arrival and mission completion |
| Calm | Mistake explanations and recoverable error states |

`BaseboundGuide` accepts an explicit pose and mascot side. Screen teams choose placement for the current task rather than repeating one centred hero everywhere. Small or large-text layouts may omit decorative art to protect labels and controls.

### Bespoke icons

`mobile/lib/ui/basebound_icons.dart` supplies `BaseboundIconName`, `BaseboundIcon(name, size, color, calm)`, `paintBaseboundIcon(canvas, bounds, name, color, calm)` and `BaseboundBackButton`. The same editable vector motifs render as widgets and inside mission Canvas scenes. This replaces both visible `Icons.*` calls and the old `IconData`/font-glyph painter interfaces.

The finite family covers navigation and map controls; audio and replay; status and explanation; people and contacts; form editing and saving; places and rooms; mission actions; and the existing help situations and phone controls. Conventional arrows, speaker waves, handset, check, cross and plus/minus shapes remain recognizable. Help uses the calm variant. Native labels, tooltips, focus and disabled state remain the responsibility of the control containing the decorative icon. Default back and close affordances also use the custom family.

### Portrait scenes and character layers

Mission background artwork uses a 2:3 portrait composition suited to the phone viewport. Environment backgrounds and the scene-character pose sheet are separate assets: the dinosaur guide remains code-native, while scene-character crops can change with the current step. Place the relevant character pose above the background, then anchor only the current step's two to four native choices to the pictured objects.

Each step supplies its own target rectangles and character placement. Do not reuse the same window/door/hallway targets for unrelated later decisions. Object-anchored choices remain neutral before selection, with the existing symbols and explanation shown afterward. The image contains no interactive text; Flutter supplies labelled, focusable touch controls. Narrow or large-text layouts retain accessible choice cards. Decorative layers cannot intercept taps, pan or drag actions.

## Parallel ownership

| Owner | Screens and files | Responsibility |
| --- | --- | --- |
| Integrator | Shared UI, app theme, fonts, portrait assets, registration and integration | Freeze component contracts, supply assets, reconcile changes and verify the combined app |
| Mission agent | Mission screen, scene and choice card | Instruction hierarchy, room choices, audio panel, feedback and completion presentation |
| Entry and map agent | Mascot widget, welcome, practice launcher, game launcher and game screen | Six vector poses, distinct child-entry composition, matching loading/error states, map frame and controls |
| Parent and help agent | Icon family, parent overview, three editors, editor scaffold, offline point picker and help screen | Bespoke vector motifs, calm adult forms, consistent controls and a visually distinct help prototype |

Each agent edits only its assigned files. Scenario data, audio service, persistence, map geometry, game movement and help procedures remain outside the visual work. Shared contracts and asset registration are controlled by the integrator to avoid concurrent conflicts. Documentation has one assigned writer during integration.

## Integration sequence

1. Preserve the committed baseline and freeze pose, icon and scene-layer interfaces.
2. First wave: develop the dinosaur pose library, bespoke icon family, and portrait environment/character assets with per-step placement metadata in parallel.
3. Second wave: migrate mission screens; welcome/practice/map screens; and parent/help screens in parallel. Screen wiring can begin against the frozen interfaces while assets are completed.
4. Integrate portrait artwork and scene-character crops. Match each native target to its pictured object, preserving the current step, choice order, feedback, narration and demo labels.
5. Check the combined diff for changed content, navigation and accessibility. Check widget icons, Canvas glyphs, implicit navigation controls and disabled controls for complete migration.
6. The integrator runs Flutter analysis, the existing tests and an Android debug build, then inspects representative portraits and narrow/large-text layouts and smoke-checks the main journey.

## Screen presentation

Welcome retains adult/child selection with a grounded waving hero and large role cards. Practice selection places the pointing guide beside its heading, with alarm/map and home/outside choices in separate illustrated cards. Loading uses the listening pose; errors use the calm pose. The map keeps a compact pointing instruction guide, a celebrating arrival state, its existing interactive area, zoom controls, restart and visible OpenStreetMap credit.

Mission scenes use a white instruction panel above the portrait visual decision. Per-step character poses and object-anchored native choices sit above the environment artwork. Choices remain neutral until the child selects one; feedback then adds symbols and an explanation. At narrow widths or large text sizes, the existing accessible list of choices remains available. Scene actions remain native Flutter controls, separate from the decorative image.

Parent setup uses compact family/place illustrations, calm white panels, outlined fields and blue save actions; artwork does not crowd the forms. The help prototype uses flat cool surfaces and restrained custom icons, keeps the unreviewed label visible and presents its existing actions without the training mascot.

## Verification record

### Baseline visual upgrade — verified before this refinement

The following integration checks on 2026-10-03 apply to committed baseline `fce55f1`:

- Flutter analysis passed with no issues.
- All 9 existing tests passed, covering home retry/completion/replay, outdoor actions, navigation, narration and narrow mission layouts with large text.
- Android debug APK built successfully.
- A temporary rendered smoke check loaded the actual font, icons and artwork for welcome, practice selection, mission introduction, mission choices, parent setup, help and map. It passed at 430 × 932; welcome, practice, parent, help and map also passed at 320 × 700 with 200% text size. The temporary runner was removed after producing the previews.
- The seven screen previews were visually inspected for loaded assets, readable labels, clipping and consistent styling. The implementation was checked in Flutter's renderer; a physical-device walkthrough was not performed.
- The action blue was adjusted to give white labels 5.30:1 contrast. Mission choices expose explicit screen-reader tap actions and disabled state.

### Latest refinement — integration checks pending

The integrator still needs to complete combined Flutter analysis, existing tests, Android debug build, loaded-asset/pose/icon previews, portrait target alignment and narrow/large-text layout checks. Navigation, narration, form saving, map gestures and help phone-app behavior require a smoke check against the integrated result. No passing baseline result should be treated as proof that these latest checks passed.

The screen-flow graphs remain unchanged because this work adds no screens or routes.

Asset prompts and provenance are recorded in `mobile/assets/illustrations/README.md`. The bundled Nunito license is in `mobile/assets/fonts/OFL.txt`.

## Checkpoint and next worktree

The 2026-10-03 checkpoint includes portrait backgrounds, separate child action poses, six dinosaur poses, and custom vector icons across the app. Mascot shadows and surrounding guide/heading panels have been removed. Scene choices currently use light captions; this is an intermediate treatment.

The next requested pass makes the illustrated objects themselves clickable, with a subtle outline and shadow marking their hit areas. Give every alarm-practice scene a separate revision agent after completing the icons. Preserve existing decisions, narration, feedback and accessibility labels.

The icon refinement is also in progress: each new storybook icon has its own agent and file under `mobile/lib/ui/icons/`, sharing `StoryIconArt` brushes and palette. Thirty of the fifty-five icons have been redrawn at this checkpoint; the others retain the first custom-vector version until their individual revision. Review the complete family together at both 24 px and illustration sizes before final delivery.

The earlier full analysis, nine existing tests and Android build passed during initial integration. Subsequent loaded-asset renders passed for the portrait journey at 390 × 844, the map and parent editors, 360 px with 125% text, and entry/parent/help/map screens at 320 × 700 with 200% text. Temporary render runners are kept outside the repository. These results do not certify the unfinished object-interaction pass.

Portrait prompts, crop bounds and provenance are recorded in `mobile/assets/illustrations/PORTRAIT_ASSETS.md`.
