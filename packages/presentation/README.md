# Safe Path pitch

The main deck is [`slides.md`](slides.md): ten slides in English, with speaker notes for an approximately four-minute pitch including a 45-second recording. The recording is a placeholder until the team captures the Android app. [`prototype.md`](prototype.md) preserves the earlier interactive concept demo separately.

## Editing text

Edit [`content.json`](content.json) for all pitch wording. `metadata` contains the deck title and description, `shared` contains the event label, `recording` contains video/placeholder and accessibility labels, and `slides` contains each slide's copy, footer and native speaker notes. Notes are arrays of paragraphs; `\n` preserves deliberate line breaks in visible copy. The JSON contains plain text, not HTML.

`slides.md` controls slide order and layout. Keep its slide IDs and `@notes:` references aligned with the keys in `content.json`. JSON edits refresh both the visible slides and native presenter notes; the same content is used for builds and exports. Edit notes in JSON rather than Slidev's inline notes editor. The separate historical concept demo retains its own copy.

## Pitch analysis

The Defence brief asks for a specific security or resilience problem, a clearly identified user, and a demonstration that remains credible when information or services are limited. Safe Path addresses **children's preparedness**: practising the next decision before a stressful situation, with familiar places and family context.

The pitch follows the mentoring guide's order: problem → user → value → one demonstrated interaction → technical decisions → practical adoption → next step. Technology explains how the experience works offline; it is not the opening argument. The closing request is for a reviewed, supervised pilot, not a claim of readiness for real emergency use.

| Defence criterion | Weight | Evidence in the pitch |
| --- | --- | --- |
| Idea & Innovation | 30% | Slides 4–5: a decision-learning loop connected to familiar photos and family context. Describe this combination without claiming to be the first or only solution. |
| Relation to Category | 20% | Slides 2–3 and 7: civilian preparedness, child-specific decisions, and practice that does not depend on connectivity. |
| Practical Applicability / Usability | 20% | Slides 5–6 and 8: parent setup, one understandable training interaction, and a proposed school/family pilot. |
| Design | 20% | Slides 4 and 6: short visual choices, calm feedback and retry. The team reviews the actual appearance and child comprehension. |
| Completeness & Implementation Value | 10% | Slides 6–7 and 9: a working Android prototype, explicit limits, and a concrete validation roadmap. |

## Content decisions

The supplied `HackYeah 2026.pdf` is a content draft, not evidence that every described feature exists. The deck adapts it as follows:

- The verified Lenka story introduces the need for preparedness. Her age does not change the product's intended audience of 7–14; implemented training currently starts at 7+.
- The five-stage loop stays central: **Situation → Decision → Action → Consequence → Explanation**. One alarm choice, feedback and retry make this visible in the planned recording.
- Local family details and photo landmarks are implemented. Rehearsing a mobile-network outage and a complete family contingency plan remains planned. Broader handbook topics are opportunities for future scenarios, not current training coverage.
- The GUS figures of approximately **3.2 million primary-school pupils and 14 thousand schools in 2024/25** describe the education system's scale. They are not paying users, a precise count of the target age group, or validated demand. Institution-funded pilots are a proposed adoption model; there are no claimed customers or partnerships.
- Specialist review, child/parent testing, further scenarios, original artwork and carefully designed gamification are next steps. A reviewed scenario library and learning-outcome evidence are long-term ambitions.
- No improvement in safety, retention, confidence or real emergency outcomes has been measured for Safe Path. Other serious-game research does not establish this app's efficacy. The draft's online-child statistic and study-specific efficacy claims are omitted from the core pitch.

The source documents are `Details - Defence.pdf`, `Od chaosu do mistrzowskiego pitchu — HackYeah.pdf`, and `HackYeah 2026.pdf` under the main checkout's `docs/` directory. They were read from that checkout because the PDFs are not present in this worktree. Verified external sources are linked in the relevant speaker notes. The draft PDF's author label is not a confirmed team roster.

The draft's *Flood Alert!* study involved 45 university students, not children, and had no control group. The speaker notes preserve that qualification; the slide does not use it as evidence of child learning. The pitch guide's final pages also inform the sequence, local recording backup and rehearsal checklist. Four minutes is a proposed rehearsal target, not a verified competition time limit.

## Demonstration boundaries

The Android prototype has alarm and lost decision practice, parent-selected places and contacts, independent photo landmarks, and foreground GPS walking practice within the bundled TAURON Arena map. Narration needs an installed offline English Android voice. The app has no runtime backend dependency.

Training calls and messages are pretend. The separate help prototype is unreviewed; its 112 action currently opens a mock dialog, while trusted-contact actions can open the phone app. Saved destinations and bundled walking paths are not verified safe places or emergency routes. GPS walking practice requires an accompanying adult. These limitations must remain clear when presenting or answering questions.

The family record and landmark metadata use local encrypted storage; photo copies are ordinary app-private files. There is no parent access gate. Use fictional names, addresses and contacts in the recording. See [`mobile/README.md`](../../mobile/README.md) for the wider scope, and [`help_phone.dart`](../../mobile/lib/features/help/help_phone.dart) for the current phone behaviour.

## Recording replacement

1. Record roughly 45 seconds: enter alarm practice → make one choice → show calm feedback → retry successfully. Keep the focus on the child's decision, rather than touring every feature.
2. Use fictional personal details. Do not trigger real phone actions or include identifying information.
3. Save the clip as `public/demo/safe-path-demo.mp4` inside this package.
4. Set the demo component in `slides.md` to `<DemoRecording src="/demo/safe-path-demo.mp4" />` and update `slides.demo.footer` in `content.json`. Omitting `src` retains the placeholder; a failed video load shows a fallback message.
5. Rehearse playback locally and keep the MP4 available separately. A PDF cannot play the recording; retain the slide's explanatory text and provide a demo link with the submission if available.

## Run and submit

Run from the repository root, using pnpm:

```sh
pnpm dev:presentation
pnpm build
pnpm --filter @hackyeah/presentation demo
```

The pitch opens on port **3030**, builds to `packages/presentation/dist`, and the preserved concept demo runs on **3031**. The concept demo is not evidence of implemented Android functionality.

The pitch bundles Nunito and the existing Safe Path mascot, so they do not need network downloads. The font licence is in `public/fonts/OFL.txt`; artwork provenance is in [`mobile/assets/branding/README.md`](../../mobile/assets/branding/README.md). These are copies of existing project assets.

PDF export is optional during editing, but required for the challenge submission:

```sh
pnpm --filter @hackyeah/presentation export
```

Slidev PDF export requires its optional Playwright browser setup. Review the exported PDF before submission; appearance and layout review are performed by the user. Keep the final submission at **a maximum of ten slides**. Videos and additional evidence can be separate submission materials.

Before submitting to Challenge Rocket, confirm the **team name and complete member list**, project description, demo link if used, and final disclosures. The brief requires disclosure of significant AI assistance, external resources and any pre-existing work. Confirm the actual hackathon contribution rather than inferring it from repository history or the draft author's name. Credit Flutter/Flame, OpenStreetMap data and other bundled resources as applicable; preserve their existing attribution and licences.
