---
theme: default
title: Safe Path — practising the next decision
info: |
  Safe Path is a child-focused Android training game for the HackYeah 2026 Defence challenge.
  Ten-slide pitch. The app recording is a placeholder; planned capabilities are labelled.
author: Safe Path
keywords: Safe Path, HackYeah 2026, Defence, children, safety training
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

<PitchSlide number="01" label="Safe Path" dark>
  <div class="cover-composition">
    <div>
      <p class="pitch-kicker">Practise before it matters</p>
      <h1>Safe Path</h1>
      <p class="cover-statement">A game that helps children<br>practise everyday safety skills.</p>
      <p class="cover-detail">Children aged 7–14 · Android prototype</p>
    </div>
    <img class="cover-mascot" src="/images/safe-path-icon-foreground.png" alt="Safe Path's friendly dinosaur holding a compass">
  </div>
  <template #footer>Preparedness begins with a decision a child can understand</template>
</PitchSlide>

<!--
[0:00–0:15 · 15 seconds]
Safe Path helps children practise the next decision before an emergency happens. We are building a serious game for children aged seven to fourteen, with a separate journey for the adult helping them prepare.

Content source: docs/HackYeah 2026.pdf, opening concept. Ages are the intended audience, not a claim of validation across all ages.
Artwork: existing Safe Path mascot, generated with OpenAI image tools; provenance in mobile/assets/branding/README.md. Nunito is bundled under the SIL Open Font License.
-->

---

<PitchSlide number="02" label="The problem">
  <h2>Knowing is not the same<br>as being ready</h2>
  <div class="problem-composition">
    <div class="story">
      <p class="pitch-kicker">Poland · July 2023</p>
      <p class="story-lead">Lenka was <strong>five</strong>.</p>
      <p>When her mother lost consciousness, she called 112 and gave their address.</p>
      <p class="source-caption">A documented incident, not a Safe Path user story.</p>
    </div>
    <div class="problem-insight">
      <p>A child may have to ask for help<br><strong>without an adult guiding them.</strong></p>
      <p class="muted">Our focus: a place to practise making the next decision.</p>
    </div>
  </div>
  <template #footer>Source: Polish Police, 7 July 2023</template>
</PitchSlide>

<!--
[0:15–0:40 · 25 seconds]
In July 2023, five-year-old Lenka called 112 when her mother lost consciousness. She gave the address and explained that her one-year-old brother was also home. She knew how to ask for help. The story shows why knowing a rule and being able to use it are different challenges. Our product focuses on practising decisions, before that moment arrives.

Primary source: https://policja.pl/pol/aktualnosci/233330,5-latka-wezwala-pomoc-do-mamy-ktora-stracila-przytomnosc.html
Incident: 4 July 2023. Report: 7 July 2023. Lenka is younger than our target audience; this is context, not evidence of product effectiveness.
Draft source: docs/HackYeah 2026.pdf, “Knowing is not the same as being ready” and “The Problem”, consolidated to avoid repetition.
-->

---

<PitchSlide number="03" label="Who it is for">
  <h2>Children need practice<br>they can understand</h2>
  <div class="audience-composition">
    <div class="age-anchor"><strong>7–14</strong><span>years old</span></div>
    <div class="audience-copy">
      <p><strong>For the child</strong><br>One situation, a few choices, calm feedback.</p>
      <p><strong>With a parent</strong><br>Familiar people and places make practice personal.</p>
      <p><strong>For civil preparedness</strong><br>Alarm and separation scenarios are our starting point.</p>
    </div>
  </div>
  <template #footer>Defence fit: preparing people to make decisions under pressure</template>
</PitchSlide>

<!--
[0:40–1:00 · 20 seconds]
Our audience is children aged seven to fourteen and the adults helping them prepare. We use simple language, illustrated situations and calm feedback. The Defence brief asks how people can prepare and make better decisions under pressure. We address the civilian side of that challenge, starting with alarm and separation practice.

Sources: docs/Details - Defence.pdf, description; docs/UX.md; docs/HackYeah 2026.pdf, “Who is it for?”.
Official context: https://www.gov.pl/web/poradnikbezpieczenstwa/pytania-i-odpowiedzi
The handbook covers outages, natural disasters and military threats. It is not an endorsement of this app.
The draft's claim that the Ministry is “now preparing” a grades 1–7 handbook is omitted because its October 2026 status was not verified. Do not describe all official guidance as exclusively adult-oriented.
-->

---

<PitchSlide number="04" label="The solution">
  <h2>Learn by making a decision</h2>
  <p class="slide-intro">Short scenarios turn instructions into something a child can practise.</p>
  <ol class="learning-loop">
    <li><span>01</span><strong>Situation</strong><p>See a familiar scene</p></li>
    <li><span>02</span><strong>Decision</strong><p>Choose what to do</p></li>
    <li><span>03</span><strong>Action</strong><p>Try it in the game</p></li>
    <li><span>04</span><strong>Consequence</strong><p>See what happens</p></li>
    <li><span>05</span><strong>Explanation</strong><p>Understand why</p></li>
  </ol>
  <p class="takeaway">A mistaken choice gets an explanation and a chance to retry.</p>
  <template #footer>Implemented: illustrated alarm and lost practice · Fictional scenarios</template>
</PitchSlide>

<!--
[1:00–1:20 · 20 seconds]
This is the learning loop. A child sees a situation, chooses an action, sees its consequence and gets a short explanation. If a choice is unhelpful, we explain why and allow another try. Alarm and lost practice already implement this approach. The immediate benefit is a completed practice decision; transfer to real-life behaviour still needs testing.

Sources: docs/UX.md; mobile/lib/features/mission/practice_launcher.dart; mobile/lib/features/mission/lost_mission_content.dart; mobile/README.md.
Draft source: docs/HackYeah 2026.pdf, “Our Solution”.
The original “prepared behaviour” wording is an intended outcome, not a measured result. No real emergency procedures are taught by this slide.
-->

---

<PitchSlide number="05" label="Family context">
  <h2>Practice linked to a child’s world</h2>
  <div class="family-composition">
    <div>
      <p class="pitch-kicker">Working in the prototype</p>
      <ul class="plain-list">
        <li>Parent adds contacts and practice places</li>
        <li>Photos help the child recognise a meeting place</li>
        <li>Lost practice includes pretend calls and reunion</li>
      </ul>
    </div>
    <div class="future-scenario">
      <p class="pitch-kicker">Next scenario · planned</p>
      <blockquote>“The mobile network is down.<br>Where did your family<br>agree to meet?”</blockquote>
      <p>Rehearse the family plan when communication fails.</p>
    </div>
  </div>
  <template #footer>Official Polish guidance recommends agreeing and regularly practising a family plan</template>
</PitchSlide>

<!--
[1:20–1:40 · 20 seconds]
Official Polish guidance recommends a family plan with contacts and meeting places, rehearsed regularly. Our prototype already lets a parent add contacts, places and photos. Lost practice uses familiar photos and pretend communication. A network-outage rehearsal is the next scenario we want to build, connecting that family context to a communication failure.

Primary source: https://www.gov.pl/web/poradnikbezpieczenstwa/plan-na-kryzys
Implementation: mobile/lib/features/parent/data/family_plan.dart; mobile/lib/features/mission/lost_mission_content.dart; mobile/README.md.
Draft source: docs/HackYeah 2026.pdf, “Why?”.
Saved places are parent-selected practice targets, not verified safe destinations. Training calls and messages are simulated. The network-down scenario and a complete family emergency-plan rehearsal are planned. Demo data should be fictional; parent setup has no access gate.
-->

---

<PitchSlide number="06" label="Demo">
  <h2>One decision in Safe Path</h2>
  <DemoRecording />
  <p class="demo-sequence">Alarm scenario <span>→</span> Child chooses <span>→</span> Calm feedback <span>→</span> Retry</p>
  <template #footer>Recording placeholder · Fictional training in the Android app</template>
</PitchSlide>

<!--
[1:40–2:25 · 45 seconds reserved for the recording]
Show one complete learning moment in the Android app: open alarm practice, make a choice, see the explanation, retry and reach the recap. Keep the clip focused on the learning loop. Use fictional details and do not include a real phone call.

The recording has not been created. This slide deliberately shows a placeholder; it is not an interactive app demo.
When ready: place the recording at public/demo/safe-path-demo.mp4 and change the component above to <DemoRecording src="/demo/safe-path-demo.mp4" />. Keep a local copy available as the pitch guide's backup plan. Update the visible footer when the recording is installed.
If presenting before the recording exists, describe the sequence explicitly as the intended demo rather than implying the audience saw it.
-->

---

<PitchSlide number="07" label="Implementation">
  <h2>Built for practice without a network</h2>
  <div class="decision-table">
    <div class="decision-table-head"><span>Need</span><span>Our choice</span><span>What works today</span></div>
    <div><strong>Keep practice available</strong><span>Bundled Flutter + Flame scenarios</span><span>Alarm and lost practice without a backend</span></div>
    <div><strong>Use familiar context</strong><span>Local family records and photos</span><span>Encrypted records; app-private photos</span></div>
    <div><strong>Recognise nearby places</strong><span>Bundled OSM map + foreground GPS</span><span>Adult-accompanied walking practice near the arena</span></div>
  </div>
  <p class="scope-note">Demo map only. Routes are unverified. Real emergency assistance is not validated.</p>
  <template #footer>Map data © OpenStreetMap contributors · ODbL 1.0</template>
</PitchSlide>

<!--
[2:25–2:50 · 25 seconds]
We chose local, bundled content so practice does not depend on a backend. Family records stay encrypted on the device; photos are stored separately in app-private files. The map uses a bundled OpenStreetMap snapshot and foreground GPS. That gives us a working offline prototype, with a clear limit: walking practice covers the arena demo area, with an adult, and its routes are unverified.

Sources: mobile/lib/features/parent/data/family_plan_repository.dart; mobile/lib/features/game/walking_navigation.dart; mobile/lib/audio/practice_audio.dart; mobile/assets/maps/README.md.
Map attribution: https://www.openstreetmap.org/copyright
Offline narration requires an installed offline English Android voice. GPS requires permission and device positioning; it is not simulated movement. There is no worldwide navigation or live hazard feed.
Separate help prototype: unreviewed, not for real emergencies. Current code mocks 112 via a native dialog; trusted contacts can open the phone app after an explicit tap. Do not claim automatic calls, SMS, verified shelters or an emergency service.
-->

---

<PitchSlide number="08" label="Adoption and value">
  <h2>A family activity, a possible school pilot</h2>
  <div class="adoption-composition">
    <div class="education-scale">
      <strong>3.2M</strong><span>primary-school pupils in Poland</span>
      <p>Across approximately <b>14,000 schools</b><br>GUS · 2024/25 school year</p>
    </div>
    <div class="adoption-copy">
      <p><strong>Families start together</strong><br>A child rehearses; a parent adds familiar context.</p>
      <p><strong>Schools could host guided practice</strong><br>Proposed pilot with teachers and safety specialists.</p>
      <p><strong>Funding hypothesis</strong><br>School or municipal programmes fund reviewed scenario packs and rollout.</p>
    </div>
  </div>
  <template #footer>National education context, not user traction · Adoption and funding remain untested</template>
</PitchSlide>

<!--
[2:50–3:15 · 25 seconds]
Poland has about 3.2 million primary-school pupils across 14,000 schools. That is the education context, not our user count. We would start with families, then test guided sessions in schools. One funding hypothesis is school or municipal programmes paying for reviewed scenario packs and rollout. We have not validated demand, partnerships or willingness to pay.

Primary source, 2024/25 national figures including special primary schools: https://stat.gov.pl/dla-mediow/informacje-prasowe/polska-szkola-w-liczbach-jak-wyglada-edukacja-w-roku-szkolnym-20242025%2C36%2C1.html
Draft source: docs/HackYeah 2026.pdf, scale and “who benefits” notes. The school population is not an exact count of children aged 7–14 or an addressable paying market.
The draft's 2.6M online estimate is omitted from the slide to avoid mixing populations and dates. Primary reference: https://gemius.com/documents/91/Internet_dzieci_2026.pdf (June 2026 report, November 2025 Mediapanel data).
-->

---

<PitchSlide number="09" label="Next steps">
  <h2>Safety review and learning tests</h2>
  <div class="roadmap">
    <div><span>01</span><h3>Review</h3><p>Safety specialists review procedures and scenarios.</p></div>
    <div><span>02</span><h3>Test</h3><p>Children and parents test comprehension, tone and recall.</p></div>
    <div><span>03</span><h3>Extend</h3><p>Add reviewed scenarios, commissioned art and carefully tested rewards.</p></div>
  </div>
  <p class="takeaway">Long-term value: a reviewed scenario library and evidence of what children learn.</p>
  <template #footer>No child study or measured learning outcomes yet</template>
</PitchSlide>

<!--
[3:15–3:40 · 25 seconds]
The next step is to review procedures with safety specialists and test comprehension with children and parents. We would measure decisions during practice and retention later, rather than assume a completed game means preparedness. Then we can expand the scenario library, improve tone and artwork, and test motivation without rewarding risky choices. Evidence and institutional trust must be earned.

Draft source: docs/HackYeah 2026.pdf, long-term advantage and improvement notes. Commissioned artwork is future work; current app art includes AI-generated assets.
Research context, not proof for Safe Path: the 2026 Flood Alert! study reported knowledge and self-efficacy improvements in 45 Indonesian UNIVERSITY geography-education students, using a single-group pre/post design, no control group. It does not validate child outcomes or real emergency behaviour. https://jamba.org.za/index.php/jamba/rt/printerFriendly/2005/3933
Proposed pilot measures and funding approach are recommendations for next steps, not completed work or signed agreements.
-->

---

<PitchSlide number="10" label="Safe Path" dark>
  <div class="closing-composition">
    <p class="pitch-kicker">Our next step</p>
    <h2>A reviewed pilot<br>with children and parents</h2>
    <p class="closing-ask">We are looking for educators and safety specialists<br>to help test the next version.</p>
    <p class="closing-line">Safe Path helps children practise the next decision.</p>
  </div>
  <template #footer>Prototype · AI-assisted development and artwork · Flutter, Flame and OpenStreetMap</template>
</PitchSlide>

<!--
[3:40–4:00 · 20 seconds]
We have a working Android training prototype. Now we want to run a reviewed pilot with children and parents, supported by educators and safety specialists. Safe Path's purpose is simple: give children a way to practise the next decision, before they need it.

Submission disclosures: Significant AI assistance was used in development, content and artwork, including this presentation. Existing app art uses OpenAI image generation; software uses Flutter and Flame; bundled map data is © OpenStreetMap contributors under ODbL 1.0; Nunito is under SIL OFL. See asset provenance files and dependency manifests for details. This is a prototype, without validated emergency guidance or measured child outcomes.
The brief also requires project title, team name, team members and project description with a maximum ten-slide PDF. Team identity and the full member list have not been supplied; the author credit in the draft is not evidence of the full team. Confirm those submission fields and the distinction between pre-event and hackathon work before submission. Do not invent them.
Sources: docs/Details - Defence.pdf, resource/AI disclosure and submission sections; docs/Od chaosu do mistrzowskiego pitchu — HackYeah.pdf, implementation limits and next step guidance.
-->
