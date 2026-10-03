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
| Guide | Locally drawn green dinosaur, decorative and static |
| Scenes | Bundled room and hallway artwork; native controls and scene descriptions |

Reusable components are `IllustratedBackdrop`, `SoftPanel`, `BaseboundBadge` and `BaseboundGuide`. `BaseboundTheme.training()` supplies the global theme. `BaseboundTheme.help()` supplies a flat cool variant, with navy actions and restrained surfaces.

## Parallel ownership

| Owner | Screens and files | Responsibility |
| --- | --- | --- |
| Integrator | Shared UI, app theme, mascot, fonts, assets and documentation | Establish the component contract, supply assets, reconcile changes and verify the combined app |
| Mission agent | Mission screen, scene and choice card | Instruction hierarchy, room choices, audio panel, feedback and completion presentation |
| Entry and map agent | Welcome, practice launcher, game launcher and game screen | Role cards, activity cards, matching loading/error states, map frame and controls |
| Parent and help agent | Parent overview, three editors, editor scaffold and help screen | Calm adult forms, consistent controls and a visually distinct help prototype |

Each screen agent edits only its assigned files. Scenario data, audio service, persistence, map geometry, game movement and help procedures remain outside the visual work. Shared API and asset registration are owned by the integrator to avoid concurrent conflicts.

## Integration sequence

1. Read the existing UX and screen-flow reference. Map the implemented screen boundaries.
2. Publish palette, component signatures and ownership before screen edits begin.
3. Run all three screen teams in parallel while the integrator builds shared controls and bundles illustration/font assets.
4. Integrate artwork without cropping away the window or exterior door. Retain the existing scene painter wherever it shows the consequence of the child's choice.
5. Check the combined diff for changed content, navigation, accessibility and demo labels. Fix issues within the visual scope.
6. Run Flutter analysis, the existing mission/navigation tests and an Android debug build. Inspect representative screen layouts and smoke-check the main journey.

## Screen presentation

Welcome retains adult/child selection with large role cards and the guide illustration. Practice selection retains alarm/map and home/outside choices in roomy cards. The map keeps its existing interactive area, zoom controls, restart and visible OpenStreetMap credit.

Mission scenes use a white instruction panel above the visual decision. Choices remain neutral until the child selects one; feedback then adds symbols and an explanation. At narrow widths or large text sizes, the existing accessible list of choices remains available. Scene actions remain native Flutter controls, separate from the decorative image.

Parent setup uses calm white panels, outlined fields and blue save actions. The help prototype uses flat cool surfaces, keeps the unreviewed label visible and presents its existing actions without the training mascot.

## Verification record

Integration checks on 2026-10-03:

- Flutter analysis passed with no issues.
- All 9 existing tests passed, covering home retry/completion/replay, outdoor actions, navigation, narration and narrow mission layouts with large text.
- Android debug APK built successfully.
- A temporary rendered smoke check loaded the actual font, icons and artwork for welcome, practice selection, mission introduction, mission choices, parent setup, help and map. It passed at 430 × 932; welcome, practice, parent, help and map also passed at 320 × 700 with 200% text size. The temporary runner was removed after producing the previews.
- The seven screen previews were visually inspected for loaded assets, readable labels, clipping and consistent styling. The implementation was checked in Flutter's renderer; a physical-device walkthrough was not performed.
- The action blue was adjusted to give white labels 5.30:1 contrast. Mission choices expose explicit screen-reader tap actions and disabled state.

The screen-flow graph remains unchanged because this work adds no screens or routes.

Asset prompts and provenance are recorded in `mobile/assets/illustrations/README.md`. The bundled Nunito license is in `mobile/assets/fonts/OFL.txt`.
