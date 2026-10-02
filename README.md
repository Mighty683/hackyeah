# HackYeah

A pnpm + Turborepo hackathon workspace with four packages.

| Package | Purpose |
| --- | --- |
| `packages/frontend` | React + TypeScript, Vite+, Tailwind CSS |
| `packages/backend` | Express API and production frontend hosting |
| `packages/presentation` | Slidev pitch deck |
| `packages/types` | Shared TypeScript API contracts |

## Start developing

Use Node.js 24 (see `.node-version`) and pnpm 12.3.4.

```sh
pnpm install
pnpm dev
```

- Frontend: http://localhost:5173
- Backend health endpoint: http://localhost:3000/api/health
- Presentation: http://localhost:3030

`pnpm dev:app` runs only the frontend and backend. `pnpm dev:presentation` runs only Slidev. Click **Check backend** in the app to confirm the API connection.

The frontend was generated with the Vite+ `vp create vite` React TypeScript template. Its local `vp` commands provide development, builds, linting, and formatting; no global Vite+ installation is required. Turborepo handles tasks across packages.

## Build and run the demo

```sh
pnpm build:app
pnpm start
```

Open http://localhost:3000. Express serves `packages/frontend/dist`, SPA routes, and `/api` endpoints. Unknown API routes return JSON 404s. Build both app packages before starting; keep the frontend build alongside the backend when deploying this workspace.

`pnpm build` builds all four packages, including the Slidev site. `pnpm typecheck` checks application and shared types. `pnpm lint` runs the frontend Vite+ linter.

The backend defaults to `0.0.0.0:3000`. Override `HOST` or `PORT` when starting it. The Vite dev proxy targets port 3000; update `packages/frontend/vite.config.ts` if changing the development backend port.

## Shared contracts

Define shared request/response types in `packages/types/src/index.ts` and import them with `import type { ... } from '@hackyeah/types'`. The package exports source types directly so development does not need a types watcher; its build emits declarations only. Put runtime helpers in the consuming app.

## Pitch deck

Edit `packages/presentation/slides.md`. `pnpm --filter @hackyeah/presentation build` creates the static deck in its `dist` directory. PDF export is available through the package's `export` script and requires Slidev's optional Playwright browser setup.

## Ripwire

With `ripwire` installed on PATH:

```sh
pnpm run context "understand frontend/backend API wiring"
```

This read-only helper follows our Pi setup: 4000-token task context, compact output, 120-second timeout, and a 2000-line / 50KB output cap. Ripwire is optional and is not downloaded by `pnpm install`; use `rg` when it is unavailable.

See `AGENTS.md` for the speed-first hackathon working agreement.
