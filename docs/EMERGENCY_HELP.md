# Emergency-help prototype

This is an **unreviewed prototype, not for real emergencies**. The UI states this at entry and on its help screens. Do not make test calls to 112. No clinical/safeguarding reviewer has been identified, and no child comprehension study has been performed.

## Implemented scope

The separate help screen is reachable from welcome without role selection, and from every game state (including loading/error/result). Opening it pauses the Flame engine; closing it restores its previous paused/running state. During saved-target loading/error, help remains available and defers creation of the game until help closes. Game help uses a labelled app-bar icon so the schematic map retains its space at enlarged text sizes. A static shared mascot and blue-grey styling distinguish help from green game UI. No scores, countdowns, sirens, entertainment animations, forced speech, or claims that someone is monitoring the child.

All content is bundled and works without internet or telephone service. Exactly three situations are offered, plus an uncertainty fallback:

| Situation | Initial behaviour | Subsequent orientation |
| --- | --- | --- |
| Someone is not responding | Show “Call 112 now” immediately; no parent-call prerequisite | Child can select no phone signal or confirm that their call connected; offline page asks for an adult’s help, connected page defers to the operator |
| Air raid | Ask inside/outside/explosions outside/unsure | Window/shelter guidance, outside explosion guidance, or seeking trusted-adult support; no shelter map or navigation |
| Lost/separated | Ask whether a trusted adult is present | Stay unless there is danger, identify already-nearby police/shop staff, and offer trusted-contact dialling |
| I don’t know | Ask a trusted adult nearby for help | No diagnosis, hazard investigation, or invented severity score |

The 112 action remains available on every step without completing questions. “Urgent help” indicates that it is for an immediate emergency, not a routine air-raid notification. This is fixed orientation content, **not automated medical triage**. “The call connected” is the child's explicit answer, never an app inference.

## What phone actions actually do

- A child must tap a clearly labelled action. `url_launcher` hands a `tel:` URI to the phone app; the app does not automatically place calls.
- Launcher success means only that the phone app opened. There is no answer detection, retry chain, emergency-service dispatch, or delivery tracking.
- Trusted contacts come from the adult-configured encrypted `FamilyPlanRepository`, shared with parent setup. Blank/unsupported numbers are filtered; USSD, URI injection, extensions and short emergency numbers are not accepted as trusted-contact numbers.
- Contact-load failures are reported separately from missing contacts. Help never edits or overwrites family records.
- Calls need telephone service. An absent internet connection alone does not establish that telephone calls are unavailable. The app does not detect network availability; “No phone signal” is child-reported and never disables access to the dialler.
- **Background SMS is not implemented.** No SMS is sent or queued, and no screen says a parent was notified. Consent, Android permissions/platform feasibility, expiry, and stale-message handling remain unresolved.
- No phone action runs automatically on entry, navigation, or replay. Do not use this prototype to practise calling an emergency number.

## Source-to-content record

Primary pages fetched and read on 2026-10-03. English wording is a developer adaptation, **not a reviewed translation or validated child protocol**.

1. [Ministry of Health — Sposób postępowania na miejscu zdarzenia](https://www.gov.pl/web/zdrowie/sposob-postepowania-na-miejscu-zdarzenia): personal safety, calling 112 for an emergency, shouting for support, following medical dispatcher instructions. The prototype intentionally does not implement breathing assessment, CPR, recovery position, or complete first aid. **A no-signal unresponsive-person flow is incomplete and must not be presented as sufficient assistance.**
2. [Government safety guide — Atak z powietrza](https://www.gov.pl/web/poradnikbezpieczenstwa/atak-z-powietrza): previously agreed shelter route, stairs instead of lifts, lying down/covering the head after an explosion outdoors, not leaving shelter hastily. Guidance also recommends SMS rather than overloading telephone lines; the prototype therefore does not offer routine parent voice calls in the air-raid flow. A genuine immediate emergency can still access 112.
3. [Government safety guide — Schronienia](https://www.gov.pl/web/poradnikbezpieczenstwa/schronienia): stay away from windows if a marked shelter is unavailable, and examples of outside shelter such as basements/underground passages. **The app does not verify shelter accessibility or safe routes.** The game’s fictional base and parent-entered practice places are never used as help destinations.
4. [Polish Police — Uwaga! Zaginęło dziecko](https://lodzka.policja.gov.pl/ld/informacje/75108,Uwaga-Zaginelo-dziecko.html): remain at the place where separated, do not leave with strangers, seek police or shop staff support. The danger exception is a cautious adaptation of the project’s own safety-first principle, not a complete evacuation protocol.
5. [112 — Jak zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/jak-zglaszac) and [Co zgłaszać?](https://www.gov.pl/web/numer-alarmowy-112/co-zglaszac): real emergency-service scope, operator-led reporting and avoiding false/practice calls.

## Before real-use release

Obtain qualified Polish emergency/first-aid and child-safeguarding review, validate the English wording with the target children (consider Polish for actual Polish users), complete medically appropriate no-service guidance, and evaluate real-device accessibility/dialler behaviour without placing emergency test calls. Ensure trusted-contact setup does not assume every caregiver is safe. Define the SMS capability and consent separately. Removing the prototype label alone is not sufficient.
