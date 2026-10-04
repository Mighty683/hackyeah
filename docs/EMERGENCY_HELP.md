# Emergency-help prototype

This is an **unreviewed prototype, not for real emergencies**. The UI states this at entry and on its help screens. Do not make test calls to 112. No clinical/safeguarding reviewer has been identified, and no child comprehension study has been performed.

## Implemented scope

See [“I need help” decision diagram](I_NEED_HELP_DECISION_DIAGRAM.md) for the implemented helper, situation, air-raid and phone-action branches.

The separate help screen is reachable from welcome without role selection, startup/loading errors, and the map's loading/error/active states. Opening it from the map pauses map GPS and narration; closing it restores the opener and starts a fresh map position request when foreground. During map loading, help remains available and defers creation of the map until help closes. Help has its own calm theme and visible prototype notice, without a training mascot, scores, countdowns, sirens, forced speech, or claims that someone is monitoring the child.

Help opens directly on **What is happening?** with four choices: not responding, air raid, lost and unsure. Instructions offer optional **A trusted adult is here**. Adult support preserves the previous scenario; **They cannot help** or Back returns to it. There is no prerequisite helper question.

Not responding offers **Practise calling 112** and **Practise the next step** regardless of service. Lost and unsure also offer offline 112 practice, plus explicitly labelled real phone-app handoff when normal service and a usable contact are available. Practice never claims a connection.

Air-raid location choices distinguish outside without heard explosions from outside hearing explosions. Shelter steps accept inability to reach shelter or an unknown route; the unsure branch accepts no available adult. Their fallback says to follow official instructions and explicitly states that this practice cannot find a safe shelter route. It permits location reselection and optional adult support. This is an honest capability limit, not complete emergency guidance or a reviewed child protocol.

## Phone context and familiar places

Help independently uses foreground GPS with the existing location grant. It never opens another permission prompt, waits for GPS before showing instructions, records a track, or runs in the background. Leaving/backgrounding help cancels its GPS subscription; resuming requests a fresh fix. Map GPS remains paused while help owns its separate subscription.

The optional hint reads **“You may be near [name]. This is a saved place.”** It considers only named, non-demo family pins, with a position at most 30 seconds old, reported accuracy at most 25 m, and distance to the pin plus reported accuracy at most 50 m. It selects the nearest qualifying pin. Fictional startup Home and other demo pins are excluded. Missing permission, poor/stale GPS, unreadable family data or no matching pin simply omits the hint.

Proximity does not establish safety, an entrance, shelter access, being indoors, or another person's presence. It never chooses an emergency branch, directs the child to a saved pin, or skips the air-raid inside/outside question. Situation selection is always explicit.

## What phone actions actually do

- For the MVP showcase, tapping 112 opens a native Android demo dialog labelled as a pretend call. It never launches the dialler or places a call, including if the dialog fails to open.
- Trusted-adult actions appear only on lost/unsure instructions, with normal telephone service and at least one usable saved contact. They use `url_launcher` to hand a `tel:` URI to the real phone app after an explicit tap; the app does not automatically place calls. Emergency-only service does not enable these actions.
- Launcher success means only that the phone app opened. There is no answer detection, retry chain, emergency-service dispatch, or delivery tracking.
- Trusted contacts come from the adult-configured encrypted `FamilyPlanRepository`, shared with parent setup. Blank/unsupported numbers are filtered; USSD, URI injection, extensions and short emergency numbers are not accepted as trusted-contact numbers.
- Contact-load failures are reported separately from missing contacts. Help never edits or overwrites family records.
- Android's native service-state stream reports the default subscription as available, emergency-only, unavailable or unknown. It starts unknown, refreshes as reports arrive, stops when help backgrounds/exits, and is re-established on return. Unsupported devices, access restrictions and stream errors remain unknown; no new dangerous phone permissions are requested. Android 13+ registration excludes location data from this telephony callback.
- Devices without voice capability do not offer real contact calling. Offline pretend calls remain available.
- This is a telephone-service hint, not an internet/Wi-Fi check, signal-strength measurement, all-SIM assessment, or guarantee that a call can connect. An absent internet connection does not by itself establish that telephone calls are unavailable. Unknown service is not proof that emergency calling is impossible; the pretend-call action stays available in every service state. The callback's default-subscription behavior and service-state meanings are documented by [Android ServiceStateListener](https://developer.android.com/reference/android/telephony/TelephonyCallback.ServiceStateListener) and [Android ServiceState](https://developer.android.com/reference/android/telephony/ServiceState).
- **Background SMS is not implemented.** No SMS is sent or queued, and no screen says a parent was notified. Consent, Android permissions/platform feasibility, expiry, and stale-message handling remain unresolved.
- No phone action runs automatically on entry, navigation, or replay. Do not use this prototype to practise calling an emergency number.

## Source-to-content record

Primary pages fetched and read on 2026-10-03. English wording is a developer adaptation, **not a reviewed translation or validated child protocol**.

1. [Ministry of Health — Sposób postępowania na miejscu zdarzenia](https://www.gov.pl/web/zdrowie/sposob-postepowania-na-miejscu-zdarzenia): personal safety, calling 112 for an emergency, shouting for support, following medical dispatcher instructions. The prototype intentionally does not implement breathing assessment, CPR, recovery position, or complete first aid. **A no-signal unresponsive-person flow is incomplete and must not be presented as sufficient assistance.**
2. [Government safety guide — Atak z powietrza](https://www.gov.pl/web/poradnikbezpieczenstwa/atak-z-powietrza): previously agreed shelter route, stairs instead of lifts, lying down/covering the head after an explosion outdoors, not leaving shelter hastily. Guidance also recommends SMS rather than overloading telephone lines; the prototype does not offer routine parent voice calls in the air-raid flow. Its current demo policy also omits the 112 mock action throughout that branch.
3. [Government safety guide — Schronienia](https://www.gov.pl/web/poradnikbezpieczenstwa/schronienia): stay away from windows if a marked shelter is unavailable, and examples of outside shelter such as basements/underground passages. **The app does not verify shelter accessibility or safe routes.** The game’s fictional base and parent-entered practice places are never used as help destinations.
4. [Polish Police — Uwaga! Zaginęło dziecko](https://lodzka.policja.gov.pl/ld/informacje/75108,Uwaga-Zaginelo-dziecko.html): remain at the place where separated, do not leave with strangers, seek police or shop staff support. The danger exception is a cautious adaptation of the project’s own safety-first principle, not a complete evacuation protocol.
5. [112 — Jak zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/jak-zglaszac) and [Co zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/co-zglaszac): real emergency-service scope, operator-led reporting and avoiding false/practice calls.

The Android references above describe technical reports only; they do not validate the child-facing decision flow or real emergency eligibility.

## Before real-use release

Obtain qualified Polish emergency/first-aid and child-safeguarding review of the situation-first flow, shelter fallbacks and real contact service gating, validate the English wording with the target children (consider Polish for actual Polish users), complete medically appropriate no-service guidance, and evaluate real-device accessibility/dialler behaviour without placing emergency test calls. Ensure trusted-contact setup does not assume every caregiver is safe. Define the SMS capability and consent separately. Removing the prototype label alone is not sufficient.
