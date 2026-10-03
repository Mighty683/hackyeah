import { dirname, resolve } from 'node:path'
import { defineVitePluginsSetup } from '@slidev/types'

export default defineVitePluginsSetup(({ entry }) => ({
  name: 'pitch-content-refresh',
  handleHotUpdate({ file, server }) {
    // Vue refreshes slide text; reparse Markdown for native metadata and notes too.
    if (file === resolve(dirname(entry), 'content.json')) {
      server.watcher.emit('change', entry)
    }
  },
}))
