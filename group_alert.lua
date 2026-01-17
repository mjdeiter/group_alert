-- Group Alert Script for MacroQuest
-- Monitors group member distances and alerts via HUD when members are too far from the leader
-- Version: 2.3.14

local mq = require('mq')
local ImGui = require('ImGui')
local SCRIPT_VERSION = "2.3.14"

-- Configuration
local config = {
    threshold = 500,         -- Distance threshold in units
    checkInterval = 5,       -- Interval in seconds between checks
    enableCenterAlert = true, -- Enable/disable center-screen /alert
    debug = false,           -- Enable debug output

    -- EQ-style overlay shadow offset (pixels)
    shadowOffsetX = 1,
    shadowOffsetY = 1,

    -- Overlay-only font option (pixel-ish)
    useOverlayFont = true,
    overlayFontSize = 28,

    -- UI options
    hideButtons = false      -- Hide buttons to allow smaller window size
}

-- ============================
-- Persistent Config (INI)
-- Saved to: <MQ Config Dir>/GroupAlert.ini
-- ============================
local CONFIG_FILE = mq.configDir .. "/GroupAlert.ini"

local function loadPersistentConfig()
    local f = io.open(CONFIG_FILE, "r")
    if not f then return end
    for line in f:lines() do
        local k, v = line:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
        if k and v then
            if k == "threshold" then
                local n = tonumber(v)
                if n and n > 0 then config.threshold = n end
            elseif k == "checkInterval" then
                local n = tonumber(v)
                if n and n > 0 then config.checkInterval = n end
            elseif k == "enableCenterAlert" then
                config.enableCenterAlert = (v == "true")
            elseif k == "debug" then
                config.debug = (v == "true")
            elseif k == "shadowOffsetX" then
                local n = tonumber(v)
                if n then config.shadowOffsetX = n end
            elseif k == "shadowOffsetY" then
                local n = tonumber(v)
                if n then config.shadowOffsetY = n end
            elseif k == "useOverlayFont" then
                config.useOverlayFont = (v == "true")
            elseif k == "overlayFontSize" then
                local n = tonumber(v)
                if n and n > 0 then config.overlayFontSize = n end
            elseif k == "hideButtons" then
                config.hideButtons = (v == "true")
            end
        end
    end
    f:close()
end

local function savePersistentConfig()
    local f = io.open(CONFIG_FILE, "w")
    if not f then return end
    f:write("threshold=" .. tostring(config.threshold) .. "\n")
    f:write("checkInterval=" .. tostring(config.checkInterval) .. "\n")
    f:write("enableCenterAlert=" .. tostring(config.enableCenterAlert) .. "\n")
    f:write("debug=" .. tostring(config.debug) .. "\n")
    f:write("shadowOffsetX=" .. tostring(config.shadowOffsetX) .. "\n")
    f:write("shadowOffsetY=" .. tostring(config.shadowOffsetY) .. "\n")
    f:write("useOverlayFont=" .. tostring(config.useOverlayFont) .. "\n")
    f:write("overlayFontSize=" .. tostring(config.overlayFontSize) .. "\n")
    f:write("hideButtons=" .. tostring(config.hideButtons) .. "\n")
    f:close()
end

-- Load saved settings on startup
loadPersistentConfig()

-- State variables
local state = {
    showAlert = false,
    separatedMembers = {},
    lastCheckTime = os.time(),
    previousShowAlert = false,  -- Track previous alert state
    alertActive = false,        -- Center-screen alert spam guard
    centerMessage = "",         -- Current overlay message
    centerUntil = 0,            -- os.time() when overlay should disappear

    -- Overlay foreground color (RED/GREEN)
    centerColor = {0.2, 1.0, 0.2, 1.0}
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

-- NEW (v2.3.14): actual member count by iterating until nil (fixes 5 vs 6 display)
local function getActualGroupCount()
    local n = 0
    local i = 0
    while true do
        local m = getGroupMember(i)
        if not m or not m.Name() then break end
        n = n + 1
        i = i + 1
    end
    return n
end

-- Helper for tooltips
local function tooltip(text)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(text)
    end
end

-- ============================
-- Overlay-only font load (safe fallback)
-- ============================
local overlayFont = nil
local overlayFontLoadedForSize = nil

local function tryLoadOverlayFont()
    if overlayFont and overlayFontLoadedForSize == config.overlayFontSize then return end
    overlayFont = nil
    overlayFontLoadedForSize = config.overlayFontSize

    if not config.useOverlayFont then return end

    -- Prefer Tahoma on Windows (classic, thicker strokes)
    local ok = pcall(function()
        local io = ImGui.GetIO()
        -- This path is Windows-specific; if missing, pcall keeps script safe.
        overlayFont = io.Fonts:AddFontFromFileTTF("C:/Windows/Fonts/tahoma.ttf", config.overlayFontSize)
    end)

    if not ok then
        overlayFont = nil
    end
end

-- Center-screen alert handling (no MQ2HUD)
-- Fires once per event, auto-clears when resolved.
local function fireCenterOverlay(msg, seconds, color)
    if not config.enableCenterAlert then return end
    state.centerMessage = msg or ""
    state.centerUntil = os.time() + (seconds or 3)

    -- accept overlay color
    if type(color) == "table" then
        state.centerColor = color
    end
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
        -- 🔴 RED when alert triggers
        fireCenterOverlay("GROUP ALERT: " .. table.concat(state.separatedMembers, ", "), 3, {1.0, 0.0, 0.0, 1.0})
        state.alertActive = true
    elseif (not state.showAlert) and state.alertActive then
        -- 🟢 GREEN when alert clears
        fireCenterOverlay("GROUP ALERT CLEARED", 2, {0.2, 1.0, 0.2, 1.0})
        state.alertActive = false
    end
end

local function testCenterAlert()
    -- Test uses GREEN
    fireCenterOverlay("GROUP ALERT TEST: Center overlay is working.", 3, {0.2, 1.0, 0.2, 1.0})
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

    -- FIX (v2.3.14): iterate members until nil so we don't miss the 6th member
    local i = 0
    while true do
        local member = getGroupMember(i)
        if not member or not member.Name() then break end

        if member.Name() ~= leader.Name() then
            local memberX, memberY, memberZ = member.X(), member.Y(), member.Z()
            if memberX and memberY and memberZ then
                local distance = calculateDistance(leaderX, leaderY, leaderZ, memberX, memberY, memberZ)
                if distance > config.threshold then
                    table.insert(state.separatedMembers, member.Name())
                end
            end
        end

        i = i + 1
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

-- Manual Cast: Call of the Heroes (E3 broadcast)
local function castCoTH()
    mq.cmd('/e3bcga /casting "Call of the Heroes"')
end

local function drawGUI()
    -- Always draw center overlay (even if main window is hidden)
    if config.enableCenterAlert and state.centerMessage ~= "" and os.time() < (state.centerUntil or 0) then
        tryLoadOverlayFont()

        local io = ImGui.GetIO()
        local x = io.DisplaySize.x / 2
        local y = io.DisplaySize.y * 0.20

        -- EQ-style: no background
        ImGui.SetNextWindowBgAlpha(0.0)
        ImGui.SetNextWindowPos(x, y, ImGuiCond.Always, 0.5, 0.5)

        ImGui.Begin("##GroupAlertCenterOverlay", nil,
            bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoSavedSettings,
                     ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav, ImGuiWindowFlags.NoInputs))

        if overlayFont then
            ImGui.PushFont(overlayFont)
        else
            ImGui.PushFont(ImGui.GetFont())
        end

        ImGui.SetWindowFontScale(2.0)

        local msg = state.centerMessage or ""
        local cx, cy = ImGui.GetCursorPos()

        -- single drop shadow
        ImGui.SetCursorPos(cx + (config.shadowOffsetX or 1), cy + (config.shadowOffsetY or 1))
        ImGui.TextColored(0.0, 0.0, 0.0, 1.0, msg)

        -- foreground
        local c = state.centerColor
        ImGui.SetCursorPos(cx, cy)
        ImGui.TextColored(c[1], c[2], c[3], c[4], msg)

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
    local actualMembers = getActualGroupCount()

    if groupMembers < 2 then
        ImGui.TextColored(1, 1, 0, 1, "Not in a group or only 1 member")
    else
        local leader = mq.TLO.Group.Leader
        if leader and leader.Name() then
            ImGui.Text("Leader: " .. leader.Name())
        end
        -- FIX (v2.3.14): show actual member count (6) instead of Group.Members() (often 5)
        ImGui.Text("Group Members: " .. actualMembers)

        if state.showAlert then
            ImGui.TextColored(1, 0, 0, 1, "ALERT: Members too far!")
            ImGui.Text("Separated: " .. table.concat(state.separatedMembers, ", "))
        else
            ImGui.TextColored(0, 1, 0, 1, "All members within range")
        end
    end

    ImGui.Separator()

    -- Hide Buttons Checkbox (always visible)
    local hb = ImGui.Checkbox("Hide Buttons", config.hideButtons)
    if type(hb) == "boolean" then
        config.hideButtons = hb
        savePersistentConfig()
    end
    tooltip("Hide buttons to allow smaller window size (saved)")

    -- Only show buttons if not hidden
    if not config.hideButtons then
        -- Settings Toggle
        if ImGui.Button(showSettings and "Hide Settings" or "Show Settings") then
            showSettings = not showSettings
        end
        tooltip("Toggle settings visibility")

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
    end

    -- Settings Section
    if showSettings then
        ImGui.Separator()
        ImGui.Text("Settings:")

        local t = ImGui.SliderInt("Distance Threshold", config.threshold, 50, 2000)
        if type(t) == "number" then
            config.threshold = t
            savePersistentConfig()
        end
        tooltip("Maximum distance in units before alerting (saved)")

        local i = ImGui.SliderInt("Check Interval", config.checkInterval, 1, 30)
        if type(i) == "number" then
            config.checkInterval = i
            savePersistentConfig()
        end
        tooltip("Seconds between automatic distance checks (saved)")

        local h = ImGui.Checkbox("Enable Center-Screen Alerts", config.enableCenterAlert)
        if type(h) == "boolean" then
            config.enableCenterAlert = h
            savePersistentConfig()
        end
        tooltip("Shows a temporary center-screen alert when group members exceed the distance threshold (saved)")

        local sx = ImGui.SliderInt("Overlay Shadow X", config.shadowOffsetX, 0, 3)
        if type(sx) == "number" then
            config.shadowOffsetX = sx
            savePersistentConfig()
        end
        tooltip("EQ-style shadow offset X (pixels, saved)")

        local sy = ImGui.SliderInt("Overlay Shadow Y", config.shadowOffsetY, 0, 3)
        if type(sy) == "number" then
            config.shadowOffsetY = sy
            savePersistentConfig()
        end
        tooltip("EQ-style shadow offset Y (pixels, saved)")

        local uf = ImGui.Checkbox("Use Overlay Pixel Font (Tahoma)", config.useOverlayFont)
        if type(uf) == "boolean" then
            config.useOverlayFont = uf
            overlayFont = nil
            overlayFontLoadedForSize = nil
            savePersistentConfig()
        end
        tooltip("Overlay-only font (safe fallback if unavailable)")

        local fs = ImGui.SliderInt("Overlay Font Size", config.overlayFontSize, 18, 40)
        if type(fs) == "number" then
            config.overlayFontSize = fs
            overlayFont = nil
            overlayFontLoadedForSize = nil
            savePersistentConfig()
        end
        tooltip("Overlay-only font size (saved)")

        if ImGui.Button("Test Center-Screen Alert") then
            testCenterAlert()
        end
        tooltip("Sends a test /alert message to confirm center-screen alerts are working")

        local d = ImGui.Checkbox("Debug Mode", config.debug)
        if type(d) == "boolean" then
            config.debug = d
            savePersistentConfig()
        end
        tooltip("Enable detailed debug logging (saved)")

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
                -- FIX (v2.3.14): iterate members until nil so we don't miss the 6th member
                local idx = 0
                while true do
                    local member = getGroupMember(idx)
                    if not member or not member.Name() then break end

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

                    idx = idx + 1
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
        savePersistentConfig()
        print("\ayDebug mode " .. (config.debug and "\agON" or "\arOFF"))
    elseif args[1] == "threshold" and args[2] then
        local newThreshold = tonumber(args[2])
        if newThreshold and newThreshold > 0 then
            config.threshold = newThreshold
            savePersistentConfig()
            print("\agThreshold set to " .. config.threshold .. " (saved)")
        else
            print("\arInvalid threshold value. Must be a positive number.")
        end
    elseif args[1] == "interval" and args[2] then
        local newInterval = tonumber(args[2])
        if newInterval and newInterval > 0 then
            config.checkInterval = newInterval
            savePersistentConfig()
            print("\agCheck interval set to " .. config.checkInterval .. " seconds (saved)")
        else
            print("\arInvalid interval value. Must be a positive number.")
        end
    elseif args[1] == "reload" then
        loadPersistentConfig()
        overlayFont = nil
        overlayFontLoadedForSize = nil
        print("\agConfiguration reloaded.")
    elseif args[1] == "status" then
        print("\ag[GROUP ALERT] Current Settings:")
        print("\ag  Threshold: " .. config.threshold .. " units")
        print("\ag  Check Interval: " .. config.checkInterval .. " seconds")
        print("\ag  Debug Mode: " .. (config.debug and "ON" or "OFF"))
        print("\ag  Center Alerts: " .. (config.enableCenterAlert and "ON" or "OFF"))
        print("\ag  Shadow Offset: " .. tostring(config.shadowOffsetX) .. "," .. tostring(config.shadowOffsetY))
        print("\ag  Overlay Font: " .. (config.useOverlayFont and ("ON (" .. tostring(config.overlayFontSize) .. "px)") or "OFF"))
    elseif args[1] == "gui" then
        showUI = true
        print("\ag[GROUP ALERT] GUI opened")
    elseif args[1] == "exit" then
        terminate = true
        print("\ag[GROUP ALERT] Exiting...")
    else
        print("\ay/groupalert debug - Toggle debug mode")
        print("\ay/groupalert threshold <value> - Set distance threshold (saved)")
        print("\ay/groupalert interval <seconds> - Set check interval (saved)")
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
