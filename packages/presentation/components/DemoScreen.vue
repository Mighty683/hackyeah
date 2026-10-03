<script setup lang="ts">
import { computed, ref } from 'vue'
import { useNav } from '@slidev/client'
import NeighborhoodMap from './NeighborhoodMap.vue'

type Screen = 'start' | 'backpack' | 'mission' | 'landmark' | 'flood' | 'finish' | 'emergency' | 'plan'
const props = defineProps<{ screen: Screen }>()
const { go } = useNav()
const selectedItems = ref(['water', 'coat', 'map'])
const feedback = ref('')
const mode = ref('screen')
const emergencyAnswers = ref<string[]>([])
const emergencyQuestions = [
  { title: 'What happened?', text: 'Choose an answer. You can also choose “Not sure”.', options: ['I do not know where I am', 'I cannot find my grown-up', 'Something worries me', 'Not sure'] },
  { title: 'Can you see any danger?', text: 'This is an example question in the prototype.', options: ['Yes', 'No', 'Not sure'] },
  { title: 'Is your grown-up with you?', text: 'For example, a parent or teacher.', options: ['Yes, they are with me', 'No, I am on my own', 'Not sure'] },
]
const emergencyQuestion = computed(() => emergencyQuestions[Math.min(emergencyAnswers.value.length, 2)])
const items = [
  { id: 'water', icon: '💧', name: 'Water', description: 'Supplies for the trip' },
  { id: 'food', icon: '🍎', name: 'Snack', description: 'Energy for the journey' },
  { id: 'coat', icon: '🧥', name: 'Jacket', description: 'For cold and rain' },
  { id: 'map', icon: '🗺️', name: 'Map', description: 'Help at a crossroads' },
  { id: 'light', icon: '🔦', name: 'Flashlight', description: 'For when it gets dark' },
  { id: 'toy', icon: '🧸', name: 'Teddy', description: 'Your adventure buddy' },
]
const screens: Screen[] = ['start', 'backpack', 'mission', 'landmark', 'flood', 'finish', 'emergency', 'plan']
const isEmergency = computed(() => ['emergency', 'plan'].includes(props.screen))

function toggleItem(id: string) {
  if (selectedItems.value.includes(id)) {
    selectedItems.value = selectedItems.value.filter(item => item !== id)
    feedback.value = ''
    return
  }
  if (selectedItems.value.length === 4) {
    feedback.value = 'Your backpack is full. Put one item back.'
    return
  }
  selectedItems.value.push(id)
  feedback.value = ''
}

function answerEmergency(answer: string) {
  emergencyAnswers.value.push(answer)
  if (emergencyAnswers.value.length === emergencyQuestions.length) {
    go(8)
    emergencyAnswers.value = []
  }
}
</script>

<template>
  <div class="demo-screen" :class="{ 'help-screen': isEmergency }">
    <header class="demo-header">
      <button class="brand" @click="go(1)"><span class="brand-icon">⌂</span> Tuptu<span class="brand-dot">●</span></button>
      <nav class="mode-nav" aria-label="Demo modes"><button :class="{ active: !isEmergency }" @click="go(1)">Adventure</button><button :class="{ active: isEmergency }" @click="go(7)">I need help</button></nav>
      <span class="prototype-label">{{ isEmergency ? 'EMERGENCY MODE PROTOTYPE' : 'GAME DEMO' }}</span>
    </header>

    <main v-if="screen === 'start'" class="start-layout">
      <div class="start-copy"><div class="eyebrow">SMALL ADVENTURES. GROWING CONFIDENCE.</div><h1>Find your way.<br /><span>Explore nearby.</span></h1><p>Pack your bag, discover familiar places<br />and guide your character back home.</p>
        <div class="mode-picker"><button :class="{ chosen: mode === 'screen' }" @click="mode = 'screen'"><span>🎮</span><strong>Play on screen</strong><small>Control your character</small></button><button :class="{ chosen: mode === 'walk' }" @click="mode = 'walk'"><span>👟</span><strong>Go for a walk</strong><small>With a grown-up · soon</small></button></div>
        <button class="primary" @click="mode === 'screen' ? go(2) : feedback = 'Walking with a grown-up is the next step. This demo shows the screen-based game.'">{{ mode === 'screen' ? 'Start my adventure →' : 'Preview walking mode' }}</button><div v-if="feedback" class="feedback">{{ feedback }}</div>
      </div>
      <div class="start-visual"><NeighborhoodMap /><div class="floating-card"><span>✦</span><div><strong>Mission: get back to base</strong><small>School → library → home</small></div></div></div>
    </main>

    <main v-else-if="screen === 'backpack'" class="standard-layout">
      <div class="section-heading"><div><div class="eyebrow">01 / GET READY</div><h1>Pack for your adventure.</h1><p>You have room for 4 items. What will you bring?</p></div><div class="timer">◷ <strong>01:00</strong><small>Demo timer</small></div></div>
      <div class="pack-layout"><div class="item-grid"><button v-for="item in items" :key="item.id" class="item-card" :class="{ selected: selectedItems.includes(item.id) }" :aria-pressed="selectedItems.includes(item.id)" @click="toggleItem(item.id)"><span class="selection-mark">{{ selectedItems.includes(item.id) ? '✓' : '+' }}</span><span class="item-icon">{{ item.icon }}</span><strong>{{ item.name }}</strong><small>{{ item.description }}</small></button></div>
        <aside class="pack-summary"><span class="big-icon">🎒</span><h2>Your backpack</h2><p>{{ selectedItems.length }} / 4 slots filled</p><div class="pack-slots"><span v-for="item in items.filter(item => selectedItems.includes(item.id))" :key="item.id">{{ item.icon }}</span></div><small>Every adventure brings new choices.</small><button class="primary" :disabled="!selectedItems.length" @click="go(3)">Backpack ready →</button><div v-if="feedback" class="feedback">{{ feedback }}</div></aside>
      </div>
    </main>

    <main v-else-if="screen === 'mission' || screen === 'flood'" class="standard-layout">
      <div class="section-heading"><div><div class="eyebrow">{{ screen === 'flood' ? '03 / AN UNEXPECTED EVENT' : '02 / THE ADVENTURE' }}</div><h1>{{ screen === 'flood' ? 'Uh-oh! The road is flooded.' : 'Next stop: base!' }}</h1></div><span class="mission-pill">⌂ Goal: home</span></div>
      <div class="journey-layout"><div class="map-panel"><NeighborhoodMap :flooded="screen === 'flood'" /><div class="map-caption">Illustrative map · fictional events</div></div>
        <aside class="journey-sidebar"><div class="resources"><div>💧 <span>Water</span><strong>•••</strong></div><div>🍎 <span>Energy</span><strong>••○</strong></div><div>🧥 <span>Warmth</span><strong>•••</strong></div></div>
          <div v-if="screen === 'mission'" class="instruction-card"><span class="direction">↑</span><h2>Head to the library</h2><p>At the crossroads, look for the building with the purple roof.</p><span class="distance">Next landmark · 120 m</span></div>
          <div v-else class="instruction-card event-card"><span class="event-icon">🌊</span><h2>Choose another route</h2><p>The riverside path is blocked in this mission. How will you get back to base?</p></div>
          <button v-if="screen === 'mission'" class="primary" @click="go(4)">Go to the crossroads →</button>
          <template v-else><button class="primary" @click="go(6)">🗺️ Take the library route</button><button class="secondary" @click="feedback = 'A flashlight helps in the dark. Here, you need a different route.'">🔦 Use the flashlight</button></template><div v-if="feedback" class="feedback">{{ feedback }}</div>
        </aside>
      </div>
    </main>

    <main v-else-if="screen === 'landmark'" class="standard-layout">
      <div class="section-heading"><div><div class="eyebrow">LANDMARK / LIBRARY</div><h1>Do you know this place?</h1></div><span class="mission-pill">✦ Discovery 1 / 3</span></div>
      <div class="journey-layout"><div class="landmark-panel">
          <svg viewBox="0 0 560 330" role="img" aria-label="Illustration of a library at a crossroads with a park on the right">
            <rect width="560" height="330" fill="#dcebed" /><circle cx="457" cy="57" r="25" fill="#fbdfa0" /><path d="M0 210 H560 V330 H0z" fill="#dfe5d3" /><path d="M145 330 225 212 H344 L424 330" fill="#a5aca6" /><path d="M0 246 H560 V275 H0z" fill="#a5aca6" /><path d="M276 330 282 292 M285 273 288 249" stroke="#fdf7e9" stroke-width="5" stroke-dasharray="17 12" />
            <rect x="55" y="105" width="229" height="134" fill="#d9c9ad" /><path d="M39 108 168 55 299 108" fill="#7b89b8" /><rect x="67" y="117" width="204" height="26" rx="3" fill="#f9f4e7" /><text x="169" y="135" text-anchor="middle" fill="#4c5b52" font-size="14" font-weight="700" letter-spacing="2">LIBRARY</text><path d="M86 157 v62 M119 157 v62 M219 157 v62 M251 157 v62" stroke="#f8f1df" stroke-width="15" /><rect x="153" y="164" width="38" height="75" rx="16" fill="#7d8c96" />
            <g fill="#719e75"><circle cx="400" cy="162" r="41" /><circle cx="470" cy="180" r="33" /></g><path d="M400 181 v58 M470 193 v46" stroke="#8d8067" stroke-width="10" /><rect x="376" y="225" width="100" height="22" rx="6" fill="#f8f4e7" /><text x="426" y="240" fill="#536357" font-size="11" text-anchor="middle" font-weight="700">PARK →</text>
          </svg><span class="illustration-label">Demo illustration · a location photo in the full game</span><div class="landmark-caption"><strong>Remember the purple roof and the park next door.</strong><span>That is your clue for the next adventure.</span></div>
        </div><aside class="journey-sidebar"><div class="instruction-card"><span class="event-icon">👀</span><h2>Which way will you turn?</h2><p>The library is on your left. The way home leads toward the park.</p></div><button class="primary" @click="go(5)">Right, toward the park →</button><button class="secondary" @click="feedback = 'Look at the PARK sign. Which way does it point?'">Left, behind the library</button><div v-if="feedback" class="feedback">{{ feedback }}</div><small class="gentle-note">Try again. That is how you learn your neighborhood.</small></aside>
      </div>
    </main>

    <main v-else-if="screen === 'finish'" class="finish-layout">
      <div class="finish-copy"><div class="eyebrow">MISSION COMPLETE</div><span class="finish-badge">⌂</span><h1>You made it to base!</h1><p>You now know part of your neighborhood.<br />Next time, try with fewer hints.</p><div class="achievement-row"><div><strong>3</strong><span>Places learned</span></div><div><strong>1</strong><span>New route</span></div><div><strong>✦</strong><span>Good decision</span></div></div><button class="primary" @click="go(2)">Another adventure →</button><button class="text-button" @click="go(7)">Preview emergency mode</button></div><div class="finish-map"><NeighborhoodMap arrived /><div class="floating-card"><span>✓</span><div><strong>Badge: I know the way!</strong><small>The library is your new landmark.</small></div></div></div>
    </main>

    <main v-else-if="screen === 'emergency'" class="help-layout">
      <div class="help-intro"><div class="eyebrow">TAKE A BREATH. ONE QUESTION AT A TIME.</div><h1>I need help</h1><p>An example question flow.<br />Your answers lead to a preview of the family plan.</p><div class="help-symbol">♡</div><span class="help-note">This prototype demonstrates the interface.<br />It does not assess danger or provide emergency assistance.</span></div>
      <div class="question-card"><div class="question-progress"><span>Question {{ Math.min(emergencyAnswers.length + 1, 3) }} of 3</span><span>● {{ emergencyAnswers.length > 0 ? '●' : '○' }} {{ emergencyAnswers.length > 1 ? '●' : '○' }}</span></div><h2>{{ emergencyQuestion.title }}</h2><p>{{ emergencyQuestion.text }}</p><button v-for="answer in emergencyQuestion.options" :key="answer" class="answer-button" @click="answerEmergency(answer)">{{ answer }}<span>→</span></button><button v-if="emergencyAnswers.length" class="text-button" @click="emergencyAnswers.pop()">← Previous question</button></div>
    </main>

    <main v-else class="standard-layout">
      <div class="section-heading"><div><div class="eyebrow">EXAMPLE PLAN SAVED BY A PARENT</div><h1>Your family plan</h1><p>Contacts, places and things to remember.</p></div><span class="mission-pill">Saved on this device</span></div>
      <div class="plan-layout"><div class="plan-main"><div class="family-contact"><span>👩</span><div><small>YOUR CONTACT</small><h2>Mom</h2><p>A parent adds the number and photo.</p></div><button class="primary" @click="feedback = 'Demo only: no call was made.'">Contact</button></div><div class="meeting-card"><span>⌂</span><div><small>AGREED MEETING POINT</small><h2>At the library entrance</h2><p>An example place agreed on with a parent in advance.</p></div></div><div class="prototype-info">In the full app, guidance depends on the situation and a reviewed scenario. This screen shows an example family plan.</div><div v-if="feedback" class="feedback">{{ feedback }}</div></div><aside class="needs-card"><h2>How are you feeling?</h2><p>Example questions about your needs.</p><button @click="feedback = 'Demo selection: I need water.'">💧 I need water</button><button @click="feedback = 'Demo selection: I feel cold.'">🧥 I feel cold</button><button @click="feedback = 'Demo selection: I feel hungry.'">🍎 I need something to eat</button><button class="text-button" @click="go(1)">Back to the game →</button></aside></div>
    </main>

    <footer class="demo-footer"><span>{{ isEmergency ? 'Example data · contact and navigation are simulated' : 'Tuptu · learn the places, remember the way' }}</span><div><button @click="go(1)">Start</button><span>{{ screens.indexOf(screen) + 1 }} / 8</span></div></footer>
  </div>
</template>
