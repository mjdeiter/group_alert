# Group Alert

[![Support](https://img.shields.io/badge/Support-Buy%20Me%20a%20Coffee-6f4e37)](https://buymeacoffee.com/shablagu)

**Originally created by Alektra <Lederhosen>**

A real-time group distance monitoring tool for the **Project Lazarus EverQuest EMU server**.  
Group Alert continuously tracks group member distances from the group leader and provides **high-visibility, center-screen alerts** when members become separated — helping prevent split groups during raids, dungeons, and travel.

---

## Features

### Real-Time Monitoring
- Automatic distance checks (configurable interval: 1–30 seconds)
- Live ImGui GUI with color-coded member status
- **Center-screen alert overlay** for separation events
- Manual distance check on demand

### Center-Screen Alerts (v2.3.8+)
- Large, high-visibility ImGui overlay
- **Fluorescent green text with black outline**
- Fires **once per separation event**
- **No alert spam**
- Automatically clears when all members return within range
- Testable via GUI button

### Visual Interface
- Clean ImGui window with collapsible settings
- Color-coded distance display:
  - **Green**: Member within range
  - **Red**: Member too far (alert state)
  - **Blue**: Group leader
  - **Gray**: No coordinates available
- Real-time distance readouts in EverQuest units
- Clear status indicators for quick assessment

### Flexible Configuration
- Adjustable distance threshold (50–2000 units, default: 500)
- Configurable check interval (1–30 seconds, default: 5)
- **Enable Center-Screen Alerts** toggle
- **Test Center-Screen Alert** button
- Debug mode for troubleshooting

### EMU-Safe Design
- Handles both 0-based and 1-based group indexing
- Graceful fallback for missing or nil group data
- Safe during zone transitions
- Conservative TLO access patterns
- No reliance on optional HUD or alert plugins

---

## Requirements

- Project Lazarus EverQuest EMU server
- MacroQuest **MQNext (MQ2Mono)**
- ImGui support (no additional plugins required)

> **Note:**  
> MQ2HUD and MQ2Alert are **not required** and are no longer used.

---

## Installation

1. Copy `group_alert.lua` into your MacroQuest `lua` directory
2. In-game, run:
