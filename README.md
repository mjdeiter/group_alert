This script is a controller-side distance monitor for EverQuest group play on MacroQuest, with HUD-based alerts when members drift too far from the leader.

Overview
This Lua script for MQNext watches the current group, computes 3D distances between each member and the group leader, and raises alerts when anyone exceeds a configurable distance threshold. It is designed to be simple, deterministic, and safe for EMU servers such as Project Lazarus, using MQ variables and MQ2HUD for in-game visualization.

Features
Monitors all group members relative to the current group leader in 3D space.

Configurable distance threshold in game units (default 500).

Periodic checks with a configurable interval (default 5 seconds).

HUD-based alert line driven by MQ variables to show out-of-range members.

Debug logging to both console (optional) and a text log file.

Commands to toggle debug mode, change threshold, and re-run initialization.

Requirements
MacroQuest (MQNext) running on an EQ EMU server (tested behavior targeted at Lazarus-style environments).

Lua scripting support enabled in MQNext.

MQ2HUD plugin available; HUD-based alerts are optional but recommended.

Ability to write to the MQ directory (for group_alert_log.txt and MQ2HUD.ini updates).

Installation
Save the script file (for example) as group_alert.lua in your MQ lua or scripts folder.

Verify that MQNext is running and connected to your EMU server.

Ensure MQ2HUD is available in your Plugins folder if you plan to use the HUD alert feature.

Confirm that your MQ directory is writable so the script can create and append to group_alert_log.txt.

How It Works
On startup, the script clears or creates group_alert_log.txt and begins logging timestamped messages for key events and errors.

It checks for and declares two MQ variables if they do not already exist:

groupAlert (int) – 0 when all clear, 1 when any member is too far away.

groupAlertMembers (string) – comma-separated list of distant members.

A HUD entry is written into MQ2HUD.ini under the "HUD" section with the key GroupAlertText.

This line uses ${groupAlert} and ${groupAlertMembers} to conditionally display a red “GROUP ALERT” message and names when groupAlert is 1.

Every checkInterval seconds, the script:

Validates the group size and leader.

Reads the leader’s current coordinates.

Iterates over each group member, computes 3D distance to the leader, and records any member whose distance exceeds threshold.

Updates state.showAlert and sets MQ variables accordingly (groupAlert and groupAlertMembers).

Optionally reloads MQ2HUD when alerts change, ensuring HUD reflects the current state.

Commands
The script binds a /groupalert command with sub-commands:

/groupalert

Shows basic usage help text in the MQ console.

/groupalert debug

Toggles debug logging on or off.

When debug is on, key operations and errors are echoed to the MQ console in addition to the log file.

/groupalert threshold <value>

Sets the distance threshold (in game units) to a positive numeric value.

Invalid or non-positive values are rejected with a clear error message.

/groupalert reload

Re-runs the MacroQuest variable initialization routine.

Useful if variables were cleared, changed, or corrupted during the session.

HUD Integration
On load, the script:

Attempts to load MQ2HUD automatically if useHUDAlert is enabled and the plugin is not yet loaded.

Writes/updates this HUD entry in MQ2HUD.ini (section "HUD", key GroupAlertText):

Position: 100,100 (screen coordinates; adjust manually in the INI if desired).

Color: red text when alerting.

Content: shows “GROUP ALERT: <names>” when groupAlert is 1, otherwise blank.

Reloads the HUD layout when alerts change (and useHUDAlert is enabled), ensuring the HUD line updates promptly.

If MQ2HUD cannot be loaded, the script will disable HUD alerts for the session but continue console alerts and variable updates.

Logging and Debugging
All internal events (initialization, errors, state updates) are logged to group_alert_log.txt with timestamps.

When debug mode is enabled, selected log messages are also printed to the MQ console with a [Debug] tag and colored text.

Errors executing MQ commands are captured via protected calls, logged, and surfaced in the console with a short, clear message pointing to the log file for details.

Runtime Behavior
The script runs an infinite loop with a short delay (mq.delay(50)) to remain responsive while avoiding tight loops.

Each cycle, it processes MQ events and checks whether checkInterval seconds have elapsed since the last distance scan.

When any member is beyond the threshold, the script prints a red “GROUP ALERT” message in the console with the list of separated members.

When a previously active alert clears (all members back within range), it prints a green “All clear” message.

Status transitions (alert raised or cleared) are also logged to the log file to help reconstruct group movement issues.

Configuration Notes
config.threshold: Adjust this to match your content and pull strategy; larger zones or kite situations may need a higher value.

config.checkInterval: Lower values mean more frequent checks (more responsiveness) at the cost of slightly more overhead.

config.useHUDAlert: Set to false if you want console-only behavior or if MQ2HUD is not desired.

config.debug: Can be toggled at runtime via /groupalert debug; leaving it off is recommended for normal play to reduce console noise.

Credits and Versioning
Originally created by Alektra <Lederhosen>.

Current script version: 1.5.2 (shown in the console on startup).

The console startup messages confirm successful load and provide the version string so you can verify which build is running.

Credits
Created by: Alektra
For: Project Lazarus EverQuest EMU Server
Support: https://buymeacoffee.com/shablagu
