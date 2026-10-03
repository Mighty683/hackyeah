# “I need help” — decision diagram

Updated: 2026-10-03. Documents the implemented Android help prototype.

**Unreviewed prototype. Not for real emergencies.** These diagrams describe the app's current decisions and actions, not a validated emergency or medical protocol. The helper-first sequence and phone-service conditions are MVP showcase policy. See [EMERGENCY_HELP.md](EMERGENCY_HELP.md) for limitations and review requirements.

## Helper and situation decisions

Rectangles are screens or actions. Diamonds are questions; the phone-service diamond is an automatic app condition, not a question shown to the child. Arrow labels identify the selected answer or action.

```mermaid
flowchart TD
    ENTRY["Tap I need help · prototype<br/>Welcome, startup/loading error, or map"]
    HELPERS{"Can someone nearby help you?"}
    CHECK{"Is a trusted adult or helper already nearby?"}
    ADULT["Tell that adult what happened.<br/>Do not leave with someone you do not know."]
    SITUATION{"What is happening?"}
    SERVICE{"App condition:<br/>normal or emergency-only phone service reported?"}
    CALL["Call 112 now.<br/>112 button opens a pretend-call dialog only."]
    OFFLINE["Shout for an adult's help.<br/>Do not approach a dangerous place.<br/>No complete first-aid instructions."]
    OPERATOR["Follow the emergency operator's instructions.<br/>Practice screen; no connected call is claimed."]
    AIR["Air-raid location question<br/>See the air-raid diagram below."]
    LOST["Stay here unless there is danger.<br/>Do not leave with someone you do not know."]
    UNSURE["Call out for an adult's help.<br/>You do not need to investigate what happened."]
    ACTIONS["Conditional phone buttons<br/>See the phone-action diagram below."]

    ENTRY --> HELPERS
    HELPERS -->|Yes| ADULT
    HELPERS -->|No one can help| SITUATION
    HELPERS -->|I'm not sure| CHECK
    CHECK -->|Someone can help| ADULT
    CHECK -->|No one can help| SITUATION
    ADULT -->|They cannot help| SITUATION
    SITUATION -->|Someone is not responding| SERVICE
    SERVICE -->|Yes| CALL
    SERVICE -->|Unknown or unavailable| OFFLINE
    CALL -->|Practise the next step| OPERATOR
    SITUATION -->|Air raid| AIR
    SITUATION -->|I am lost| LOST
    SITUATION -->|I don't know| UNSURE
    LOST --> ACTIONS
    UNSURE --> ACTIONS
```

The not-responding branch also follows the initial helper question. With unknown or unavailable service, its offline screen has neither a 112 button nor **Practise the next step**. Service changes update the current instruction and available actions without repeating the helper questions.

## Air-raid decisions

This branch has no phone buttons, shelter map or route calculation. The app asks the child where they are; GPS does not answer this question.

```mermaid
flowchart TD
    LOCATION{"Where are you now?"}
    INSIDE["Stay away from windows."]
    STAIRS["Use your agreed shelter route, if you know it.<br/>Use stairs, not lifts.<br/>The game's base is not a shelter."]
    OUTSIDE["Use nearby shelter if you can reach it.<br/>No verified shelter map."]
    EXPLOSIONS["Lie down and cover your head.<br/>Use a dip in the ground if within reach."]
    UNKNOWN["Ask a trusted adult to help you find shelter."]
    STAY["Stay in shelter and follow official instructions."]

    LOCATION -->|Inside a building| INSIDE
    LOCATION -->|Outside| OUTSIDE
    LOCATION -->|Outside, hearing explosions| EXPLOSIONS
    LOCATION -->|I don't know| UNKNOWN
    INSIDE -->|Read the shelter step| STAIRS
    STAIRS -->|I reached shelter| STAY
    OUTSIDE -->|I reached shelter| STAY
    UNKNOWN -->|I reached shelter| STAY
```

**I reached shelter** is the child's answer, not verified arrival. The explosion instruction has no subsequent scenario step; Back and the helper-return action remain available.

## Phone-action decisions

These conditions run automatically after no helper is confirmed. Offline instructions stay visible regardless of service. The buttons below are optional actions, not automatic calls or required next steps.

```mermaid
flowchart TD
    INSTRUCTION["Lost or I don't know instruction<br/>No helper confirmed"]
    SERVICE{"Reported phone service?"}
    CONTACTS{"At least one usable saved contact?"}
    BOTH["Show Call trusted adult<br/>and Call 112"]
    EMERGENCY["Show Call 112 only"]
    NONE["Hide phone buttons<br/>Keep offline instruction"]
    MOCK["Native pretend-call dialog<br/>No real 112 call or dialler launch"]
    COUNT{"One usable contact?"}
    PICK["Choose a trusted adult"]
    PHONE["Open real phone app with selected number<br/>Does not automatically place or confirm a call"]

    INSTRUCTION --> SERVICE
    SERVICE -->|Normal| CONTACTS
    SERVICE -->|Emergency-only| EMERGENCY
    SERVICE -->|Unknown or unavailable| NONE
    CONTACTS -->|Yes| BOTH
    CONTACTS -->|No| EMERGENCY
    BOTH -->|Tap Call 112| MOCK
    EMERGENCY -->|Tap Call 112| MOCK
    BOTH -->|Tap Call trusted adult| COUNT
    COUNT -->|Yes| PHONE
    COUNT -->|No: multiple contacts| PICK
    PICK -->|Select contact| PHONE
    PICK -->|Back to help| INSTRUCTION
```

- Not responding offers only the 112 mock action when service is normal or emergency-only. It never offers trusted-contact buttons.
- Helper questions, adult support, situation selection, air-raid screens and operator practice have no phone buttons.
- A failed mock dialog reports that no call was made. A failed phone-app launch reports the failure and keeps offline steps available. Neither triggers another action automatically.
- A contact-read error is shown separately from having no usable contacts. Neither enables the trusted-contact button.
- Service is an Android telephone-service report, not an internet check or guarantee that calls can connect. Unknown service does not prove emergency calling is impossible.

## Back, helper return and location context

- **Back** returns to the preceding help screen. Back from the first helper question closes help and restores its opener.
- **Someone can help now** appears after no helper is confirmed on screens with fewer than three scenario choices. It returns to **Tell that adult what happened**, clears the earlier no-helper history and removes phone actions. It is absent from the four-choice situation and air-raid location questions. Back from adult support returns to the initial helper question.
- Opening help from the map pauses map GPS and narration. Closing help restores the opener and requests a fresh map position when foreground; opening during map loading defers map creation until help closes.
- Help may show **You may be near [name]. This is a saved place.** This optional GPS hint never chooses a branch, proves safety or directs the child to a pin. Instructions do not wait for GPS.
- No SMS, automatic calls, call-answer detection, verified shelter routes or rescue dispatch are implemented.

## Implementation references

- [help_flow.dart](../mobile/lib/features/help/help_flow.dart): screen wording and scenario transitions.
- [help_screen.dart](../mobile/lib/features/help/help_screen.dart): history, helper reset, service-dependent instructions and button visibility.
- [help_phone.dart](../mobile/lib/features/help/help_phone.dart): service states, usable contacts, 112 mock and trusted-contact handoff.
- [SCREEN_FLOW.md](SCREEN_FLOW.md): application-wide navigation, including implemented and future flows.
