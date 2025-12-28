# Move the "Cast Call of the Heroes" button to sit between "Manual Check" and "Exit Script"
# Bump version to v2.3.10

import re, os

in_path = "/mnt/data/group_alert_v2.3.9_center_overlay_fullgui.lua"
s = open(in_path, "r", encoding="utf-8").read()

# Bump version
s = re.sub(r'local SCRIPT_VERSION\s*=\s*"[^"]+"', 'local SCRIPT_VERSION = "2.3.10"', s)
s = re.sub(r'-- Version:\s*\d+\.\d+\.\d+', '-- Version: 2.3.10', s)

# Remove the existing always-visible CoTH button block (near top)
s = re.sub(
    r'\s*-- Always-visible manual CoTH button \(Option C\)[\s\S]*?ImGui\.Separator\(\)\n',
    '\n',
    s,
    count=1
)

# Find the Manual Check / Exit Script button row and insert CoTH between them
pattern = r'(if ImGui\.Button\("Manual Check"\) then[\s\S]*?end\s*\n\s*ImGui\.SameLine\(\)\s*\n\s*if ImGui\.Button\("Exit Script"\) then)'
m = re.search(pattern, s)

if not m:
    raise Exception("Could not locate Manual Check / Exit Script button block")

insert = r'''if ImGui.Button("Manual Check") then
        checkGroupDistances()
    end
    tooltip("Force immediate distance check")

    ImGui.SameLine()

    if ImGui.Button("Cast Call of the Heroes") then
        castCoTH()
    end
    tooltip("Manually request Call of the Heroes from an available Mage in the group")

    ImGui.SameLine()

    if ImGui.Button("Exit Script") then'''

s = s[:m.start()] + insert + s[m.end():]

out_path = "/mnt/data/group_alert_v2.3.10_center_overlay_fullgui.lua"
with open(out_path, "w", encoding="utf-8") as f:
    f.write(s)

out_path
