-- Group Alert Script for MacroQuest
-- Monitors group member distances and alerts via HUD when members are too far from the leader
-- Version: 2.3.10

local mq = require('mq')
local ImGui = require('ImGui')
local SCRIPT_VERSION = "2.3.10"

-- Configuration
local config = {
    threshold = 500,         -- Distance threshold in units
    checkInterval = 5,       -- Interval in seconds between checks
    enableCenterAlert = true, -- Enable/disable center-screen /alert
    debug = false            -- Enable debug output
}

-- State variables
local state = {
    showAlert = false,
    separatedMembers = {},
    lastCheckTime = os.time(),
    previousShowAlert = false,  -- Track previous alert state
    alertActive = false,        -- Center-screen alert spam guard
    centerMessage = "",         -- Current overlay message
    centerUntil = 0             -- os.time() when overlay should disappear
}

-- GUI state
local showUI = true
local terminate = false

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

-- Calculate 3D distance
local function calculateDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

-- Safe group member count - handles both 0-based and 1-based indexing
local function getGroupMemberCount()
    local count = mq.TLO.Group.Members()
    if not count then return 0 end
    return tonumber(count) or 0
end

-- Safe group member access - handles both 0-based and 1-based indexing
local function getGroupMember(index)
    -- Try 0-based first (standard MQ2)
    local member = mq.TLO.Group.Member(index)
    if member and member.Name() then return member end
    
    -- Fall back to 1-based if 0-based returns nil
    member = mq.TLO.Group.Member(index + 1)
    if member and member.Name() then return member end
    
    return nil
end

-- Helper for tooltips
local function tooltip(text)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(text)
    end
end


-- Center-screen alert handling (no MQ2HUD)
-- Fires once per event, auto-clears when resolved.
local function fireCenterOverlay(msg, seconds)
    if not config.enableCenterAlert then return end
    state.centerMessage = msg or ""
    state.centerUntil = os.time() + (seconds or 3)
end

-- Center-screen alert handling (ImGui overlay; NO MQ2HUD; NO /alert command)
-- Fires once per event, auto-clears when resolved.
local function handleCenterAlert()
    if not config.enableCenterAlert then
        state.alertActive = false
        state.centerMessage = ""
        state.centerUntil = 0
        return
    end

    if state.showAlert and not state.alertActive then
        fireCenterOverlay("GROUP ALERT: " .. table.concat(state.separatedMembers, ", "), 3)
        state.alertActive = true
    elseif (not state.showAlert) and state.alertActive then
        fireCenterOverlay("GROUP ALERT CLEARED", 2)
        state.alertActive = false
    end
end

local function testCenterAlert()
    fireCenterOverlay("GROUP ALERT TEST: Center overlay is working.", 3)
end

-- GUI collapsible section state
local showSettings = false

-- Check group member distances
local function checkGroupDistances()
    logMessage("Checking group distances...")
    local groupMembers = getGroupMemberCount()
    if groupMembers < 2 then
        state.showAlert = false
        handleCenterAlert()
        if state.previousShowAlert then
            print("\ag[GROUP ALERT] All clear: All members are within range.")
        end
        state.previousShowAlert = state.showAlert
        return
    end

    local leader = mq.TLO.Group.Leader
    if not leader or not leader.Name() then
        state.showAlert = false
        handleCenterAlert()
        if state.previousShowAlert then
            print("\ag[GROUP ALERT] All clear: All members are within range.")
        end
        state.previousShowAlert = state.showAlert
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
        local member = getGroupMember(i)
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
    handleCenterAlert()
    if state.showAlert then
        print("\ar[GROUP ALERT] Members too far: " .. table.concat(state.separatedMembers, ", "))
    elseif state.previousShowAlert then
        print("\ag[GROUP ALERT] All clear: All members are within range.")
    end
    state.previousShowAlert = state.showAlert
end

-- Manual check command - forces immediate distance check and reports results
local function manualGroupCheck()
    print("\ay[GROUP ALERT] Running manual group check...")
    local groupMembers = getGroupMemberCount()
    
    if groupMembers < 2 then
        print("\ay[GROUP ALERT] You are not in a group or group has only 1 member.")
        return
    end

    local leader = mq.TLO.Group.Leader
    if not leader or not leader.Name() then
        print("\ar[GROUP ALERT] Unable to determine group leader.")
        return
    end

    -- Cache leader's coordinates
    local leaderX, leaderY, leaderZ = leader.X(), leader.Y(), leader.Z()
    if not leaderX or not leaderY or not leaderZ then
        print("\ar[GROUP ALERT] Unable to get leader coordinates.")
        return
    end

    local withinRange = {}
    local tooFar = {}
    
    for i = 0, groupMembers - 1 do
        local member = getGroupMember(i)
        if member and member.Name() and member.Name() ~= leader.Name() then
            local memberX, memberY, memberZ = member.X(), member.Y(), member.Z()
            if memberX and memberY and memberZ then
                local distance = calculateDistance(leaderX, leaderY, leaderZ, memberX, memberY, memberZ)
                if distance > config.threshold then
                    table.insert(tooFar, string.format("%s (%.0f units)", member.Name(), distance))
                else
                    table.insert(withinRange, string.format("%s (%.0f units)", member.Name(), distance))
                end
            else
                table.insert(tooFar, member.Name() .. " (no coordinates)")
            end
        end
    end

    print("\ag[GROUP ALERT] Leader: " .. leader.Name())
    print("\ag[GROUP ALERT] Threshold: " .. config.threshold .. " units")
    
    if #withinRange > 0 then
        print("\ag[GROUP ALERT] Within range: " .. table.concat(withinRange, ", "))
    end
    
    if #tooFar > 0 then
        print("\ar[GROUP ALERT] Too far: " .. table.concat(tooFar, ", "))
    else
        print("\ag[GROUP ALERT] All members are within range!")
    end
end

-- GUI Draw function

-- Manual Cast: Call of the Heroes (E3 broadcast)
local function castCoTH()
    mq.cmd('/e3bcga /casting "Call of the Heroes"')
end

local function drawGUI()
    -- Always draw center overlay (even if main window is hidden)
    if config.enableCenterAlert and state.centerMessage ~= "" and os.time() < (state.centerUntil or 0) then
        local io = ImGui.GetIO()
        local x = io.DisplaySize.x / 2
        local y = io.DisplaySize.y * 0.20
        ImGui.SetNextWindowBgAlpha(0.35)
        ImGui.SetNextWindowPos(x, y, ImGuiCond.Always, 0.5, 0.5)
        ImGui.Begin("##GroupAlertCenterOverlay", nil,
            bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoSavedSettings,
                     ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav, ImGuiWindowFlags.NoInputs))
        
        ImGui.PushFont(ImGui.GetFont())
        ImGui.SetWindowFontScale(2.0)

        -- Bold/outline effect: draw the same text multiple times with small offsets (black),
        -- then once in fluorescent green. We then reserve layout space once with Dummy().
        local msg = state.centerMessage or ""
        local cx, cy = ImGui.GetCursorPos()
        local tsx, tsy = ImGui.CalcTextSize(msg)

        -- Outline offsets (pixels, in window space)
        local o = 1

        ImGui.SetCursorPos(cx - o, cy)
        ImGui.TextColored(0.0, 0.0, 0.0, 1.0, msg)
        ImGui.SetCursorPos(cx + o, cy)
        ImGui.TextColored(0.0, 0.0, 0.0, 1.0, msg)
        ImGui.SetCursorPos(cx, cy - o)
        ImGui.TextColored(0.0, 0.0, 0.0, 1.0, msg)
        ImGui.SetCursorPos(cx, cy + o)
        ImGui.TextColored(0.0, 0.0, 0.0, 1.0, msg)

        -- Foreground text
        ImGui.SetCursorPos(cx, cy)
        ImGui.TextColored(0.2, 1.0, 0.2, 1.0, msg)

        -- Advance cursor once (prevents extra lines from the outline passes)
        ImGui.SetCursorPos(cx, cy)
        ImGui.Dummy(tsx, tsy)

        ImGui.SetWindowFontScale(1.0)
        ImGui.PopFont()

        ImGui.End()
    end

    if not showUI then return end
    
    local open = ImGui.Begin("Group Alert " .. SCRIPT_VERSION, true)
    
    if not open then
        showUI = false
        ImGui.End()
        return
    end

    -- Status Section
    ImGui.Text("Status:")
    ImGui.Separator()
    
    local groupMembers = getGroupMemberCount()
    if groupMembers < 2 then
        ImGui.TextColored(1, 1, 0, 1, "Not in a group or only 1 member")
    else
        local leader = mq.TLO.Group.Leader
        if leader and leader.Name() then
            ImGui.Text("Leader: " .. leader.Name())
        end
        ImGui.Text("Group Members: " .. groupMembers)
        
        if state.showAlert then
            ImGui.TextColored(1, 0, 0, 1, "ALERT: Members too far!")
            ImGui.Text("Separated: " .. table.concat(state.separatedMembers, ", "))
        else
            ImGui.TextColored(0, 1, 0, 1, "All members within range")
        end
    end
    
    ImGui.Separator()
    
    -- Settings Toggle
    if ImGui.Button(showSettings and "Hide Settings" or "Show Settings") then
        showSettings = not showSettings
    end
    tooltip("Toggle settings visibility")
    
    ImGui.SameLine()
    
    
    if ImGui.Button("Manual Check") then
        checkGroupDistances()
    end
    tooltip("Force immediate distance check")

    ImGui.SameLine()

    if ImGui.Button("Cast Call of the Heroes") then
        castCoTH()
    end
    tooltip("Manually request Call of the Heroes from an available Mage in the group")

    ImGui.SameLine()

    if ImGui.Button("Exit Script") then
        terminate = true
    end
    tooltip("Close window and terminate script")

    
    -- Settings Section
    if showSettings then
        ImGui.Separator()
        ImGui.Text("Settings:")
        
        local t = ImGui.SliderInt("Distance Threshold", config.threshold, 50, 2000)
        if type(t) == "number" then
            config.threshold = t
        end
        tooltip("Maximum distance in units before alerting")
        
        local i = ImGui.SliderInt("Check Interval", config.checkInterval, 1, 30)
        if type(i) == "number" then
            config.checkInterval = i
        end
        tooltip("Seconds between automatic distance checks")
        
        local h = ImGui.Checkbox("Enable Center-Screen Alerts", config.enableCenterAlert)
        if type(h) == "boolean" then
            config.enableCenterAlert = h
        end
        tooltip("Shows a temporary center-screen alert when group members exceed the distance threshold")


        if ImGui.Button("Test Center-Screen Alert") then
            testCenterAlert()
        end
        tooltip("Sends a test /alert message to confirm center-screen alerts are working")
        
        local d = ImGui.Checkbox("Debug Mode", config.debug)
        if type(d) == "boolean" then
            config.debug = d
        end
        tooltip("Enable detailed debug logging")
        
        ImGui.Separator()
    end
    
    -- Group Member Details
    if groupMembers >= 2 then
        ImGui.Separator()
        ImGui.Text("Group Members:")
        
        ImGui.BeginChild("members", 0, 150, true)
        
        local leader = mq.TLO.Group.Leader
        if leader and leader.Name() then
            local leaderX, leaderY, leaderZ = leader.X(), leader.Y(), leader.Z()
            
            if leaderX and leaderY and leaderZ then
                for i = 0, groupMembers - 1 do
                    local member = getGroupMember(i)
                    if member and member.Name() then
                        local memberX, memberY, memberZ = member.X(), member.Y(), member.Z()
                        
                        if member.Name() == leader.Name() then
                            ImGui.TextColored(0, 0.8, 1, 1, member.Name() .. " (Leader)")
                        elseif memberX and memberY and memberZ then
                            local distance = calculateDistance(leaderX, leaderY, leaderZ, memberX, memberY, memberZ)
                            
                            if distance > config.threshold then
                                ImGui.TextColored(1, 0, 0, 1, string.format("%s - %.0f units", member.Name(), distance))
                            else
                                ImGui.TextColored(0, 1, 0, 1, string.format("%s - %.0f units", member.Name(), distance))
                            end
                        else
                            ImGui.TextColored(0.5, 0.5, 0.5, 1, member.Name() .. " (no coordinates)")
                        end
                    end
                end
            end
        end
        
        ImGui.EndChild()
    end
    
    ImGui.End()
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
    elseif args[1] == "interval" and args[2] then
        local newInterval = tonumber(args[2])
        if newInterval and newInterval > 0 then
            config.checkInterval = newInterval
            print("\agCheck interval set to " .. config.checkInterval .. " seconds")
        else
            print("\arInvalid interval value. Must be a positive number.")
        end
    elseif args[1] == "reload" then
        print("\agConfiguration reloaded.")
    elseif args[1] == "check" then
        manualGroupCheck()
    elseif args[1] == "status" then
        print("\ag[GROUP ALERT] Current Settings:")
        print("\ag  Threshold: " .. config.threshold .. " units")
        print("\ag  Check Interval: " .. config.checkInterval .. " seconds")
        print("\ag  Debug Mode: " .. (config.debug and "ON" or "OFF"))
        print("\ag  Center Alerts: " .. (config.enableCenterAlert and "ON" or "OFF"))
    elseif args[1] == "gui" then
        showUI = true
        print("\ag[GROUP ALERT] GUI opened")
    elseif args[1] == "exit" then
        terminate = true
        print("\ag[GROUP ALERT] Exiting...")
    else
        print("\ay/groupalert debug - Toggle debug mode")
        print("\ay/groupalert threshold <value> - Set distance threshold")
        print("\ay/groupalert interval <seconds> - Set check interval")
        print("\ay/groupalert check - Manually check group member distances")
        print("\ay/groupalert status - Show current settings")
        print("\ay/groupalert reload - Reload configuration")
        print("\ay/groupalert gui - Open GUI window")
        print("\ay/groupalert exit - Exit script")
    end
end

-- Bind command
mq.bind("/groupalert", groupAlertCommand)

-- Initialize ImGui
mq.imgui.init("GroupAlert", drawGUI)

-- Display credit message and version
print("\atOriginally created by Alektra <Lederhosen>")
print("\agGroup Alert Script v" .. SCRIPT_VERSION .. " Loaded")
print("\ayUse /groupalert for commands or /groupalert gui to open window")
logMessage("Script started")

-- Main loop
while not terminate and mq.TLO.MacroQuest.GameState() == "INGAME" do
    mq.doevents()
    if os.time() - state.lastCheckTime >= config.checkInterval then
        state.lastCheckTime = os.time()
        checkGroupDistances()
    end
    mq.delay(50)
end

-- Cleanup
mq.imgui.destroy("GroupAlert")
print("\ag[GROUP ALERT] Closed.")
