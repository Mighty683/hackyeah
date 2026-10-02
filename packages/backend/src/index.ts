import express from 'express';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import type { HealthResponse } from '@hackyeah/types';

const app = express();
const port = Number(process.env.PORT ?? 3000);
const frontendDist = fileURLToPath(new URL('../../frontend/dist/', import.meta.url));

app.use(express.json());
app.get('/api/health', (_req, res) => {
  const response: HealthResponse = { status: 'ok', message: 'Ready to build something great.' };
  res.json(response);
});
app.use('/api', (_req, res) => {
  res.status(404).json({ error: 'API endpoint not found' });
});

if (existsSync(join(frontendDist, 'index.html'))) {
  app.use(express.static(frontendDist));
  app.get('/{*path}', (_req, res) => {
    res.sendFile(join(frontendDist, 'index.html'));
  });
} else {
  console.log('Frontend build missing. Use the Vite dev server, or run pnpm build:app.');
}

app.listen(port, process.env.HOST ?? '0.0.0.0', () => {
  console.log(`Backend listening at http://localhost:${port}`);
});
