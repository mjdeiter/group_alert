Group Alert (Project Lazarus)

A controller-driven group distance monitor for the Project Lazarus EverQuest EMU server.

Overview

Group Alert allows one designated controller character to monitor how far each group member is from the group leader. When a member exceeds a configurable distance threshold, the script raises clear alerts using the MacroQuest console and optionally MQ2HUD.

The goal is to provide at-a-glance awareness when someone drifts out of range, without requiring scripts to run on every toon.

What It Does

Monitors distance between the group leader and each group member

Raises alerts when any member exceeds a configured range

Displays alert information via:

MacroQuest console messages

MQ2HUD (optional)

Logs activity to a file for troubleshooting and history

Compatibility

Project Lazarus EverQuest EMU server

MacroQuest MQNext (MQ2Mono)

E3Next

Lazarus-compatible HUD setups (MQ2HUD, optional but recommended)

How It Works
Single Controller Script

Runs only on one controller character

Periodically checks the group leader’s position

Calculates 3D distance between the leader and each group member

Updates MQ variables used by MQ2HUD for visual alerts

Processing Flow

Track the group leader’s coordinates

Measure each group member’s distance from the leader

If any member exceeds the threshold:

Set groupAlert = 1

Populate groupAlertMembers with the names of out-of-range toons

Reload MQ2HUD (if enabled)

Print a console alert

When all members return within range:

Set groupAlert = 0

Clear groupAlertMembers

Reload MQ2HUD (if enabled)

Print an “All clear” message

Key Features

Controller-only execution
Only one toon runs the script and controls alerts.

Distance-based alerts
Configurable 3D distance threshold between leader and members.

HUD integration
Displays a red “GROUP ALERT” line via MQ2HUD with separated member names.

Timestamped logging
Writes to group_alert_log.txt for debugging and historical reference.

Safe variable handling
Declares and verifies MQ variables before use:

groupAlert

groupAlertMembers

Robust command wrapper
Safely executes MQ commands and reports failures clearly.

Alert state tracking
“All clear” messages are printed only when transitioning from alert to safe.

Requirements

Project Lazarus (or compatible EQ EMU server)

MacroQuest MQNext (MQ2Mono)

MQ2HUD plugin (optional but recommended)

Characters must be grouped and in command range for alerts to be meaningful

Installation

Copy the script into your MacroQuest Lua directory:

group_alert.lua


If using HUD alerts, ensure MQ2HUD is present in your Plugins folder.

Start EverQuest and MacroQuest on your controller character.

From the MQ console, run:

/lua run group_alert

Usage
Default Behavior

Once running, the script:

Checks group distances at a fixed interval (default: every 5 seconds)

Prints red console alerts listing members who are too far away

Prints green “All clear” messages when everyone is back in range

Shows or hides a “GROUP ALERT” line in MQ2HUD based on groupAlert

Commands
/groupalert

Displays usage help in the MQ console.

/groupalert debug

Toggles debug mode on or off.

When enabled:

Key events and errors are echoed to the MQ console

Additional detail is written to the log file

/groupalert threshold <value>

Sets the distance threshold (in game units).

Must be a positive number

Invalid values are rejected with a clear message

/groupalert reload

Reinitializes MacroQuest variables.

Useful if variables were cleared or modified during a session.

Configuration
Distance Threshold

config.threshold (default: 500)
Controls how far a member may be from the leader before triggering an alert.

Guidelines:

Higher values for large zones or kiting

Lower values for tight camps

Check Interval

config.checkInterval (default: 5 seconds)
Controls how often the script scans group distances.

Shorter intervals respond faster but perform checks more frequently.

HUD Alerts

config.useHUDAlert (default: true)

On startup, the script:

Attempts to load MQ2HUD if not already loaded

Writes or updates GroupAlertText in MQ2HUD.ini

Reloads the HUD as needed to reflect alert state

If MQ2HUD cannot be loaded:

HUD alerts are disabled for the session

Console and log alerts remain active

Debug Mode

config.debug (default: false)

When enabled, additional diagnostic information is printed, including:

Variable initialization

MQ command execution

Group scan details and errors

Files and Storage
Log File

group_alert_log.txt (in the MQ directory)

Contains timestamped entries for:

Script startup and shutdown

MQ command failures

Variable initialization and updates

Group scanning issues (e.g., invalid leader coordinates)

HUD Configuration

MQ2HUD.ini (existing file)

The script adds or updates:

GroupAlertText under the HUD section

Design Philosophy

Group Alert is built to align with Project Lazarus-style constraints by:

Using a single controller toon

Avoiding remote polling or automation on other characters

Favoring predictable behavior and explicit thresholds

Failing safely with protected MQ commands and variable checks

Keeping automation minimal and focused

Credits

Created by: Alektra

For: Project Lazarus EverQuest EMU Server

Support: https://buymeacoffee.com/shablagu
