# Group Alert Changelog

---

## [v2.3.11] – 2025-12-29  
### EQ-Style Overlay, Persistence, and Visual Clarity (Canonical)

### Added
- Persistent configuration saved to `GroupAlert.ini`:
  - Distance threshold
  - Check interval
  - Center-screen alert toggle
  - Debug mode
  - Overlay shadow offset (X/Y)
  - Overlay font toggle and font size
- EQ-style center-screen overlay rendering:
  - Fully transparent ImGui window (no background plate)
  - Single drop shadow for native EverQuest-style readability
- Color-coded alert states:
  - **Red** when group members exceed distance threshold
  - **Green** when group returns within range
- Optional overlay-only font for improved clarity (safe fallback if unavailable)

### Changed
- Replaced outlined/boxed overlay styles with native-feeling EQ-style text
- Center overlay rendering now uses explicit RGBA foreground colors
- Overlay visuals refined without altering alert timing or logic

### Compatibility
- EMU-safe (Project Lazarus compliant)
- MacroQuest MQNext (MQ2Mono)
- No MQ2HUD, MQ2Alert, or `/alert` usage
- Deterministic one-shot alerts preserved

---

## [v2.3.10] – 2025-12-22  
### Center Overlay Alerts + Manual CoTH (Stable Release)

### Added
- **Always-visible “Cast Call of the Heroes” button**
  - Manual trigger (not gated by alert state)
  - Uses E3 group broadcast
- **Center-screen alert overlay** rendered via ImGui
- **Test Center-Screen Alert** button for diagnostics
- **Enable Center-Screen Alerts** toggle
- High-visibility alert styling:
  - Fluorescent green text
  - Black outline
  - 2× font scale

### Changed
- Replaced MQ2HUD-based alerts with a deterministic ImGui overlay
- Alerts now:
  - Fire once per separation event
  - Do not spam while the condition persists
  - Auto-clear when all members return within range
- Improved main button layout:
