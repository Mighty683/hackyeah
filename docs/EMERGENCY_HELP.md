# Emergency-help prototype

This is an **unreviewed prototype, not for real emergencies**. The UI states this at entry and on its help screens. Do not make test calls to 112. No clinical/safeguarding reviewer has been identified, and no child comprehension study has been performed.

## Implemented scope

See [“I need help” decision diagram](I_NEED_HELP_DECISION_DIAGRAM.md) for the implemented helper, situation, air-raid and phone-action branches.

The separate help screen is reachable from welcome without role selection, startup/loading errors, and the map's loading/error/active states. Opening it from the map pauses map GPS and narration; closing it restores the opener and starts a fresh map position request when foreground. During map loading, help remains available and defers creation of the map until help closes. Help has its own calm theme and visible prototype notice, without a training mascot, scores, countdowns, sirens, forced speech, or claims that someone is monitoring the child.

All help text is bundled and works without internet or telephone service. Every entry first asks **“Can someone nearby help you?”**, including when the child would later choose not responding:

- **Yes** shows “Tell that adult what happened.” **They cannot help** continues to situation selection.
- **No one can help** goes directly to the four situation choices.
- **I’m not sure** clarifies whether a trusted adult, police officer or shop worker is already nearby, without asking the child to walk around.

Once no helper is confirmed, the following situations are offered. **Someone can help now** returns to the adult instruction and clears the earlier no-helper answer. Back follows the previous help step; back from entry closes help.

| Situation | Initial behaviour | Subsequent orientation |
| --- | --- | --- |
| Someone is not responding | With reported normal/emergency-only phone service, show “Call 112 now” and the native mock action | Unknown/unavailable service shows the offline adult-help instruction; **Practise the next step** opens operator guidance without claiming that a call connected |
| Air raid | Ask inside/outside/explosions outside/unsure | Window/shelter guidance, outside explosion guidance, or seeking trusted-adult support; no shelter map or navigation |
| Lost/separated | Show “Stay here unless there is danger” immediately | Reuse the existing no-helper answer; offer contact actions only when the relevant phone-service condition is met |
| I don’t know | Show “Call out for an adult’s help” | Offer eligible contact actions; no diagnosis, hazard investigation, or invented severity score |

There is no persistent 112 footer. The mock action appears only after no helper has been confirmed, on the not-responding, lost or unsure instruction, and while Android reports normal or emergency-only telephone service. It is absent from helper questions, adult support, situation selection, air-raid guidance and operator practice. Unknown/unavailable service keeps offline instructions visible without a calling option. Service changes update the current instruction/actions without repeating questions.

**The helper-first sequence and service-based visibility are the requested MVP showcase policy, not a validated emergency or medical protocol.** In particular, the initial helper question also precedes the not-responding branch. These choices must not be attributed to Ministry of Health guidance or carried into real assistance without qualified review.

## Phone context and familiar places

Help independently uses foreground GPS with the existing location grant. It never opens another permission prompt, waits for GPS before showing instructions, records a track, or runs in the background. Leaving/backgrounding help cancels its GPS subscription; resuming requests a fresh fix. Map GPS remains paused while help owns its separate subscription.

The optional hint reads **“You may be near [name]. This is a saved place.”** It considers only named, non-demo family pins, with a position at most 30 seconds old, reported accuracy at most 25 m, and distance to the pin plus reported accuracy at most 50 m. It selects the nearest qualifying pin. Fictional startup Home and other demo pins are excluded. Missing permission, poor/stale GPS, unreadable family data or no matching pin simply omits the hint.

Proximity does not establish safety, an entrance, shelter access, being indoors, or another person's presence. It never chooses an emergency branch, directs the child to a saved pin, or skips the air-raid inside/outside question. The reduced lost flow comes from asking about helpers once, not from guessing that a nearby place is safe.

## What phone actions actually do

- For the MVP showcase, tapping 112 opens a native Android demo dialog labelled as a pretend call. It never launches the dialler or places a call, including if the dialog fails to open.
- Trusted-adult actions appear only on the no-helper lost/unsure instructions, with normal telephone service and at least one usable saved contact. They use `url_launcher` to hand a `tel:` URI to the real phone app after an explicit tap; the app does not automatically place calls. Emergency-only service does not enable these actions.
- Launcher success means only that the phone app opened. There is no answer detection, retry chain, emergency-service dispatch, or delivery tracking.
- Trusted contacts come from the adult-configured encrypted `FamilyPlanRepository`, shared with parent setup. Blank/unsupported numbers are filtered; USSD, URI injection, extensions and short emergency numbers are not accepted as trusted-contact numbers.
- Contact-load failures are reported separately from missing contacts. Help never edits or overwrites family records.
- Android's native service-state stream reports the default subscription as available, emergency-only, unavailable or unknown. It starts unknown, refreshes as reports arrive, stops when help backgrounds/exits, and is re-established on return. Unsupported devices, access restrictions and stream errors remain unknown; no new dangerous phone permissions are requested. Android 13+ registration excludes location data from this telephony callback.
- Devices without voice capability do not offer calling. On Android API 30+, emergency-service registration can enable the mock even when ordinary voice is out of service. API 24–29 cannot inspect that public registration list and may miss emergency-only coverage; this is another limit of the showcase gating, not proof that a real emergency call is impossible.
- This is a telephone-service hint, not an internet/Wi-Fi check, signal-strength measurement, all-SIM assessment, or guarantee that a call can connect. An absent internet connection does not by itself establish that telephone calls are unavailable. Unknown service is not proof that emergency calling is impossible; hiding the mock action in that state is the demo policy above. The callback's default-subscription behavior and service-state meanings are documented by [Android ServiceStateListener](https://developer.android.com/reference/android/telephony/TelephonyCallback.ServiceStateListener) and [Android ServiceState](https://developer.android.com/reference/android/telephony/ServiceState).
- **Background SMS is not implemented.** No SMS is sent or queued, and no screen says a parent was notified. Consent, Android permissions/platform feasibility, expiry, and stale-message handling remain unresolved.
- No phone action runs automatically on entry, navigation, or replay. Do not use this prototype to practise calling an emergency number.

## Source-to-content record

Primary pages fetched and read on 2026-10-03. English wording is a developer adaptation, **not a reviewed translation or validated child protocol**.

1. [Ministry of Health — Sposób postępowania na miejscu zdarzenia](https://www.gov.pl/web/zdrowie/sposob-postepowania-na-miejscu-zdarzenia): personal safety, calling 112 for an emergency, shouting for support, following medical dispatcher instructions. The prototype intentionally does not implement breathing assessment, CPR, recovery position, or complete first aid. **A no-signal unresponsive-person flow is incomplete and must not be presented as sufficient assistance.**
2. [Government safety guide — Atak z powietrza](https://www.gov.pl/web/poradnikbezpieczenstwa/atak-z-powietrza): previously agreed shelter route, stairs instead of lifts, lying down/covering the head after an explosion outdoors, not leaving shelter hastily. Guidance also recommends SMS rather than overloading telephone lines; the prototype does not offer routine parent voice calls in the air-raid flow. Its current demo policy also omits the 112 mock action throughout that branch.
3. [Government safety guide — Schronienia](https://www.gov.pl/web/poradnikbezpieczenstwa/schronienia): stay away from windows if a marked shelter is unavailable, and examples of outside shelter such as basements/underground passages. **The app does not verify shelter accessibility or safe routes.** The game’s fictional base and parent-entered practice places are never used as help destinations.
4. [Polish Police — Uwaga! Zaginęło dziecko](https://lodzka.policja.gov.pl/ld/informacje/75108,Uwaga-Zaginelo-dziecko.html): remain at the place where separated, do not leave with strangers, seek police or shop staff support. The danger exception is a cautious adaptation of the project’s own safety-first principle, not a complete evacuation protocol.
5. [112 — Jak zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/jak-zglaszac) and [Co zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/co-zglaszac): real emergency-service scope, operator-led reporting and avoiding false/practice calls.

The Android references above describe technical reports only; they do not validate the helper-first decision flow, emergency eligibility, or the decision to hide an action on unknown service.

## Before real-use release

Obtain qualified Polish emergency/first-aid and child-safeguarding review of the helper-first sequence and service gating, validate the English wording with the target children (consider Polish for actual Polish users), complete medically appropriate no-service guidance, and evaluate real-device accessibility/dialler behaviour without placing emergency test calls. Ensure trusted-contact setup does not assume every caregiver is safe. Define the SMS capability and consent separately. Removing the prototype label alone is not sufficient.
