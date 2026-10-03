---
theme: default
title: '@content:title'
info: '@content:info'
author: '@content:author'
keywords: '@content:keywords'
favicon: /images/safe-path-icon-foreground.png
fonts:
  provider: none
  local: [Nunito, monospace]
  sans: Nunito
  mono: monospace
colorSchema: light
drawings:
  persist: false
transition: fade
canvasWidth: 1280
aspectRatio: 16/9
duration: 4min
mdc: true
defaults:
  layout: none
---

<PitchSlide slide="cover" v-slot="{ copy }" dark>
  <div class="cover-composition">
    <div>
      <p class="pitch-kicker">{{ copy.kicker }}</p>
      <h1>{{ copy.title }}</h1>
      <p class="cover-statement copy-lines">{{ copy.statement }}</p>
      <p class="cover-detail">{{ copy.detail }}</p>
    </div>
    <img class="cover-mascot" src="/images/safe-path-icon-foreground.png" :alt="copy.imageAlt">
  </div>
</PitchSlide>

<!-- @notes:cover -->

---

<PitchSlide slide="problem" v-slot="{ copy }">
  <h2 class="copy-lines">{{ copy.title }}</h2>
  <div class="problem-composition">
    <div class="story">
      <p class="pitch-kicker">{{ copy.kicker }}</p>
      <p class="story-lead">{{ copy.storyLead.text }}<strong>{{ copy.storyLead.emphasis }}</strong>{{ copy.storyLead.suffix }}</p>
      <p>{{ copy.story }}</p>
      <p class="source-caption">{{ copy.caption }}</p>
    </div>
    <div class="problem-insight">
      <p>{{ copy.insight.text }}<br><strong>{{ copy.insight.emphasis }}</strong></p>
      <p class="muted">{{ copy.focus }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:problem -->

---

<PitchSlide slide="audience" v-slot="{ copy }">
  <h2 class="copy-lines">{{ copy.title }}</h2>
  <div class="audience-composition">
    <div class="age-anchor"><strong>{{ copy.age }}</strong><span>{{ copy.ageUnit }}</span></div>
    <div class="audience-copy">
      <p v-for="point in copy.points" :key="point.title"><strong>{{ point.title }}</strong><br>{{ point.body }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:audience -->

---

<PitchSlide slide="solution" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <p class="slide-intro">{{ copy.intro }}</p>
  <ol class="learning-loop">
    <li v-for="(step, index) in copy.steps" :key="step.title"><span>{{ String(index + 1).padStart(2, '0') }}</span><strong>{{ step.title }}</strong><p>{{ step.body }}</p></li>
  </ol>
  <p class="takeaway">{{ copy.takeaway }}</p>
</PitchSlide>

<!-- @notes:solution -->

---

<PitchSlide slide="family" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="family-composition">
    <div>
      <p class="pitch-kicker">{{ copy.currentLabel }}</p>
      <ul class="plain-list">
        <li v-for="feature in copy.features" :key="feature">{{ feature }}</li>
      </ul>
    </div>
    <div class="future-scenario">
      <p class="pitch-kicker">{{ copy.plannedLabel }}</p>
      <blockquote class="copy-lines">{{ copy.scenario }}</blockquote>
      <p>{{ copy.purpose }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:family -->

---

<PitchSlide slide="demo" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <DemoRecording />
  <p class="demo-sequence"><template v-for="(step, index) in copy.sequence" :key="step"><span v-if="index" aria-hidden="true">→</span>{{ step }}</template></p>
</PitchSlide>

<!-- @notes:demo -->

---

<PitchSlide slide="implementation" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="decision-table">
    <div class="decision-table-head"><span v-for="column in copy.columns" :key="column">{{ column }}</span></div>
    <div v-for="decision in copy.decisions" :key="decision.need"><strong>{{ decision.need }}</strong><span>{{ decision.choice }}</span><span>{{ decision.result }}</span></div>
  </div>
  <p class="scope-note">{{ copy.scope }}</p>
</PitchSlide>

<!-- @notes:implementation -->

---

<PitchSlide slide="adoption" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="adoption-composition">
    <div class="education-scale">
      <strong>{{ copy.pupils }}</strong><span>{{ copy.pupilsLabel }}</span>
      <p>{{ copy.schools.prefix }}<b>{{ copy.schools.count }}</b><br>{{ copy.schools.source }}</p>
    </div>
    <div class="adoption-copy">
      <p v-for="point in copy.points" :key="point.title"><strong>{{ point.title }}</strong><br>{{ point.body }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:adoption -->

---

<PitchSlide slide="roadmap" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="roadmap">
    <div v-for="(step, index) in copy.steps" :key="step.title"><span>{{ String(index + 1).padStart(2, '0') }}</span><h3>{{ step.title }}</h3><p>{{ step.body }}</p></div>
  </div>
  <p class="takeaway">{{ copy.takeaway }}</p>
</PitchSlide>

<!-- @notes:roadmap -->

---

<PitchSlide slide="closing" v-slot="{ copy }" dark>
  <div class="closing-composition">
    <p class="pitch-kicker">{{ copy.kicker }}</p>
    <h2 class="copy-lines">{{ copy.title }}</h2>
    <p class="closing-ask copy-lines">{{ copy.ask }}</p>
    <p class="closing-line">{{ copy.statement }}</p>
  </div>
</PitchSlide>

<!-- @notes:closing -->
