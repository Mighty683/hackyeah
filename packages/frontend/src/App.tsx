import { useState } from 'react';
import type { HealthResponse } from '@hackyeah/types';

export default function App() {
  const [message, setMessage] = useState('Check the connection, then start building.');

  async function checkBackend() {
    setMessage('Connecting…');
    try {
      const response = await fetch('/api/health');
      if (!response.ok) throw new Error(`Request failed: ${response.status}`);
      const health: HealthResponse = await response.json();
      setMessage(health.message);
    } catch {
      setMessage('Backend unavailable. Start both apps with pnpm dev:app.');
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-slate-950 p-6 text-slate-100">
      <section className="w-full max-w-xl rounded-3xl border border-slate-800 bg-slate-900 p-10">
        <p className="text-sm font-semibold uppercase tracking-widest text-emerald-400">HackYeah starter</p>
        <h1 className="mt-4 text-5xl font-bold tracking-tight">Build. Demo. Ship.</h1>
        <p className="mt-6 text-slate-300">{message}</p>
        <button className="mt-8 rounded-xl bg-emerald-400 px-5 py-3 font-semibold text-slate-950 hover:bg-emerald-300" onClick={checkBackend}>
          Check backend
        </button>
      </section>
    </main>
  );
}
