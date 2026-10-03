# Basebound screen and action reference

Updated: 2026-10-03. Android is the application; the Slidev screens are pitch prototypes.

## Implemented Android flow

Solid arrows describe working navigation or game actions. Result, loading and error are states of the game screen. “Back” returns to the screen that opened the game. Role selection changes the journey; it is not age verification or access control.

```mermaid
flowchart TD
    W["WELCOME<br/>Are you an adult or a child?"]
    A["ADULT INTRODUCTION<br/>Explore together<br/>Practice game; not real-world navigation"]
    L["GAME: LOADING<br/>Load the offline map"]
    G["GAME: PLAYING<br/>Reach the pretend base<br/>Tap the map to move your character"]
    R["GAME: RESULT<br/>You reached the base!<br/>You guided your character to the base"]
    E["GAME: LOAD ERROR<br/>Go back and try again"]
    I["ABOUT THIS DEMO<br/>Pretend base, free movement and map credits"]

    W -->|I'm a child| L
    W -->|I'm an adult| A
    A -->|Play together| L
    A -->|Back| W
    L -->|Map loaded| G
    L -->|Map failed to load| E
    G -->|Tap a map point: move character| G
    G -->|Drag: pan; pinch or zoom buttons: zoom 1–4×| G
    G -->|Show whole map: restore full source area| G
    G -->|Reach the base| R
    G -->|Start again: reset position and whole map| G
    R -->|Drag, pinch or zoom buttons: explore without moving character| R
    R -->|Show whole map: restore full source area| R
    R -->|Play again: reset position and whole map| G
    G -->|About this demo| I
    R -->|About this demo| I
    I -->|Close: return to previous game state| P{"Previous game state"}
    P -->|Playing| G
    P -->|Result| R
    L -->|Back| B{"Opened by"}
    G -->|Back| B
    R -->|Back| B
    E -->|Back| B
    B -->|Child| W
    B -->|Adult| A
```

| Screen/state | One primary task | Secondary actions |
| --- | --- | --- |
| Welcome | Choose child or adult | None |
| Adult introduction | Start playing together | Back to welcome |
| Game loading | Wait for the map | Back |
| Game playing | Move the character to the pretend base | Pan/zoom, show whole map, restart, demo information, back |
| Game result | Read the result and replay | Pan/zoom, show whole map, demo information, back |
| Game load error | Return and reopen the game | Back |
| Demo information | Read optional demo details | Close |

Keep the map attribution visible. The square overview covers the same geographic extent as the offline source. The child view is deliberately schematic: broad park/water shapes, a few main roads and illustrated landmarks instead of a dense street map. Minor streets/buildings/POIs are omitted, and secondary labels appear only when space permits. Decorative trees and illustrated buildings are not exact real-world positions or outlines. Dragging or pinching explores the map without selecting a movement destination; only a resolved tap moves the character. Zoom buttons and Show whole map are secondary controls, disabled while loading or after a load error. Instructions and attribution stay outside scrolling areas. Only secondary controls can scroll; the map has its own gesture area. Short or large-text layouts use a shorter instruction, and landscape places the map beside the instructions and controls. Water, energy and warmth cards are removed because they do not affect this demo. There is one restart control in each loaded game state. Detailed geography and licensing information live in the information dialog.

## Proposed future product flow — not implemented

Dashed arrows describe future work, not features available in Android. Keep adult setup separate from child play. Each adult setup screen asks for one piece of information. Do not add a dashboard to the welcome screen.

```mermaid
flowchart TD
    W["WELCOME<br/>Adult or child?"]

    subgraph ADULT["PLANNED: adult setup"]
        A["Choose setup task<br/>Contact or meeting place"]
        C["Add trusted adult contact"]
        M["Choose agreed meeting place"]
        V["Review this change"]
        S["Save confirmed change"]
    end

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

    W -.->|I'm an adult| A
    W -.->|I'm a child| H
    A -.->|Edit contact| C
    A -.->|Edit meeting place| M
    C -.->|Review contact| V
    M -.->|Review place| V
    V -.->|Edit again| A
    V -.->|Confirm| S
    S -.->|Choose another task| A
    A -.->|Back| W
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

The future help entry must be reachable without completing onboarding. It must use different styling from training, omit scores and entertainment, and follow situation-specific guidance from authoritative sources. This diagram defines navigation, not emergency procedures. Help is absent from Android today; the pitch includes a simulated preview that does not assess danger or make calls.

The first implementation slice is the solid-arrow Android flow. Family-plan storage, branching emergency scenarios, walking mode, real navigation and real assistance remain future work.

## Keeping this reference useful

Update the implemented graph when a screen, action or return path changes. Promote future nodes only when their behavior works. Use [UX.md](UX.md) for product principles and [UX_REVIEW.md](UX_REVIEW.md) for the review behind this simplification.
