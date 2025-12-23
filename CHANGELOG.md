# Group Alert Changelog

---

## [v2.3.8] – 2025-12-22  
### Center Overlay Alerts (Lazarus-Stable Release)

### Added
- **Center-screen alert overlay** rendered via ImGui (no external plugins)
- **Test Center-Screen Alert** button to instantly verify alert visibility
- **Enable Center-Screen Alerts** toggle in settings
- High-visibility alert styling:
  - 2× font scale
  - Fluorescent green text
  - Black outline for readability during combat and spell effects

### Changed
- Replaced MQ2HUD-based alerts with a **deterministic ImGui overlay**
- Alerts now:
  - Fire **once per separation event**
  - Do **not spam** while the condition persists
  - **Auto-clear** when all members return within range
- Unified alert rendering:
  - Test alerts, live alerts, and clear notifications share the same code path

### Removed
- **All MQ2HUD dependencies**
  - No plugin loading
  - No HUD ini writes
  - No `/hud reload` calls
- Removed reliance on `/alert` / MQ2Alert plugin behavior

### Fixed
- Eliminated HUD-related instability caused by plugin availability
- Resolved alert inconsistencies across different Lazarus environments

### Compatibility
- Designed specifically for **Project Lazarus (MQNext / MQ2Mono)**
- Does not rely on optional or inconsistently available plugins
- Safe under partial ImGui availability

---

## [v2.3.0–v2.3.7] – 2025-12-21 to 2025-12-22  
### Intermediate Development Iterations

> These versions were used internally during migration away from MQ2HUD.  
> They are **not intended for public use** and are superseded by **v2.3.8**.

---

## [v2.1.0] – 2025-12-20

### Added
- **Exit Script** button in GUI for full script termination
- `/groupalert exit` command for command-line termination
- Tooltip explaining the difference between **hiding the window** and **terminating the script**

### Changed
- Window **X button** now hides the GUI while monitoring continues
- `/groupalert gui` command reopens the hidden window

### Fixed
- Proper script termination handling
- Clear distinction between *hide window* and *exit script*

---

## [v2.0.3] – 2025-12-20

### Fixed
- Simplified GUI state management to match *itempass* pattern
- Window properly hides when X button is clicked
- Script continues monitoring while GUI is hidden

---

## [v2.0.2] – 2025-12-20

### Fixed
- Added terminate flag for reliable script exit handling

---

## [v2.0.1] – 2025-12-20

### Fixed
- **CRITICAL:** Fixed ImGui Begin/End pairing issue
- Resolved *“Mismatched Begin/BeginChild vs End/EndChild”* error
- Correct window state handling before GUI operations

---

## [v2.0.0] – 2025-12-20

### Added
- **Full ImGui interface** with real-time monitoring
- Collapsible settings panel
- Live group member distance display with color coding:
  - **Green** – Within range
  - **Red** – Too far
  - **Blue** – Group leader
  - **Gray** – No coordinates available
- Tooltips for all buttons and controls
- Manual Check button
- Settings controls:
  - Distance threshold slider (50–2000 units)
  - Check interval slider (1–30 seconds)
  - HUD alert toggle *(removed in later versions)*
  - Debug mode toggle
  - Reload HUD button *(removed in later versions)*

### Changed
- Major UI overhaul from CLI-only to full GUI
- Real-time status display
- Interactive configuration via sliders and checkboxes

---

## [v1.7.0] – 2025-12-20

### Added
- **EMU-safe group indexing**
  - Handles both 0-based and 1-based group member indexing
- `getGroupMemberCount()` helper with safe type conversion
- `getGroupMember(index)` helper with automatic fallback
- `/groupalert interval <seconds>` command
- `/groupalert status` command
- Improved startup message with command hint

### Changed
- Group member access now uses dual-indexing for EMU compatibility
- Improved type safety for group member count

---

## [v1.6.0] – 2025-12-20

### Added
- `/groupalert check` manual group distance check
- Immediate distance verification with detailed output
- Displays:
  - Exact distances
  - Current threshold
  - Group leader information
- Handles edge cases (no group, missing coordinates)

---

## [v1.5.2] – Original Version

### Features
- Group distance monitoring relative to leader
- Configurable distance threshold (default: 500 units)
- MQ2HUD-based alerts *(deprecated)*
- Automatic distance checks every 5 seconds
- Debug logging to file

### Commands
- `/groupalert debug` – Toggle debug mode
- `/groupalert threshold <value>` – Set distance threshold
- `/groupalert reload` – Reload configuration

### Technical
- MacroQuest MQNext compatible
- Project Lazarus EMU compatible
- MQ2HUD integration *(deprecated)*
- File-based debug logging
