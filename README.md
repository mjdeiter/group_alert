# Group Alert

[![Support](https://img.shields.io/badge/Support-Buy%20Me%20a%20Coffee-6f4e37)](https://buymeacoffee.com/shablagu)

**Originally created by Alektra \<Lederhosen\>**

A real-time group distance monitoring tool for Project Lazarus (EverQuest EMU). Group Alert continuously tracks group member distances from the leader and alerts you when members are too far away, helping prevent split groups during raids and dungeon exploration.

## Features

### Real-Time Monitoring
- Automatic distance checks (configurable interval: 1-30 seconds)
- Live GUI display with color-coded member status
- HUD alerts via MQ2HUD integration
- Manual distance check on demand

### Visual Interface
- Clean ImGui window with collapsible settings
- Color-coded distance display:
  - **Green**: Member within range
  - **Red**: Member too far (alert state)
  - **Blue**: Group leader
  - **Gray**: No coordinates available
- Real-time distance readouts in units
- Status messages for quick assessment

### Flexible Configuration
- Adjustable distance threshold (50-2000 units, default: 500)
- Configurable check interval (1-30 seconds, default: 5)
- HUD alert toggle
- Debug mode for troubleshooting
- Settings persist in GUI sliders

### EMU-Safe Design
- Handles both 0-based and 1-based group indexing
- Graceful fallback for missing group data
- No crashes on zone transitions
- Robust coordinate validation

## Requirements

- Project Lazarus EverQuest EMU server
- MacroQuest MQNext (MQ2Mono)
- MQ2HUD plugin (optional, for HUD alerts)
- ImGui support

## Installation

1. Copy `group_alert.lua` to your MacroQuest `lua` folder
2. In-game, run: `/lua run group_alert`
3. The GUI window will open automatically

## Usage

### GUI Controls

**Status Display**
- Shows current group leader
- Displays total group member count
- Alert state indicator (green = all clear, red = members too far)
- List of separated members when alert is active

**Settings Panel** (collapsible)
- **Distance Threshold**: Maximum distance before alerting (50-2000 units)
- **Check Interval**: Seconds between automatic checks (1-30 seconds)
- **Enable HUD Alert**: Toggle MQ2HUD overlay alerts
- **Debug Mode**: Enable detailed logging to file
- **Reload HUD**: Reinitialize MQ variables and reload HUD

**Group Members List**
- Real-time distance for each member
- Color-coded status at a glance
- Updates automatically during monitoring

**Buttons**
- **Show/Hide Settings**: Toggle settings panel
- **Manual Check**: Force immediate distance check with console output
- **Exit Script**: Fully terminate the script

### Command Line Interface
```
/groupalert debug              - Toggle debug mode
/groupalert threshold <value>  - Set distance threshold (units)
/groupalert interval <seconds> - Set check interval (seconds)
/groupalert check              - Manual distance check with detailed output
/groupalert status             - Display current settings
/groupalert reload             - Reload HUD configuration
/groupalert gui                - Reopen GUI window if closed
/groupalert exit               - Exit script
```

### Manual Check Output

The `/groupalert check` command provides detailed console output:
```
[GROUP ALERT] Running manual group check...
[GROUP ALERT] Leader: YourLeaderName
[GROUP ALERT] Threshold: 500 units
[GROUP ALERT] Within range: Tank (45 units), Healer (123 units)
[GROUP ALERT] Too far: Puller (873 units)
```

### Window Management

- **X button**: Hides window, script continues monitoring in background
- **Exit Script button**: Closes window AND terminates script completely
- **`/groupalert gui`**: Reopens window if hidden
- **`/groupalert exit`** or **`/lua stop group_alert`**: Command-line termination

## Configuration

### Distance Threshold
Adjust based on your group's playstyle:
- **200-300**: Tight formation (dungeons, pulling)
- **500**: Default (balanced for most content)
- **1000+**: Loose formation (open world, farming)

### Check Interval
Balance between responsiveness and performance:
- **1-3 seconds**: High alertness (raids, dangerous content)
- **5 seconds**: Default (balanced)
- **10-30 seconds**: Casual monitoring (low overhead)

### HUD Alert
When enabled, displays on-screen alert with separated member names:
```
GROUP ALERT: Puller, DPS2
```

Position configured in `MQ2HUD.ini` (default: top-left, red text).

## Technical Details

### EMU Compatibility

**Group Indexing**: Dual-pattern support for both 0-based and 1-based indexing
```lua
-- Tries 0-based first (standard MQ2)
local member = mq.TLO.Group.Member(index)
-- Falls back to 1-based if needed
member = mq.TLO.Group.Member(index + 1)
```

**Safe Operations**:
- Type-safe group member count with fallback
- Coordinate validation before distance calculations
- Graceful handling of missing group data
- No crashes on zone transitions or group changes

### Distance Calculation

3D Euclidean distance from leader:
```
distance = √((x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²)
```

All measurements in EverQuest units.

### MQ2HUD Integration

The script creates two MQ variables:
- `${groupAlert}`: 0 (clear) or 1 (alert)
- `${groupAlertMembers}`: Comma-separated list of separated members

HUD configuration automatically added to `MQ2HUD.ini`:
```ini
GroupAlertText=100,100,3,255,0,0,${If[${groupAlert}==1,GROUP ALERT: ${groupAlertMembers},]}
```

Position: X=100, Y=100, Font=3, Color=Red (255,0,0)

### Debug Logging

When debug mode is enabled, logs to `group_alert_log.txt`:
```
[2025-12-20 15:30:45] Checking group distances...
[2025-12-20 15:30:45] Checking if 'groupAlert' is defined: true
[2025-12-20 15:30:45] Set groupAlert=1, groupAlertMembers="Puller"
```

## Troubleshooting

**HUD not showing alerts**
- Ensure MQ2HUD plugin is loaded: `/plugin MQ2HUD`
- Verify HUD is enabled: `/hud on`
- Check HUD configuration: `/hud reload`
- Confirm "Enable HUD Alert" is checked in settings

**Script won't start**
- Ensure you're in-game (not at character select)
- Verify MacroQuest is loaded properly
- Check for conflicting scripts

**Members showing as "no coordinates"**
- Member may be zoning or logging in
- Member may be in different zone
- Network lag may delay coordinate updates

**Distances seem incorrect**
- Verify all members are in same zone
- Check for elevation differences (Z-axis)
- Ensure coordinates are updating (not frozen)

**Window won't close**
- Use "Exit Script" button for full termination
- X button only hides window (script continues)
- Use `/groupalert exit` or `/lua stop group_alert` from console

**Script crashes on group changes**
- Update to latest version (EMU-safe indexing added in v1.7.0)
- Enable debug mode to capture error details
- Report issue with debug log

## Performance

- **CPU Impact**: Minimal (5-second default check interval)
- **Memory**: < 1 MB
- **Network**: No additional network traffic (uses cached TLO data)

Typical overhead: < 0.1% CPU usage on modern systems.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Current Version

**v2.1.0** - 2025-12-20
- Full GUI with real-time monitoring
- Exit Script button for proper termination
- EMU-safe group indexing
- Configurable intervals and thresholds
- Comprehensive tooltips and help text

## Credits

**Originally created by Alektra \<Lederhosen\>**

Enhanced and maintained for the Project Lazarus community.

## License

This script is provided as-is for use on Project Lazarus.
