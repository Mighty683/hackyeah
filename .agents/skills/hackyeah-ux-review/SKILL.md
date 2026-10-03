---
name: hackyeah-ux-review
description: Review HackYeah code changes for compliance with docs/UX.md, covering child-friendly emergency training, decision flows, accessibility, feedback, and safety guidance. Use for requested UX reviews of diffs, pull requests, or current changes in this project.
---

# HackYeah UX Review

Review changes against the repository's current `docs/UX.md`. The audience is
children roughly 7–14 learning how to act in emergencies. Report concrete,
actionable problems that affect their understanding, decisions, or safety.

## Establish the review scope

- Read the applicable `AGENTS.md` instructions and the current `docs/UX.md`
  from the repository root. The document is the source of truth; section
  references below help navigate it and do not replace reading it.
- Honor a requested file, commit range, branch, or PR. For a branch review,
  compare against the merge base of the requested or confirmed base branch.
- Without a specified scope, review staged and unstaged changes plus relevant
  untracked source files. Inspect Git status before selecting files; skip build
  output, generated files, dependencies, and unrelated binary assets.
- If `docs/UX.md` is absent or unreadable, report that blocker instead of
  claiming compliance. If the change also edits the UX document, disclose
  that and identify any removed requirement that affects the review.
- Inspect affected screens, scenario data, shared contracts, and backend
  responses as needed to understand the complete user journey. Follow the
  project's read-only Ripwire orientation guidance for unfamiliar code or
  changes spanning packages; use targeted reads and `rg` otherwise.
- Review web and Flutter game changes using the same product principles.
  Apply emergency-mode rules only if that mode exists or is introduced.
  Review pitch material only when it changes child-facing examples or product
  behavior claims; do not force game-screen constraints onto adult-facing slides.

## Evaluate the affected journey

Use only applicable checks. Tie each finding to a specific requirement in
`docs/UX.md` and an observable behavior in the changed code or UI.

| UX sections | Review focus |
| --- | --- |
| 1, 3, 8 | Preserve Situation → Decision → Action → Consequence → Explanation. Start scenarios with concrete situations; offer 2–4 meaningful choices with plausible mistakes; show consequences and a brief explanation. Teach practiced decisions rather than memorized definitions or long readings. |
| 2, 9 | Use simple English, active action labels, one instruction at a time, and a calm tone. Prefer 5–12-word sentences where possible; explain unfamiliar terms. Make corrective feedback useful without blame, punishment, or unnecessary fear. |
| 4 | Check one primary task per screen, 2–4 decision choices, readable text, touch targets, visual hierarchy, minimal text, reachable key actions, and simple navigation. Danger and success need cues beyond color; essential information must work without animation. Check accessibility and contrast using evidence available from code or rendering. |
| 5 | Keep visuals friendly and credible, hazards recognizable, and environments familiar. Avoid military-simulator styling or visuals that erase the consequences of emergencies. |
| 6 | Keep real emergency mode visually and functionally separate from training. Remove points, achievements, entertainment animations, scores, and unnecessary choices from that mode. Present one actionable instruction per screen after situation selection. |
| 7 | Check the provenance of emergency procedures. Do not endorse invented guidance or encourage children to investigate hazards. For ambiguity, preserve the safety → trusted adult/emergency services → official instructions sequence. |
| 10 | Assess whether a frightened nine-year-old could quickly identify what to do. Explain the concrete ambiguity or distraction; do not claim a measured three-second result without observing one. |

Distinguish a deliberately wrong scenario choice from endorsed advice. A risky
option can be valid teaching material when its consequence and explanation
clearly correct it. Label demo data appropriately, but do not accept dangerous
instructions merely because the surrounding experience is a demo.

When a finding depends on emergency-procedure correctness, inspect referenced
sources and verify disputed claims against current authoritative guidance
(e.g. Polish emergency services, RCB, PSP, Police, government guidance, or
recognized first-aid standards). Cite the supporting source. If verification
is unavailable, state what remains unverified; do not invent a correction or
present a medical or safety assumption as established fact.

Do not turn preferences or absent numerical thresholds into UX requirements.
For example, the sentence-length guidance is a preference, and the document
does not specify a mandatory pixel size for touch targets or type.

## Verify proportionally

- Inspect the affected flow in a running app when available. Check the situation,
  choice, consequence, explanation, and relevant narrow-screen presentation.
  Use browser tooling for the web app and available Flutter tooling for mobile.
- Code inspection can establish logic and copy issues. Without rendering,
  identify visual, contrast, or touch-size concerns as unverified unless the
  implementation itself provides sufficient evidence. A build does not prove UX.
- Follow project tooling: pnpm and existing package scripts for the workspace;
  Flutter/Dart for `mobile/`. Run the quickest relevant check only when needed.
  Do not add tests, quality gates, or broad cleanup for a review.
- Keep the review read-only. Apply fixes only when the user asks for them.

## Report findings

Lead with actionable findings, highest severity first. Focus on problems
introduced or worsened by the reviewed changes. Include pre-existing issues
only when needed to explain a regression or when a broader audit is requested;
label them clearly. Avoid speculative problems and duplicate findings.

For each finding include:

- **Priority and title:** P1 for unsafe guidance or a blocked core journey;
  P2 for a material comprehension, learning, or accessibility problem;
  P3 for a smaller actionable issue. Use P0 only for an established immediate,
  critical safety risk.
- **Location:** a precise file and line, preferably within the reviewed diff.
- **Evidence and impact:** the trigger, observed behavior, and effect on the child.
- **UX basis:** the relevant `docs/UX.md` section and requirement.
- **Smallest useful fix:** a concrete correction, with authoritative support
  when changing emergency guidance.

Use clickable file links or the host's inline review comments when supported.
Finish with the scope reviewed, checks actually performed, and material gaps
such as unavailable visual inspection or unverified safety sources. If there
are no actionable findings, say so without implying that unperformed checks
passed. Keep the output concise and useful for shipping the demo.
