# Group Alert Changelog

## [v2.1.0] - 2025-12-20

### Added
- **Exit Script button** in GUI for full script termination
- `/groupalert exit` command for command-line termination
- Tooltip for Exit button explaining full termination vs window close

### Changed
- X button now hides window while script continues monitoring (consistent with itempass pattern)
- `/groupalert gui` command can reopen hidden window

### Fixed
- Proper script termination handling
- Clear distinction between "hide window" and "exit script"

---

## [v2.0.3] - 2025-12-20

### Fixed
- Simplified GUI state management to match itempass pattern
- Window now properly hides when X button is clicked
- Script continues monitoring in background when window is hidden

---

## [v2.0.2] - 2025-12-20

### Fixed
- Added terminate flag for proper script exit handling

---

## [v2.0.1] - 2025-12-20

### Fixed
- **CRITICAL**: Fixed ImGui Begin/End pairing issue
- Resolved "Mismatched Begin/BeginChild vs End/EndChild" error
- Proper window state handling before GUI operations

---

## [v2.0.0] - 2025-12-20

### Added
- **Full ImGui interface** with real-time monitoring
- Collapsible settings panel
- Live group member distance display with color coding:
  - Green: Within range
  - Red: Too far
  - Blue: Group leader
  - Gray: No coordinates available
- Tooltips for all buttons and controls
- Manual check button in GUI
- Settings controls:
  - Distance threshold slider (50-2000 units)
  - Check interval slider (1-30 seconds)
  - HUD alert toggle
  - Debug mode toggle
  - Reload HUD button

### Changed
- Major UI overhaul from CLI-only to full GUI
- Real-time status display in window
- Interactive configuration via sliders and checkboxes

---

## [v1.7.0] - 2025-12-20

### Added
- **EMU-safe group indexing** - handles both 0-based and 1-based group member indexing
- `getGroupMemberCount()` helper with safe type conversion
- `getGroupMember(index)` helper with automatic fallback
- **Configurable check interval** via `/groupalert interval <seconds>` command
- **Status command** - `/groupalert status` displays all current settings
- Improved startup message with command hint

### Changed
- Group member access now uses dual-indexing pattern for EMU compatibility
- Better type safety for group member count

---

## [v1.6.0] - 2025-12-20

### Added
- **Manual group check** command - `/groupalert check`
- Immediate distance verification with detailed output
- Shows all members with exact distances
- Displays current threshold and leader information
- Handles edge cases (no group, missing coordinates)

---

## [v1.5.2] - Original Version

### Features
- Monitors group member distances from leader
- Configurable distance threshold (default: 500 units)
- HUD alerts via MQ2HUD integration
- Automatic distance checks every 5 seconds
- Debug logging to file
- Commands:
  - `/groupalert debug` - Toggle debug mode
  - `/groupalert threshold <value>` - Set distance threshold
  - `/groupalert reload` - Reload configuration

### Technical
- Works with MacroQuest MQNext
- Project Lazarus EMU compatible
- MQ2HUD integration for on-screen alerts
- File-based debug logging
