# “I need help” — decision diagram

Updated: 2026-10-04. Android and the browser demo share this flow.

**Feature in preparation. Not for real emergencies.**

```mermaid
flowchart TD
    ENTRY["Tap I need help · prototype"] --> SITUATION{"What is happening?"}
    SITUATION -->|Someone is not responding| GUIDE["Interactive guide placeholder<br/>A future guide will show children what to do step by step"]
    SITUATION -->|Hear a siren| GUIDE
    SITUATION -->|Lost| GUIDE
    SITUATION -->|Unsure| GUIDE
    GUIDE -->|Wróć do wyboru scenariusza or Back| SITUATION
    SITUATION -->|Close| OPENER["Restore the screen that opened help"]
```

The guide is not implemented. The help screen has no emergency instructions, phone actions, contact loading or GPS. See [EMERGENCY_HELP.md](EMERGENCY_HELP.md) and [SCREEN_FLOW.md](SCREEN_FLOW.md).
