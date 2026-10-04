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
duration: 3min35sec
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

<PitchSlide slide="audience" v-slot="{ copy }">
  <h2 class="copy-lines">{{ copy.title }}</h2>
  <div class="preparedness-composition">
    <div>
      <h3>{{ copy.contextTitle }}</h3>
      <p>{{ copy.context }}</p>
      <p>{{ copy.response }}</p>
    </div>
    <div class="preparedness-development">
      <h3>{{ copy.contentsTitle }}</h3>
      <p class="preparedness-takeaway">{{ copy.gap }}</p>
    </div>
  </div>
  <p class="preparedness-sources"><a v-for="source in copy.sources" :key="source.url" :href="source.url" target="_blank" rel="noopener noreferrer" @click.stop>{{ source.label }}</a></p>
</PitchSlide>

<!-- @notes:audience -->

---

<PitchSlide slide="children" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="preparedness-composition">
    <div>
      <h3>{{ copy.developmentTitle }}</h3>
      <p>{{ copy.developmentIntro }}</p>
      <p class="muted">{{ copy.development }}</p>
    </div>
    <div class="preparedness-development">
      <h3>{{ copy.adaptationTitle }}</h3>
      <p>{{ copy.adaptation }}</p>
    </div>
  </div>
  <p class="preparedness-sources"><a v-for="source in copy.sources" :key="source.url" :href="source.url" target="_blank" rel="noopener noreferrer" @click.stop>{{ source.label }}</a></p>
</PitchSlide>

<!-- @notes:children -->

---

<PitchSlide slide="problem" v-slot="{ copy }">
  <h2 class="copy-lines">{{ copy.title }}</h2>
  <div class="problem-composition">
    <div class="story">
      <p class="pitch-kicker">{{ copy.kicker }}</p>
      <p class="story-lead">{{ copy.storyLead.text }}</p>
      <p class="story-body">{{ copy.story }}</p>
      <p class="source-caption"><a :href="copy.sourceUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ copy.sourceLabel }}</a></p>
    </div>
    <div class="problem-insight">
      <p>{{ copy.insight.text }}<br><strong>{{ copy.insight.emphasis }}</strong></p>
      <p class="muted">{{ copy.focus }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:problem -->

---

<PitchSlide slide="overview" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="solution-overview">
    <div class="solution-description">
      <h3>{{ copy.lead }}</h3>
      <p>{{ copy.description }}</p>
      <p>{{ copy.practice }}</p>
      <p>{{ copy.narration }}</p>
      <p class="solution-promise">{{ copy.promise }}</p>
    </div>
    <div class="solution-prototype">
      <img v-if="copy.screenshotSrc" class="prototype-screenshot" :src="copy.screenshotSrc" :alt="copy.screenshotAlt">
      <div v-else class="prototype-screenshot-placeholder" role="img" :aria-label="copy.screenshotPlaceholder">{{ copy.screenshotPlaceholder }}</div>
      <a v-if="copy.prototypeUrl" class="prototype-link" :href="copy.prototypeUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ copy.prototypeLabel }}</a>
      <div class="prototype-audio-note">
        <p class="prototype-audio-hint"><span aria-hidden="true">🔇</span> {{ copy.audioHint }}</p>
        <p class="prototype-caption">{{ copy.prototypeCaption }}</p>
      </div>
    </div>
  </div>
</PitchSlide>

<!-- @notes:overview -->

---

<PitchSlide slide="family" v-slot="{ copy }">
  <h2>{{ copy.title }}</h2>
  <div class="scenario-examples">
    <div v-for="scenario in copy.scenarios" :key="scenario.question" class="scenario-example">
      <p class="pitch-kicker">{{ scenario.status }}</p>
      <h3 class="copy-lines">{{ scenario.question }}</h3>
      <p class="scenario-description">{{ scenario.description }}</p>
    </div>
  </div>
</PitchSlide>

<!-- @notes:family -->


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
  <div class="value-propositions">
    <div v-for="point in copy.points" :key="point.title">
      <h3>{{ point.title }}</h3>
      <p>{{ point.body }}</p>
    </div>
  </div>
  <div class="value-context">
    <p><strong>{{ copy.scaleSummary }}</strong><br><span>{{ copy.scaleSource }}</span></p>
    <p>{{ copy.funding }}</p>
  </div>
</PitchSlide>

<!-- @notes:adoption -->

---

<PitchSlide slide="roadmap" v-slot="{ copy }">
  <h2 class="closing-title">{{ copy.title }}</h2>
  <p class="roadmap-intro">{{ copy.intro }}</p>
  <div class="roadmap">
    <div v-for="(step, index) in copy.steps" :key="step.title"><span>{{ String(index + 1).padStart(2, '0') }}</span><h3>{{ step.title }}</h3><p>{{ step.body }}</p></div>
  </div>
  <p class="takeaway">{{ copy.takeaway }}</p>

</PitchSlide>

<!-- @notes:roadmap -->


---

<PitchSlide slide="thanks" v-slot="{ copy }" dark class="thanks-slide">
  <h1>{{ copy.title }}</h1>
  <p class="thanks-tagline">{{ copy.tagline }}</p>
  <div class="thanks-links">
    <div>
      <h3>{{ copy.prototypeLabel }}</h3>
      <a :href="copy.prototypeUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ copy.prototypeLinkLabel }} ↗</a>
      <p class="thanks-caption">{{ copy.prototypeCaption }}</p>
    </div>
    <div>
      <h3>{{ copy.analysisLabel }}</h3>
      <a v-if="copy.analysisUrl" :href="copy.analysisUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ copy.analysisLinkLabel }} ↗</a>
      <p v-else class="thanks-caption">{{ copy.pendingLink }}</p>
      <p v-if="copy.analysisUrl && copy.analysisPasswordLabel" class="thanks-caption">{{ copy.analysisPasswordLabel }}</p>
    </div>
    <div>
      <h3>{{ copy.contactLabel }}</h3>
      <div v-for="creator in copy.creators" :key="creator.name" class="thanks-person">
        <strong>{{ creator.name }}</strong>
        <a v-if="creator.linkedinUrl" :href="creator.linkedinUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ copy.linkedinLabel }} ↗</a>
        <a v-if="creator.email" :href="'mailto:' + creator.email" @click.stop>{{ creator.email }}</a>
        <p v-if="!creator.linkedinUrl && !creator.email" class="thanks-caption">{{ copy.pendingContact }}</p>
        <p v-else-if="!creator.email" class="thanks-caption">{{ copy.pendingEmail }}</p>
        <p v-else-if="!creator.linkedinUrl" class="thanks-caption">{{ copy.pendingLinkedin }}</p>
      </div>
    </div>
  </div>
</PitchSlide>

<!-- @notes:thanks -->
