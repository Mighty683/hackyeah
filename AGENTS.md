# Hackathon working agreement

This is a HackYeah hackathon project. Speed of development and a compelling working demo are the primary goals. Prioritize shipping useful features over production stability, exhaustive testing, long-term maintainability, or architectural polish.

## How to work

- Implement the smallest useful solution and keep moving. Make reasonable assumptions instead of blocking on routine decisions.
- Prefer straightforward code, existing libraries, and simple integration over custom infrastructure or speculative abstractions.
- Temporary shortcuts, hardcoded demo data, and limited edge-case handling are acceptable when they accelerate the demo. Label mocks so the team understands what is real.
- Do not add test suites, coverage targets, CI gates, or broad refactors unless requested or needed to unblock a critical demo path.
- Verify changes with the quickest relevant check: build/typecheck for wiring changes and a manual smoke check for the main flow. Testing is a tool, not the primary deliverable.
- Fix failures that stop the app or demo. Defer unrelated cleanup and production hardening.
- Never commit secrets or introduce avoidable destructive behavior. Speed does not justify losing team data.

## Workspace

Use pnpm only. Turborepo orchestrates workspace tasks. There are exactly four packages:

- `packages/frontend` (`@hackyeah/frontend`): React + TypeScript, scaffolded with Vite+, styled with Tailwind CSS. Use the local `vp` CLI through package scripts.
- `packages/backend` (`@hackyeah/backend`): Express API under `/api`; serves the frontend build and SPA routes from `packages/frontend/dist`.
- `packages/presentation` (`@hackyeah/presentation`): Slidev pitch deck in `slides.md`.
- `packages/types` (`@hackyeah/types`): shared API contracts. Keep it type-only and use `import type` in both apps.

`pnpm dev` starts the app and slides. `pnpm dev:app` starts only frontend/backend. `pnpm build:app` builds the frontend before the backend; `pnpm start` serves both through Express. `pnpm build` also builds the presentation. Do not replace Turborepo with Vite+'s task runner at the workspace level.

The frontend proxies `/api` to port 3000 during development. Keep API calls relative so the same code works through Express in production. If changing the backend port, update the frontend proxy too.

## Ripwire context

Ripwire is installed separately and available as `ripwire` on PATH. The `pnpm run context` command mirrors the Pi wrapper in `~/projects/ai-setup/pi/agent/extensions/ripwire.ts`: task context for the current workspace, 4000-token budget, compact legend, 120-second timeout, and output capped at 2000 lines / 50KB.

When the Ripwire MCP tools are available, use `for` or `explore` to orient on the current task. Use read-only tools; quality reports remain advisory. If MCP is not available in the current session, use the CLI wrapper:

For unfamiliar code or a change spanning packages, orient with:

```sh
pnpm run context "describe the change or question; include known symbol names"
```

Then read only relevant files/symbols. Use `rg` for exact text/file lookup and simple targeted edits. If Ripwire is unavailable, fall back to `rg` and continue; do not block hackathon work on installing it. Keep this integration read-only: do not use Ripwire command-execution or write flags. Ripwire quality reports are advisory and must not become testing or stability gates.
