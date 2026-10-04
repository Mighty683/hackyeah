# “I need help” — decision diagram

Updated: 2026-10-04. Documents the implemented Android help prototype.

**Unreviewed prototype. Not for real emergencies.** This is not a validated emergency or medical protocol. See [EMERGENCY_HELP.md](EMERGENCY_HELP.md).

## Situation and helper decisions

Help opens directly on four situation choices. Adult support is optional on instruction screens, including shelter steps. It preserves the current scenario; **They cannot help** or Back returns to that instruction. It is absent from situation and air-location selection to keep those questions focused.

```mermaid
flowchart TD
    ENTRY["Tap I need help · prototype"] --> SITUATION{"What is happening?"}
    SITUATION -->|Someone is not responding| CALL["Practise calling 112"]
    CALL -->|Practise the next step| OPERATOR["Follow the emergency operator's instructions"]
    SITUATION -->|Air raid| AIR["Where are you now?"]
    SITUATION -->|I am lost| LOST["Stay here unless there is danger"]
    SITUATION -->|I don't know| UNSURE["Call out for an adult's help"]
    INSTRUCTION["Any scenario instruction"] -->|A trusted adult is here| ADULT["Tell that adult what happened"]
    ADULT -->|They cannot help or Back| INSTRUCTION
```

Practice calling and operator practice work with unknown or unavailable service. No call connection is claimed. The unresponsive-person content remains incomplete first aid.

## Air-raid decisions

No phone actions, shelter map or route calculation. GPS never answers the location question.

```mermaid
flowchart TD
    LOCATION{"Where are you now?"}
    LOCATION -->|Inside a building| INSIDE["Stay away from windows"]
    LOCATION -->|Outside, no explosions heard| OUTSIDE["Use nearby shelter if you can reach it"]
    LOCATION -->|Outside, hearing explosions| EXPLOSIONS["Lie down and cover your head"]
    LOCATION -->|I don't know| UNKNOWN["Ask a trusted adult to help you find shelter"]
    INSIDE -->|Read the shelter step| STAIRS["Use your agreed shelter route, if you know it; use stairs"]
    STAIRS -->|I reached shelter| STAY["Stay in shelter and follow official instructions"]
    OUTSIDE -->|I reached shelter| STAY
    UNKNOWN -->|I reached shelter| STAY
    STAIRS -->|I don't know the way / I can't reach shelter| BLOCKED["Follow official instructions; this practice cannot find a safe shelter route"]
    OUTSIDE -->|I can't reach shelter| BLOCKED
    UNKNOWN -->|No adult can help| BLOCKED
    BLOCKED -->|Choose my location again| LOCATION
```

The fallback exposes the app's limit, not a new evacuation protocol or verified route. Adult support remains optional there. **I reached shelter** is self-reported. The explosion instruction retains Back and adult support; it does not imply that danger has ended.

## Phone actions

```mermaid
flowchart TD
    INSTRUCTION["Not responding, lost or unsure"] --> PRACTICE["Practise calling 112 · always available offline"]
    PRACTICE -->|Explicit tap| MOCK["Pretend-call dialog; no real call or dialler"]
    LOST["Lost or unsure"] --> SERVICE{"Normal telephone service and usable saved contacts?"}
    SERVICE -->|Yes| CONTACT["Open phone to call an adult"]
    SERVICE -->|No| OFFLINE["Keep offline instruction and 112 practice"]
    CONTACT --> COUNT{"One contact?"}
    COUNT -->|Yes| PHONE["Open real phone app; no automatic call"]
    COUNT -->|No| PICK["Open phone to call… choose an adult"]
    PICK -->|Select| PHONE
    PICK -->|Cancel| LOST
```

- Emergency-only, unknown and unavailable service hide real trusted-contact actions, never practice.
- Real contact actions are Android-only; web demo phone actions remain pretend.
- Helper, air-raid, situation and operator screens have no phone actions.
- Dialog/phone-launch failures are reported without triggering another action.
- Contact-read errors are distinct from no saved contacts.
- Telephone reports do not prove whether a call will connect.

## Back and location context

- Back follows history; Back from situation selection closes help and restores its opener.
- Adult support preserves the exact preceding instruction and removes phone actions while open.
- Help pauses map GPS and narration; closing requests a fresh map position when foreground. Map creation is deferred if help opens during loading.
- Optional **You may be near [name]. This is a saved place.** never chooses a branch or proves safety.
- No automatic calls, SMS, call-answer detection, verified shelter routes or dispatch.

## Implementation references

- [help_flow.dart](../mobile/lib/features/help/help_flow.dart): wording and transitions.
- [help_screen.dart](../mobile/lib/features/help/help_screen.dart): history and action visibility.
- [help_phone.dart](../mobile/lib/features/help/help_phone.dart): service, contacts and phone handoff.
- [SCREEN_FLOW.md](SCREEN_FLOW.md): implemented and future application flows.
