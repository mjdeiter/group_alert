Group Alert (Project Lazarus)

A controller-driven group distance monitor for the Project Lazarus EverQuest EMU server.

What It Does

Group Alert lets one character monitor how far each group member is from the group leader and raises clear alerts when anyone is too far away. It uses MacroQuest variables plus MQ2HUD so you can see at a glance who has drifted out of range.

Compatible With

MacroQuest MQNext (MQ2Mono)
E3Next
Lazarus-compatible HUD setups (MQ2HUD)

How It Works

Single Controller Script

Runs only on your main/controller character

Periodically checks the group leader’s position and compares each member’s 3D distance

Updates MQ variables so the HUD can show alert text

The Process:

The script tracks the leader’s coordinates

It measures each group member’s distance from the leader

If any member exceeds the configured threshold, it:

Sets groupAlert = 1

Fills groupAlertMembers with the names of distant toons

Reloads MQ2HUD (if enabled) and prints a console alert

When everyone comes back within range, it:

Sets groupAlert = 0 and clears groupAlertMembers

Reloads MQ2HUD (if enabled) and prints an “All clear” message

Key Features

Controller-only execution – Only one toon runs the script and controls alerts

Distance-based alerts – Configurable 3D distance threshold between leader and members

HUD integration – Uses MQ2HUD to show a red “GROUP ALERT” line with separated member names

Timestamped logging – Writes a log file (group_alert_log.txt) for debugging and history

Safe variable handling – Declares and verifies MQ variables before use (groupAlert, groupAlertMembers)

Robust command wrapper – Safely executes MQ commands and reports failures clearly

Alert state tracking – Prints “All clear” only when transitioning from alert back to safe

Requirements

Project Lazarus or compatible EQ EMU server

MacroQuest MQNext (MQ2Mono)

MQ2HUD plugin (for HUD alerts; optional but recommended)

Characters must be grouped and in command range for HUD/console status to be meaningful

Installation

Copy the script file (for example):

group_alert.lua
into your MQ lua (or scripts) directory.

Ensure MQ2HUD is present in your Plugins folder if you want HUD alerts.

Start EverQuest and MacroQuest on your controller character.

From the MQ console on the controller, run:

/lua run group_alert

Usage

Basic Behavior

Once running, the script:

Checks group distances at a fixed interval (default every 5 seconds)

Prints red console alerts listing members who are too far from the leader

Prints green “All clear” messages when everyone is back in range

MQ2HUD displays or hides a “GROUP ALERT” line based on the groupAlert variable.

Commands

/groupalert

Shows usage help in the MQ console.

/groupalert debug

Toggles debug mode on or off.

When ON, key events and errors are echoed to the MQ console in addition to the log file.

/groupalert threshold <value>

Sets the distance threshold in game units.

Must be a positive number; invalid values are rejected with a clear message.

/groupalert reload

Re-runs the MacroQuest variable initialization routine.

Useful if the variables were cleared or changed during the session.

Configuration

Distance Threshold

config.threshold (default: 500) controls how far a member can be from the leader before triggering an alert.

Higher values are appropriate for large zones or kiting; lower values for tight camps.

Check Interval

config.checkInterval (default: 5 seconds) sets how often the script scans group distances.

Shorter intervals react faster but perform checks more frequently.

HUD Alerts

config.useHUDAlert (default: true) controls whether MQ2HUD is used.

On startup, the script:

Attempts to load MQ2HUD if it is not already loaded

Writes/updates the GroupAlertText entry in MQ2HUD.ini under the HUD section

Reloads the HUD when needed so the alert text reflects current state

If MQ2HUD cannot be loaded, HUD alerts are disabled for that session and only console/log alerts are used.

Debug Mode

config.debug (default: false) can be toggled with /groupalert debug.

When enabled, the script prints additional information about variable checks, command execution, and group scanning to the console.

Where Settings and Logs Are Saved

Log file: group_alert_log.txt in your MQ directory.

Contains timestamped entries for:

Startup and shutdown

MQ command errors

Variable initialization and updates

Group scan operations and issues (e.g., invalid leader coordinates)

MQ2HUD configuration: MQ2HUD.ini (existing file).

The script adds or updates the GroupAlertText entry in the HUD section.

Design Philosophy

Group Alert respects Project Lazarus-style constraints by:

Using a single controller – Only one character runs the script and drives alerts

Avoiding remote polling – Relies on group/leader information exposed locally to the controller

Preferring predictable behavior – Fixed check interval, explicit thresholds, and clear state transitions

Failing safely – Protected MQ command execution, robust variable checks, and graceful handling when MQ2HUD is unavailable

Keeping automation minimal – No buff/inventory scanning, no background execution on other toons

Credits

Created by: Alektra <Lederhosen>
For: Project Lazarus EverQuest EMU Server
Version: 1.5.2 (shown on load as Group Alert Script v1.5.2)
