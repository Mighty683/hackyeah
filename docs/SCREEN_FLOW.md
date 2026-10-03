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

    W -->|I'm an adult| AL
    AL -->|Details loaded| A
    AL -->|Read failed| AE
    AE -->|Retry loading| AL
    AE -->|Delete all saved details| DEL
    W -->|I'm a child| F
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
    SE -->|Retry on the same form| A
    M -->|Map load failed| ME
    ME -->|Back| A
    A -->|Delete entry or all saved details| DEL
    DEL -->|Keep| A
    DEL -->|Delete: persist removal| A
    A -->|Play together| F
    A -->|Back| W
    F -->|Target selected or fictional fallback| L
    F -->|Read failed| FE
    FE -->|Try again| F
    L -->|Map loaded| G
    L -->|Map load failed| E
    G -->|Tap a map point: move character| G
    G -->|Reach target| R
    G -->|Start again: choose a new random target| F
    R -->|Play again: choose a new random target| F
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
    B -->|Child| W
    B -->|Adult| A
```

| Screen/state | One primary task | Secondary actions |
| --- | --- | --- |
| Welcome | Choose child or adult | None |
| Parent setup | Choose a setup task | Play together, confirmed Delete all, back |
| Child details | Edit optional child information | Save changes, back without saving |
| Trusted contact | Edit one of up to three contacts | Save changes, back without saving |
| Practice place | Name and position a practice pin | Tap or accessible centre/direction controls; save, back |
| Setup load error | Recover saved details | Retry, confirmed Delete all, back |
| Form save error | Retry saving without losing edits | Back without saving |
| Game target selection | Wait for saved places | Back |
| Game playing | Move the character to the practice target | Restart with a random target, demo information, back |
| Game result | Read the result and replay | Demo information, back |
| Game load error | Retry saved details or reopen the map | Back |
| Demo information | Read optional demo details | Close |

### Data and demo boundaries

- One child; optional full name, age, address and support notes. No photo feature.
- Up to three trusted contacts; name, phone and relationship are optional. Saving a number does not make calls or verify it.
- Parent-selected places are named geographic pins inside the bundled TAURON Arena area. They are not verified safe destinations, walking routes, or emergency instructions.
- Each game launch and replay chooses a random valid saved place. Repeats are possible. No places means the original fictional base.
- The family plan persists in `flutter_secure_storage` using Android encryption. Android cloud backup and device-transfer rules exclude app data. No sync, migration or restore is promised.
- Encryption is not a parent gate: anyone using this unlocked app can view the records. Recommend fictional personal details for demonstrations. **Delete all saved details** removes this feature's child/contact/place record after confirmation; it does not silently reset failed reads.
- Keep map attribution visible. Preserve the distinction between real geography and simulated movement. Emergency decision scenarios and real emergency assistance are not part of this parent-setup slice.

## Proposed future product flow — not implemented

Dashed arrows describe future work. Keep adult configuration separate from child training. Online area selection, multi-device sharing and protected parent access are not available in this demo.

```mermaid
flowchart TD
    W["WELCOME<br/>Adult or child?"]
    A["PARENT SETUP"]
    MAP["PLANNED: choose an area on an online map"]
    V["PLANNED: review and confirm family-plan changes"]

    subgraph CHILD["PLANNED: child training"]
        H["Child start<br/>Start practice"]
        T["Situation<br/>One concrete event"]
        D["Decision<br/>2–4 plausible action choices"]
        X["Action<br/>Show the chosen action"]
        F["Consequence and explanation<br/>What happened and why"]
        N{"Scenario complete?"}
        R["Result<br/>One thing learned"]
    end

    subgraph HELP["FUTURE ONLY: help outside the game"]
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

The future help entry must be reachable without completing onboarding. It must use different styling from training, omit scores and entertainment, and follow authoritative situation-specific guidance. This diagram defines navigation, not emergency procedures. Help is absent from this Android branch; the pitch includes a simulated preview that does not assess danger or make calls.

## Keeping this reference useful

Update the implemented graph when a screen, action or return path changes. Promote future nodes only when their behavior works. Concurrent map/help branches must reconcile their implemented flows at integration. Use [UX.md](UX.md) for product principles and [UX_REVIEW.md](UX_REVIEW.md) for the earlier simplification review.
