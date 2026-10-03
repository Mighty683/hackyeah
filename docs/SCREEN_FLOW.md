# Basebound screen and action reference

Updated: 2026-10-03. Android is the application; the Slidev screens are pitch prototypes.

## Implemented Android flow

Solid arrows describe working navigation and actions. Loading, result and error are screen states. Role selection changes the journey; it is not age verification or access control. Parent setup is freely accessible in this demo.

```mermaid
flowchart TD
    W["WELCOME<br/>Are you an adult or a child?"]
    A["PARENT SETUP<br/>Child details, up to 3 contacts, practice places"]
    AL["SETUP: LOADING<br/>Read the encrypted local family plan"]
    AE["SETUP: LOAD ERROR<br/>Retry or explicitly delete saved details"]
    C["CHILD DETAILS<br/>Optional name, age, address, support needs"]
    T["TRUSTED CONTACT<br/>Optional name, phone, relationship"]
    M["PRACTICE PLACE<br/>Optional name; choose a pin on the offline map"]
    ME["PLACE: MAP ERROR<br/>Go back and try again"]
    SE["FORM: SAVE ERROR<br/>Keep edits and retry"]
    DEL["DELETE CONFIRMATION<br/>Delete entry or all saved details"]
    F["GAME: SELECT TARGET<br/>Read saved places; randomly choose a valid pin<br/>No places: use the fictional base"]
    FE["GAME: SAVED DETAILS ERROR<br/>Retry or go back"]
    L["GAME: LOADING<br/>Load the offline map"]
    G["GAME: PLAYING<br/>Reach the named practice place or pretend base<br/>Tap the map to move your character"]
    R["GAME: RESULT<br/>You reached the practice target"]
    E["GAME: MAP ERROR<br/>Go back and try again"]
    I["ABOUT THIS DEMO<br/>Practice-only movement and map credits"]
    H["HELP PROTOTYPE<br/>Unreviewed; not for real emergencies<br/>3 situations + I don't know"]
    Q["OFFLINE HELP STEP<br/>One question or instruction<br/>112 dialler always available"]
    D["PHONE APP<br/>Explicit child tap; no automatic call or SMS"]

    W -->|I need help: bypass role selection| H
    F -->|I need help: defer game creation| H
    FE -->|I need help| H
    L -->|I need help: pause game| H
    G -->|I need help: pause game| H
    R -->|I need help: pause game| H
    E -->|I need help: pause game| H
    H -->|Select situation| Q
    Q -->|Answer or next instruction| Q
    Q -->|Back: previous instruction| Q
    Q -->|Back from first step| H
    H -->|Close: restore opener and prior pause state| HP{"Help opened by"}
    HP -->|Welcome| W
    HP -->|Target selection| F
    HP -->|Saved-details error| FE
    HP -->|Map loading| L
    HP -->|Playing| G
    HP -->|Result| R
    HP -->|Map error| E
    H -->|Open 112 dialler| D
    Q -->|Explicit 112 or saved trusted-contact action| D
    D -->|Return: no connection assumed| DP{"Previous help screen"}
    DP -->|Situation selector| H
    DP -->|Instruction| Q
    W -->|I'm an adult| AL
    AL -->|Details loaded| A
    AL -->|Read failed| AE
    AE -->|Retry loading| AL
    AE -->|Delete all saved details| DEL
    W -->|I'm a child| PS["PRACTICE SELECTION<br/>Alarm practice or map practice"]
    PS -->|Map practice| F
    PS -->|Alarm practice: ages 7+| MODE["CHOOSE SCENE<br/>At home or outside"]
    MODE -->|At home| HOME["HOME ALARM TUTORIAL"]
    MODE -->|Outside| OUT["OUTDOOR ALARM SIMULATION"]
    HOME --> MR["MISSION RECALL<br/>Completion sticker; no score"]
    OUT --> MR
    MR -->|Replay| RE{"Selected mission mode"}
    RE -->|Home| HOME
    RE -->|Outside| OUT
    HOME -->|Back| PS
    OUT -->|Back| PS
    MR -->|Choose practice| PS
    PS -->|Back| B
    A -->|Edit child details| C
    A -->|Add or edit contact| T
    A -->|Add or edit practice place| M
    C -->|Save changes| A
    T -->|Save changes| A
    M -->|Save changes after choosing a position| A
    C -->|Back: discard unsaved edits| A
    T -->|Back: discard unsaved edits| A
    M -->|Back: discard unsaved edits| A
    C -->|Save failed| SE
    T -->|Save failed| SE
    M -->|Save failed| SE
    SE -->|Retry successfully on the same form| A
    M -->|Map load failed| ME
    ME -->|Back| A
    A -->|Delete entry or all saved details| DEL
    DEL -->|Keep| A
    DEL -->|Delete: persist removal| A
    A -->|Play together| PS
    A -->|Back| W
    F -->|Target selected or fictional fallback| L
    F -->|Read failed| FE
    FE -->|Try again| F
    L -->|Map loaded| G
    L -->|Map load failed| E
    G -->|Tap a map point: move character| G
    G -->|Drag: pan; pinch or zoom buttons: zoom 1–4×| G
    G -->|Show whole map: restore full source area| G
    G -->|Reach target| R
    G -->|Start again: random target, reset character and overview| F
    R -->|Drag, pinch or zoom buttons: explore without moving character| R
    R -->|Show whole map: restore full source area| R
    R -->|Play again: random target, reset character and overview| F
    G -->|About this demo| I
    R -->|About this demo| I
    I -->|Close| P{"Previous game state"}
    P -->|Playing| G
    P -->|Result| R
    F -->|Back| B{"Opened by"}
    FE -->|Back| B
    L -->|Back| B
    G -->|Back| B
    R -->|Back| B
    E -->|Back| B
    B -->|Map game| PS
    B -->|Practice opened by child| W
    B -->|Practice opened by adult| A
```

| Screen/state | One primary task | Secondary actions |
| --- | --- | --- |
| Welcome | Choose child or adult | Help prototype, without choosing a role |
| Practice selection | Choose alarm or map practice | Replay audio, back |
| Mission mode (7+) | Choose home or outside | Replay audio, choose practice |
| Mission scene | Make one visual decision or hear the situation | Replay audio, back |
| Mission feedback | See the consequence and explanation | Retry the same decision or advance; replay audio |
| Mission recall | See the six learned actions and completion sticker | Replay audio, replay mission, choose practice |
| Parent setup | Choose a setup task | Play together, confirmed Delete all, back |
| Child details | Edit optional child information | Save changes, back without saving |
| Trusted contact | Edit one of up to three contacts | Save changes, back without saving |
| Practice place | Name and position a practice pin | Tap or accessible centre/direction controls; save, back |
| Setup load error | Recover saved details | Retry, confirmed Delete all, back |
| Form save error | Retry saving without losing edits | Back without saving |
| Game target selection/error | Wait for saved places or retry | Help prototype, back |
| Game map loading | Wait for the offline map | Help prototype, back |
| Game playing | Move the character to the practice target | Help prototype, pan/zoom, show whole map, restart with a random target, demo information, back |
| Game result | Read the result and replay | Help prototype, pan/zoom, show whole map, demo information, back |
| Game load error | Retry saved details or reopen the map | Help prototype, back |
| Demo information | Read optional demo details | Close |
| Help prototype entry | Choose not responding, air raid, lost, or unsure | Open 112 dialler, no-signal information, close |
| Help step | Answer one question or read one instruction | Previous step, 112 dialler, trusted-contact dialler where offered |

Help content is bundled. Phone-app launch is real, but no call, connection, rescue, SMS delivery or verified route is inferred. Not-responding skips parent contact and offers 112 immediately. The air-raid flow does not offer routine parent voice calls. No-signal medical guidance is incomplete. See [EMERGENCY_HELP.md](EMERGENCY_HELP.md) for sources and the review required before real use. Adult setup configures contacts; help only reads its encrypted local record. Opening help during target selection defers creation of the game until help closes.

### Mission 01 — air-raid alarm practice

The home tutorial practices alarm recognition, moving away from windows, choosing an interior hallway, messaging a fictional trusted adult, staying after a noise, waiting through silence, and following an explicit all-clear. The premise is a fallback when the agreed shelter cannot be reached. An interior area and two walls offer some protection; the game does not certify a home as safe.

The MVP targets children aged 7+ with two to four choices and optional fictional outdoor practice: compare nearby shelter against distant destinations and exposed places. There is no younger-child branch or age-selection screen; saved age does not change this mission. An outdoor mistake leads to getting down (drag or tap), protecting the head, and moving to shelter. Home mistakes explain the consequence and retry without punishment. Both modes finish with a visual recall and completion sticker, with no score or timer.

Instructions, feedback, and replay use an installed offline English Android speech voice. If unavailable, the app shows an adult-help message; text remains as a fallback. Short warning and all-clear playback excerpts are teaching samples, not complete alarm signals. Contacts, messages, replies, shelter selection and movement are fictional; this mission neither calls nor sends messages nor uses saved personal contacts or map pins. See [mission-01-air-raid-alarm.md](mission-01-air-raid-alarm.md) for the scenario and source notes.

### Visual design system

The implemented screens share rounded Nunito typography, navy text, blue actions and white panels. Training uses warm or sky-tinted backdrops, a decorative green guide and bundled fictional room/hallway illustrations. Parent setup uses calmer form panels. Help retains a distinct flat cool theme and visible prototype notice. The visual redesign preserves all screen actions and return paths described above; see [UI_IMPLEMENTATION_PLAN.md](UI_IMPLEMENTATION_PLAN.md) for shared components and parallel ownership.

### Child map interaction

The parent pin editor shows accurate bundled OSM geometry; the child view is deliberately schematic. The square overview covers the same geographic extent as the offline source, but minor streets/buildings/POIs are omitted. Decorative trees and illustrated buildings are not exact real-world positions or outlines. Dragging or pinching explores without selecting a movement destination; only a resolved tap moves the character. Zoom buttons and Show whole map are secondary controls, disabled while loading or after a load error. Instructions and attribution stay outside scrolling areas. Only secondary controls can scroll; the map has its own gesture area. Short or large-text layouts use a shorter instruction, and landscape places the map beside instructions and controls. Water, energy and warmth cards remain removed. There is one restart control in each loaded game state. Restart/replay reloads the saved places, selects a fresh random target, and resets character and overview; repeats are possible.

### Data and demo boundaries

- One child; optional full name, age, address and support notes. No photo feature.
- Up to three trusted contacts; name, phone and relationship are optional. Saving a number does not make calls or verify it.
- Parent-selected places are named geographic pins inside the bundled TAURON Arena area. They are not verified safe destinations, walking routes, or emergency instructions.
- Each game launch and replay chooses a random valid saved place. Repeats are possible. No places means the original fictional base.
- The family plan persists in `flutter_secure_storage` using Android encryption. Android cloud backup and device-transfer rules exclude app data. No sync, migration or restore is promised.
- Encryption is not a parent gate: anyone using this unlocked app can view the records. Recommend fictional personal details for demonstrations. **Delete all saved details** removes this feature's child/contact/place record after confirmation; it does not silently reset failed reads.
- Keep map attribution visible. Preserve the distinction between real geography and simulated movement. Mission 01 implements fictional alarm decision training; validated real emergency assistance remains unimplemented. The separate help prototype is unreviewed.

## Proposed future product flow — not implemented

Dashed arrows describe future work. Keep adult configuration separate from child training. Online area selection, multi-device sharing and protected parent access are not available in this demo.

```mermaid
flowchart TD
    W["WELCOME<br/>Adult or child?"]
    A["PARENT SETUP"]
    MAP["PLANNED: choose an area on an online map"]
    V["PLANNED: review and confirm family-plan changes"]

    subgraph CHILD["PLANNED: additional child training missions"]
        H["Child start<br/>Start practice"]
        T["Situation<br/>One concrete event"]
        D["Decision<br/>2–4 plausible action choices"]
        X["Action<br/>Show the chosen action"]
        F["Consequence and explanation<br/>What happened and why"]
        N{"Scenario complete?"}
        R["Result<br/>One thing learned"]
    end

    subgraph HELP["FUTURE ONLY: reviewed real-help release"]
        Q["What is happening?<br/>Include an unsure option"]
        O["One actionable instruction<br/>Reviewed official guidance"]
        K["Contact trusted adult or emergency services<br/>When appropriate for the situation"]
    end

    A -.->|Choose a different area| MAP
    MAP -.->|Review places| V
    W -.->|I'm a child| H
    H -.->|Start practice| T
    T -.->|Present the decision| D
    D -.->|Choose an action| X
    X -.->|Show the outcome| F
    F -.->|Read the brief explanation| N
    N -.->|Another situation| T
    N -.->|Finished| R
    R -.->|Practice again| T
    R -.->|Child start| H
    H -.->|Change role| W
    W -.->|I need help: bypass role selection| Q
    H -.->|I need help: leave training| Q
    T -.->|I need help: leave training| Q
    D -.->|I need help: leave training| Q
    Q -.->|Select situation| O
    O -.->|Situation requires contact| K
    O -.->|Next reviewed step| O
```

The future help entry must be reachable without completing onboarding. It must use different styling from training, omit scores and entertainment, and follow authoritative situation-specific guidance. This diagram defines navigation, not emergency procedures. Android now has an explicitly unreviewed help prototype, not released real assistance. The pitch still includes a simulated preview that does not assess danger or make calls.

Full reviewed emergency procedures, background messaging, walking mode, real navigation and validated real assistance remain future work. The implemented prototype is not a promotion of the future reviewed-help graph.

## Keeping this reference useful

Update the implemented graph when a screen, action or return path changes. Promote future nodes only when their behavior works. Concurrent map/help branches must reconcile their implemented flows at integration. Use [UX.md](UX.md) for product principles and [UX_REVIEW.md](UX_REVIEW.md) for the earlier simplification review.
