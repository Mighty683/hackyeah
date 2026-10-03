# Mission 01 — Air Raid Alarm

## Goal

Teach children aged **7+** how to react safely during an air-raid warning without requiring them to read. The younger-child scenario is outside the MVP.

Core behavior to practice:

**Alarm → Move away from windows → Find a protected place → Contact a trusted adult → Stay there until the all-clear.**

The game should teach **actions, not terminology**.

---

## UX Principles

- No reading required.
- Every instruction is spoken aloud.
- Text is optional and secondary.
- One decision per screen.
- Use **2–4 choices for children aged 7+**.
- Choices should be visual actions, not text-heavy buttons.
- Use large touch/click targets.
- Always provide a **Replay Audio** button.
- No timers, “Game Over”, punishment, or failure screens.
- Wrong choices show a calm consequence and let the child try again.
- Avoid realistic warfare, weapons, injuries, panic, and spectacular explosions.

---

# Tutorial — Home Alone

## Scene 1 — The Alarm

The child is playing at home.

The phone vibrates and a warning symbol appears.

A short sample of the alarm siren is played.

Voice:

> “This is an alarm. Find a safe place.”

The child does not need to read the alert.

---

## Scene 2 — What Do You Do?

The room itself is interactive.

Possible actions:

- Go to the window.
- Go outside.
- Move deeper inside the home.

### Window

The character approaches the window.

Voice:

> “Windows are less safe. Move away from them.”

The scene resets.

### Outside

The character approaches the exit.

Voice:

> “The alarm has started. Stay inside and find a safer place.”

### Inside

The character moves away from the windows.

Voice:

> “Good. Move away from the windows.”

---

## Scene 3 — Find the Safest Place

Show a simple top-down apartment:

- living room with windows,
- bedroom with windows,
- kitchen with windows,
- internal hallway or other protected room.

Voice:

> “Find a place away from the windows.”

The child selects a room.

If the child chooses a room with windows:

> “There is a window here. Find a place deeper inside.”

If the child chooses the internal area:

The game briefly visualizes:

**Child → Wall → Wall → Outside**

Voice:

> “Two walls help protect you.”

Do not require the child to remember the phrase “two-wall rule”.

---

## Scene 4 — Contact a Trusted Adult

The child is already in the safe place.

Show large family avatars, for example:

- Mom
- Dad
- Grandparent

Voice:

> “You are safe. Let someone you trust know.”

Show two visual actions:

- repeated phone calls,
- one short message.

Correct behavior:

**Send one message.**

Example message, read aloud:

> “I am in a safe place.”

A parent replies with audio:

> “Good. Stay there and wait for the all-clear.”

---

## Scene 5 — Loud Noise

A loud but non-frightening sound is heard.

Use only subtle environmental movement.

No realistic explosion, fire, injuries, or panic.

Voice:

> “You hear a loud noise. What do you do?”

Visual choices:

- go to the window,
- go to the door,
- stay in the protected place.

Correct behavior:

**Stay in the protected place.**

Feedback:

> “Good. Stay here.”

Wrong choice feedback:

> “Do not go to the window yet.”

or:

> “Do not go outside yet.”

---

## Scene 6 — Silence

The alarm sound stops.

Nothing happens for a moment.

Voice:

> “It is quiet now. What do you do?”

Choices:

- leave,
- stay and wait.

Correct behavior:

**Stay and wait.**

If the child tries to leave:

> “Quiet does not mean the danger is over. Wait for the all-clear.”

---

## Scene 7 — All-Clear

The phone vibrates again.

Play a short sample of the official all-clear sound.

Voice:

> “The alarm is over. Now follow instructions from adults or emergency services.”

The mission ends.

---

# End-of-Mission Recall

Do not show a score.

Show the learned behavior as a simple visual sequence:

**Alarm → Away from windows → Protected place → Message a trusted adult → Stay → All-clear**

Voice:

> “Alarm. Move away from windows. Find a safe place. Tell someone you trust. Stay there until the all-clear.”

Optional reward:

- mission sticker,
- badge for completing the training.

The reward should be for **completion**, not perfection.

---

# MVP Difficulty — Ages 7+

The younger-child scenario (ages 4–6) is deferred and not implemented in the MVP. There is one mission flow, with no age selection or age-specific branching.

- 2–4 choices.
- Less narrator guidance.
- More realistic wrong choices.
- Child selects the safest room independently.
- Can compare “near” and “far”.
- Can use the outdoor simulation.

---

# Simulation Mode — Ages 7+

The child is walking home from school when the alarm begins.

The environment shows:

- home far away,
- school farther away,
- a solid nearby building,
- a park,
- a bus stop.

No large hint tells the child what to choose.

Voice:

> “You hear the alarm.”

The child must decide where to move.

The scenario tests whether the child prefers a nearby solid shelter over remaining outdoors or travelling a long distance.

---

## Outdoor Loud-Noise Branch

The branch follows the destination the child just selected. Home and school are too far away; the open park and bus stop offer little protection in this fictional scene. Feedback explains that the child is still outside, then **See what happens** opens a short story beat:

> “You start towards home. Before you get there, you hear a loud noise.”

School, park and bus-stop choices have their own matching narration. A restrained sound cue accompanies this interruption. Do not use realistic explosions or jump scares.

**Choose what to do** opens the physical-action decision. Keep the same street setting and show recognizable poses as equivalent choices:

1. **Get down:** drag downward when the scene fits, or tap the pictured pose. “Keep standing” receives calm feedback and a retry.
2. **Cover your head:** tap the pictured pose. “Keep hands down” receives calm feedback and a retry.
3. **Stay down:** a separate “An adult helps you” story beat explains that a trusted adult helps the child reach shelter when it is possible in the story.
4. **Follow the adult:** show arrival inside the practice shelter before asking the child to tell a trusted adult.

Selecting the nearby practice shelter goes directly to the arrival scene and skips the outdoor recovery. Replay starts a fresh story, without retaining the previous destination.

---

# What the Scenario Trains

- Alarm recognition.
- Moving away from windows.
- Choosing a protected internal place.
- Understanding the two-wall principle visually.
- Avoiding unnecessary outdoor movement.
- Messaging a trusted adult instead of repeatedly calling.
- Staying sheltered after a loud noise.
- Understanding that silence is not the all-clear.
- Reacting safely outdoors.
- Waiting for official instructions.

---

# Visual Direction

The experience should feel **friendly, calm, and credible**.

Use:

- simple 2D illustration,
- recognizable home and street environments,
- clear characters,
- restrained sound and animation.

Avoid:

- visible weapons,
- military aesthetics,
- realistic drones,
- graphic explosions,
- injuries,
- screaming,
- dramatic war music,
- frightening imagery.

The product should feel like **civil-safety training for children**, not a war simulator.

---

# Android implementation plan and demo boundaries

Implemented in three parallel areas, integrated through a shared mission-state contract:

1. **Scenario logic:** home scenes, two to four choices, retry/advance behavior, outdoor recovery branch, and focused flow checks.
2. **Visual experience:** illustrated rooms/street, selected-action consequences, two-wall diagram, fictional family avatars and messages, drag-or-tap getting down, head protection, recall and completion sticker.
3. **Offline audio:** Android embedded English speech, replay and cancellation, official alarm/all-clear playback excerpts, a restrained environmental sound, and gentle interaction feedback.

Integration adds narrated practice selection beside the existing map game. Both child entry and parent “Play together” lead to the same 7+ MVP: choose alarm practice, then home or outside. There is no age-selection screen or younger-child implementation; saved age does not change the mission. No age verification is claimed. Screen-flow documentation records the implemented mission separately from future missions and reviewed emergency assistance.

The home scene explicitly assumes the agreed shelter cannot be reached. An internal room and two walls are a fallback, not a verified shelter or guarantee of safety. “I am away from windows” replaces the example message’s unconditional safety claim. Outdoor destinations are fictional; the nearby building represents a practice shelter. Five possible destinations are split across two decisions to keep each screen at four choices or fewer. No real messages or calls are made, and no saved contacts or practice pins are used.

Narration requires an installed offline English Android voice. If missing or playback fails, the app asks for adult help and retains text as a fallback; this device state does not satisfy independent play without reading. Alarm/all-clear sounds are short teaching excerpts from original Polish recordings, not the complete official-duration signal. Asset attribution and licensing are in `mobile/assets/audio/mission01/README.md`.

Sound effects have a separate mute control that leaves spoken instructions and replay available. Selection cues mark outdoor destination choices; soft action cues accompany getting down and covering the head; success and retry cues support other feedback without replacing its words. Cues can play without an installed voice, but the adult-help fallback still applies. All playback stops on backgrounding or exit.

## Initial MVP verification — 2026-10-03

These results describe the initial MVP, before the outdoor-story and sound-effects revision. Current verification is reported with that revision.

- Flutter analysis: no issues.
- Nine focused tests passed: five scenario-flow tests, three mission-screen tests, and one launcher test confirming direct 7+ mode selection and return navigation.
- Android debug APK built successfully.
- Connected Android phone initialized an installed local English voice (`en-us-x-tpf-local`); the alarm scene and interactive room were inspected before the age simplification. The phone locked before the final manual entry check; the simplified entry is covered by the launcher test.

## Safety-content references

These sources inform the limited training content; the mission has not undergone qualified child-safety review and is not real emergency assistance:

- [RCB: official Polish alarm signals and recordings](https://www.gov.pl/web/rcb/sygnaly-alarmowe3).
- [Polish government: air attack guidance](https://www.gov.pl/attachment/66632d1d-e2bb-4ed4-be0f-c25457bd5dcc), including nearby shelter and getting down/protecting the head outdoors.
- [DSNS: nearest shelter and windowless/two-wall fallback](https://lg.dsns.gov.ua/news/iak-diiati-pid-cas-signalu-povitriana-trivoga).
- [DSNS: remain sheltered until official all-clear](https://bezpeka.dsns.gov.ua/materials/pravyla-perebuvannya-v-ukrytti).

Follow reviewed local instructions in a real event. The general Polish warning sound alone does not identify an air raid; this fictional scene supplies that context.
