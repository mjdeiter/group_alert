# Group Alert Changelog
All notable changes to this project are documented in this file.
This project follows a pragmatic versioning scheme where:
- Patch releases fix correctness issues
- Minor releases add features
- Visual-only changes are explicitly called out
---
## [v2.3.13] – 2026-01-17
### UI Cleanup Release
### Removed
- Manual Check button from GUI (redundant with automatic checking)
- `manualGroupCheck()` function
- `/groupalert check` command option
### Notes
- No feature changes to core monitoring functionality
- No configuration changes
- Fully backward compatible with existing settings
- Automatic distance checking continues to function every interval
This release is a **UI cleanup** that removes redundant functionality while
preserving all monitoring and alert features.
---
## [v2.3.12] – 2026-01-02
### Full Group Iteration Fix (Canonical)
### Fixed
- Corrected group member iteration on Project Lazarus so **all 6 group members**
  are displayed and evaluated correctly.
- Resolved off-by-one behavior caused by `Group.Members()` returning only
  non-self members on Lazarus.
### Notes
- No feature changes
- No UI changes
- No HUD changes
- No configuration changes
- Fully backward compatible
This release is a **surgical correctness fix** and preserves all existing
behavior, visuals, and saved settings.
---
## [v2.3.11] – 2025-12-29
### EQ-Style Overlay & Persistence (Visual Polish Release)
### Added
- Persistent configuration saved to `GroupAlert.ini`:
  - Distance threshold
  - Check interval
  - Center-screen alert toggle
  - Debug mode
  - Overlay shadow offset (X/Y)
  - Overlay font toggle and font size
- EQ-style center-screen overlay:
  - Fully transparent background
  - Single drop shadow (~1px right/down)
- Color-coded overlay states:
  - **Red** when group members exceed threshold
  - **Green** when group returns within range
- Optional overlay-only pixel-style font (Tahoma fallback)
### Changed
- Replaced outlined/boxed overlay styles with native EverQuest-style text
- Explicit RGBA rendering for overlay text
- Visual polish without altering alert logic or timing
---
## [v2.3.10] – 2025-12-22
### Center Overlay Alerts + Manual CoTH
### Added
- Center-screen alert overlay rendered via ImGui
- Test Center-Screen Alert button
- Enable Center-Screen Alerts toggle
- **Always-visible "Cast Call of the Heroes" button**
  - Manual trigger only
  - Uses E3 group broadcast
### Changed
- Replaced MQ2HUD-based alerts with ImGui overlay
- Alerts now fire once per state change (no spam)
- Clear alert fires when group returns within range
### Removed
- MQ2HUD dependency
- MQ2Alert usage
- `/alert` command reliance
---
## [v2.3.0 – v2.3.9]
### Internal Iterations
These versions represent internal migration work and incremental refinements
leading up to the stable v2.3.10 overlay system.
---
## [v2.0.0] – 2025-12-20
### Full GUI Introduction
### Added
- Full ImGui interface
- Live group member distance list
- Color-coded member display:
  - Green – Within range
  - Red – Too far
  - Blue – Group leader
  - Gray – No coordinates
- Collapsible settings panel
- Manual Check button
- Distance threshold and interval sliders
- Debug mode toggle
---
## [v1.x] – Original Releases
### Initial Functionality
- Group distance monitoring relative to leader
- Configurable distance threshold
- Automatic periodic checks
- Debug logging to file
- CLI-only interface (pre-GUI)
