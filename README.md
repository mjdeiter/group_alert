[![Support](https://img.shields.io/badge/Support-Buy%20Me%20a%20Coffee-6f4e37)](https://buymeacoffee.com/shablagu)

# Group Alert (Project Lazarus)

A controller-driven group distance monitoring script for the Project Lazarus EverQuest EMU server.

---

## Credits
**Created by:** Alektra  
**For:** Project Lazarus EverQuest EMU Server  
**Support:** https://buymeacoffee.com/shablagu

---

## Description
Group Alert provides at-a-glance awareness when group members drift too far from the group leader.

The script runs on **one designated controller character only** and monitors the 3D distance between the group leader and each group member. When any member exceeds a configurable distance threshold, clear alerts are raised via the MacroQuest console and, optionally, MQ2HUD.

The design intentionally avoids running scripts on every toon and favors predictable, low-overhead monitoring aligned with Project Lazarus scripting constraints.

---

## Key Features
- **Controller-only execution**  
  Runs on a single character; no remote polling or per-toon scripts.

- **Distance-based alerts**  
  Configurable 3D distance threshold between leader and members.

- **Console and HUD notifications**  
  - Red console alerts when members are out of range  
  - Optional MQ2HUD integration displaying a persistent “GROUP ALERT” line

- **Alert state tracking**  
  “All clear” messages are only printed when transitioning from alert to safe state.

- **Timestamped logging**  
  Writes diagnostic and alert data to a log file for review and troubleshooting.

- **Safe MacroQuest variable handling**  
  Verifies and initializes required MQ variables before use:
  - `groupAlert`
  - `groupAlertMembers`

---

## Requirements
- Project Lazarus (or compatible EverQuest EMU server)
- MacroQuest MQNext (MQ2Mono)
- E3Next
- MQ2HUD plugin (optional but recommended)
- Characters must be grouped for alerts to be meaningful

---

## Installation
1. Copy the script into your MacroQuest Lua directory:
