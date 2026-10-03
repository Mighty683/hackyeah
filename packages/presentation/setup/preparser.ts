import { readFile } from 'node:fs/promises'
import { basename, dirname, resolve } from 'node:path'
import { definePreparserSetup } from '@slidev/types'

type PitchContent = typeof import('../content.json')

// Resolve copy before Slidev parses metadata and native presenter/export notes.
export default definePreparserSetup(async ({ filepath }) => {
  if (basename(filepath) !== 'slides.md') return []

  const content: PitchContent = JSON.parse(
    await readFile(resolve(dirname(filepath), 'content.json'), 'utf8'),
  )

  return [{
    name: 'pitch-content',
    transformRawLines(lines) {
      for (const [index, line] of lines.entries()) {
        const match = line.match(/^(\w+): '@content:(\w+)'$/)
        if (!match) continue
        const value = content.metadata[match[2] as keyof PitchContent['metadata']]
        if (typeof value !== 'string') throw new Error(`Missing pitch metadata: ${match[2]}`)
        lines[index] = `${match[1]}: ${JSON.stringify(value)}`
      }
    },
    async transformNote(note) {
      const match = note?.trim().match(/^@notes:(\w+)$/)
      if (!match) return note
      const slide = content.slides[match[1] as keyof PitchContent['slides']]
      if (!slide) throw new Error(`Missing pitch notes: ${match[1]}`)
      return slide.notes.join('\n\n')
    },
  }]
})
