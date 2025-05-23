-- Group Alert Script for MacroQuest
-- Monitors group member distances and alerts via HUD when members are too far from the leader
-- Version: 1.5.1

local mq = require('mq')
local SCRIPT_VERSION = "1.5.1"

-- Configuration
local config = {
    threshold = 500,         -- Distance threshold in units
    checkInterval = 5,       -- Interval in seconds between checks
    useHUDAlert = true,      -- Enable/disable HUD alert
    debug = false            -- Enable debug output
}

-- State variables
local state = {
    showAlert = false,
    separatedMembers = {},
    lastCheckTime = os.time()
}

-- Log file for debugging
local logFilePath = "group_alert_log.txt"

-- Clear log file on startup
local clearLogFile = io.open(logFilePath, "w")
if clearLogFile then
    clearLogFile:close()
end

-- Log messages with timestamps
local function logMessage(message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = string.format("[%s] %s\n", timestamp, message)
    local file = io.open(logFilePath, "a")
    if file then
        file:write(logEntry)
        file:close()
    else
        print("\arError: Could not open log file.")
    end
    if config.debug then
        print("\ay[Debug] " .. message)
    end
end

-- Safely execute MacroQuest commands
local function safeMQCommand(command)
    local success, err = pcall(function() mq.cmd(command) end)
    if not success then
        logMessage("Error executing '" .. command .. "': " .. tostring(err))
        print("\arError: " .. command .. " failed - Check " .. logFilePath)
        return false
    end
    return true
end

-- Check if a variable is defined in MacroQuest
local function isVariableDefined(varName)
    local success, result = pcall(function() return mq.TLO.Defined(varName)() end)
    if not success then
        logMessage("Error checking variable '" .. varName .. "': " .. tostring(result))
        return false
    end
    logMessage("Checking if '" .. varName .. "' is defined: " .. tostring(result))
    return result
end

-- Initialize MacroQuest variables
local function initializeMQVariables()
    logMessage("Initializing MacroQuest variables...")

    -- Declare variables if they don’t exist
    if not isVariableDefined("groupAlert") then
        safeMQCommand("/declare groupAlert int outer 0")
        logMessage("Declared 'groupAlert' as int outer with value 0")
    else
        logMessage("'groupAlert' already declared")
    end

    if not isVariableDefined("groupAlertMembers") then
        safeMQCommand("/declare groupAlertMembers string outer \"\"")
        logMessage("Declared 'groupAlertMembers' as string outer with value \"\"")
    else
        logMessage("'groupAlertMembers' already declared")
    end

    -- Verify declarations
    safeMQCommand("/echo Verifying groupAlert: ${groupAlert}")
    safeMQCommand("/echo Verifying groupAlertMembers: ${groupAlertMembers}")
end

-- Update MacroQuest variables with checks
local function updateMQ2Variables()
    -- Ensure variables exist before setting
    if not isVariableDefined("groupAlert") then
        logMessage("'groupAlert' missing, re-declaring...")
        safeMQCommand("/declare groupAlert int outer 0")
    end
    if not isVariableDefined("groupAlertMembers") then
        logMessage("'groupAlertMembers' missing, re-declaring...")
        safeMQCommand("/declare groupAlertMembers string outer \"\"")
    end

    -- Set values based on alert state
    if state.showAlert then
        safeMQCommand("/varset groupAlert 1")
        safeMQCommand("/varset groupAlertMembers \"" .. table.concat(state.separatedMembers, ", ") .. "\"")
        logMessage("Set groupAlert=1, groupAlertMembers=\"" .. table.concat(state.separatedMembers, ", ") .. "\"")
    else
        safeMQCommand("/varset groupAlert 0")
        safeMQCommand("/varset groupAlertMembers \"\"")
        logMessage("Set groupAlert=0, groupAlertMembers=\"\"")
    end

    -- Reload HUD if in use
    if config.useHUDAlert and mq.TLO.Plugin("MQ2HUD").IsLoaded() then
        safeMQCommand("/hud reload")
        logMessage("HUD reloaded")
    end
end

-- Calculate 3D distance
local function calculateDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

-- Check group member distances
local function checkGroupDistances()
    logMessage("Checking group distances...")
    local groupMembers = mq.TLO.Group.Members()
    if not groupMembers or groupMembers < 2 then
        state.showAlert = false
        updateMQ2Variables()
        return
    end

    local leader = mq.TLO.Group.Leader
    if not leader or not leader.Name() then
        state.showAlert = false
        updateMQ2Variables()
        return
    end

    -- Cache leader's coordinates
    local leaderX, leaderY, leaderZ = leader.X(), leader.Y(), leader.Z()
    if not leaderX or not leaderY or not leaderZ then
        logMessage("Invalid leader coordinates")
        return
    end

    state.separatedMembers = {}
    for i = 0, groupMembers - 1 do
        local member = mq.TLO.Group.Member(i)
        if member and member.Name() and member.Name() ~= leader.Name() then
            local memberX, memberY, memberZ = member.X(), member.Y(), member.Z()
            if memberX and memberY and memberZ then
                local distance = calculateDistance(leaderX, leaderY, leaderZ, memberX, memberY, memberZ)
                if distance > config.threshold then
                    table.insert(state.separatedMembers, member.Name())
                end
            end
        end
    end

    state.showAlert = #state.separatedMembers > 0
    updateMQ2Variables()
    if state.showAlert then
        print("\ar[GROUP ALERT] Members too far: " .. table.concat(state.separatedMembers, ", "))
    end
end

-- Command handler
local function groupAlertCommand(...)
    local args = {...}
    if args[1] == "debug" then
        config.debug = not config.debug
        print("\ayDebug mode " .. (config.debug and "\agON" or "\arOFF"))
    elseif args[1] == "threshold" and args[2] then
        local newThreshold = tonumber(args[2])
        if newThreshold and newThreshold > 0 then
            config.threshold = newThreshold
            print("\agThreshold set to " .. config.threshold)
        else
            print("\arInvalid threshold value. Must be a positive number.")
        end
    elseif args[1] == "reload" then
        initializeMQVariables()
        print("\agConfiguration reloaded.")
    else
        print("\ay/groupalert debug - Toggle debug mode")
        print("\ay/groupalert threshold <value> - Set distance threshold")
        print("\ay/groupalert reload - Reload configuration")
    end
end

-- Bind command
mq.bind("/groupalert", groupAlertCommand)

-- Check plugins
if config.useHUDAlert and not mq.TLO.Plugin("MQ2HUD").IsLoaded() then
    print("\arMQ2HUD not loaded. Attempting to load it...")
    safeMQCommand("/plugin MQ2HUD")
    if not mq.TLO.Plugin("MQ2HUD").IsLoaded() then
        print("\arFailed to load MQ2HUD. HUD alerts disabled.")
        config.useHUDAlert = false
    end
end

-- Initialize and setup HUD
initializeMQVariables()
safeMQCommand('/ini "MQ2HUD.ini" "HUD" "GroupAlertText" "100,100,3,255,0,0,${If[${groupAlert}==1,GROUP ALERT: ${groupAlertMembers},]}"')
if config.useHUDAlert then
    safeMQCommand("/hud reload")
end

print("\agGroup Alert Script v" .. SCRIPT_VERSION .. " Loaded")
logMessage("Script started")

-- Main loop
while true do
    mq.doevents()
    if os.time() - state.lastCheckTime >= config.checkInterval then
        state.lastCheckTime = os.time()
        checkGroupDistances()
    end
    mq.delay(50)
end