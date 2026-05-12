# Group Alert

**Originally created by Alektra <Lederhosen>**

[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20Me%20a%20Coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/shablagu)

Group Alert is a real-time group distance monitoring tool for the  
**Project Lazarus EverQuest EMU server**, built for **MacroQuest MQNext (MQ2Mono)**.

It continuously monitors group member distances from the group leader and provides
**high-visibility, center-screen alerts** when members become separated.

<img width="346" height="393" alt="image" src="https://github.com/user-attachments/assets/887d5402-eff9-4bf0-a20d-b924597911d1" />







---

## Features

### Core Monitoring
- Automatic distance checks (1–30 second interval)
- Live ImGui GUI with real-time updates

### Center-Screen Alerts
- Center-screen overlay
- Fully transparent background 
- Explicit RGBA text rendering
- **Red** alert when members exceed distance threshold
- **Green** all-clear when group returns within range
- Fires once per state transition
- Auto-clears when resolved
- Testable via GUI button

### Manual CoTH Control
- **Always-visible “Cast Call of the Heroes” button**
- Manual trigger only (no automation)
- Uses E3 group broadcast
- Independent of alert state
### E3 Follow Mode Broadcast
- **Three follow mode radio buttons** with a **Send** broadcast button:
  - **Nav** – /e3follow (navigation-based, may cut corners)
  - **Replay** – /e3follow replay nonav (replays exact player path)
  - **No Nav** – /e3follow nonav (disables stuck-nav feature)
- Broadcasts the selected mode to the group via /e3bcga
- Hidden when **Hide Buttons** compact mode is active

### Visual Interface
- Color-coded group member list:
  - Green: Within range
  - Red: Too far
  - Blue: Group leader
  - Gray: No coordinates
- Collapsible settings panel
- Deterministic, non-flaky UI behavior

### Persistent Settings
Saved automatically to `GroupAlert.ini`:
- Distance threshold
- Check interval
- Center-screen alert toggle
- Debug mode
- Overlay shadow offset (X/Y)
- Overlay-only font toggle and font size

---

## Requirements

- Project Lazarus EverQuest EMU
- MacroQuest **MQNext (MQ2Mono)**
- ImGui support

> **Note:** MQ2HUD and MQ2Alert are **not required** and are not used.

---

## Installation

1. Copy `group_alert.lua` into your MacroQuest `lua` directory
2. In game, run:
