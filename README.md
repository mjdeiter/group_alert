# Group Alert

**Originally created by Alektra <Lederhosen>**

Group Alert is a real-time group distance monitoring tool for the  
**Project Lazarus EverQuest EMU server**, built for **MacroQuest MQNext (MQ2Mono)**.

It continuously monitors group member distances from the group leader and provides
**high-visibility, center-screen alerts** when members become separated.

---

## Features

### Core Monitoring
- Automatic distance checks (1–30 second interval)
- Live ImGui GUI with real-time updates
- Manual distance checks on demand
- EMU-safe group indexing (0-based and 1-based compatibility)

### Center-Screen Alerts (v2.3.10)
- Large ImGui overlay alerts
- **Fluorescent green text with black outline**
- Fires once per event (no spam)
- Auto-clears when resolved
- Testable via GUI button

### Manual CoTH Control
- **Always-visible “Cast Call of the Heroes” button**
- Manual trigger only (no automation)
- Uses E3 group broadcast
- Independent of alert state

### Visual Interface
- Color-coded group member list:
  - Green: Within range
  - Red: Too far
  - Blue: Group leader
  - Gray: No coordinates
- Collapsible settings panel
- Deterministic, non-flaky UI behavior

---

## Requirements

- Project Lazarus EverQuest EMU
- MacroQuest **MQNext (MQ2Mono)**
- ImGui support

> **Note:** MQ2HUD and MQ2Alert are **not required** and are no longer used.

---

## Installation

1. Copy `group_alert.lua` into your MacroQuest `lua` directory
2. In game, run:
   ```
   /lua run group_alert
   ```
3. The GUI will open automatically

---

## Usage

### Button Row
```
[ Manual Check ] [ Cast Call of the Heroes ] [ Exit Script ]
```

- **Manual Check** – Forces an immediate distance evaluation
- **Cast Call of the Heroes** – Manually request CoTH from an available Mage
- **Exit Script** – Fully terminates the script

---

## Commands

```
/groupalert check
/groupalert threshold <value>
/groupalert interval <seconds>
/groupalert status
/groupalert gui
/groupalert exit
```

---

## Alert Behavior

- Alerts trigger once when a member exceeds the threshold
- No repeated spam while condition persists
- Clear alert fires when group returns within range

---

## Window Behavior

- **X button**: hides the window, monitoring continues
- **Exit Script**: terminates the script completely
- `/groupalert gui`: reopen hidden window

---

## Configuration Guidance

### Distance Threshold
- 200–300: Tight formations (dungeons)
- 500: Default
- 1000+: Open-world travel

### Check Interval
- 1–3 seconds: High alertness
- 5 seconds: Default
- 10–30 seconds: Low overhead

---

## Debug Logging

When Debug Mode is enabled, logs are written to `group_alert_log.txt`.

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for full version history.

---

## Current Version

**v2.3.10**

---

## License

Provided as-is for use on the Project Lazarus EverQuest EMU server.
