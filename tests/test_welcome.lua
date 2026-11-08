local UI = {}
local frames, timers = {}, {}
local combat, reloads, imports, bars = false, 0, 0, 0
local allowImport, allowBars = true, true
local methods = {}
for _, method in ipairs({"SetPoint", "SetSize", "SetText", "SetWidth", "SetWordWrap", "SetTextColor", "SetFrameStrata", "EnableMouse", "SetClampedToScreen", "RegisterEvent"}) do
    methods[method] = function() end
end
function methods:SetText(text) self.text=text end
function methods:SetScript(event, callback) self[event] = callback end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function CreateFrame()
    local frame = setmetatable({}, {__index=methods})
    frames[#frames+1] = frame
    return frame
end
UIParent = {}
SlashCmdList = {}
function InCombatLockdown() return combat end
function ReloadUI() reloads = reloads + 1 end
C_Timer = {After=function(_, callback) timers[#timers+1] = callback end}
assert(loadfile("Core.lua"))("Foreverbuddyui", UI)
local toc=assert(io.open("Foreverbuddyui.toc","r")):read("*a")
assert(toc:match("## Version: ([^\r\n]+)")==UI.VERSION, "setup version must match TOC")
UI.Panel = CreateFrame
UI.Text = CreateFrame
UI.Message = function() end
UI.CompleteEditLayoutSetup = function(callback) callback() end
UI.EnableEditLayout = function() imports = imports + 1; return allowImport end
UI.EnableActionBars = function() bars = bars + 1; return allowBars end
assert(loadfile("Welcome.lua"))("Foreverbuddyui", UI)
local events = frames[#frames]
ForeverbuddyuiDB = {positions={}}
events.OnEvent(events, "PLAYER_LOGIN")
assert(not UI.welcome and #timers == 1, "login must defer and not install")
combat = true
timers[1]()
assert(not UI.welcome and not ForeverbuddyuiDB.welcomeVersion, "combat login waits")
combat = false
events.OnEvent(events, "PLAYER_REGEN_ENABLED")
assert(UI.welcome.shown and ForeverbuddyuiDB.welcomeVersion, "welcome shown once after combat")
assert(imports == 0 and bars == 0 and reloads == 0, "showing must not configure")
local warning=false
for _,frame in ipairs(frames) do if frame.text=="Vorsicht: Layout wird überschrieben!" then warning=true end end
assert(warning and UI.welcome.description.text:find("gehen verloren",1,true), "overwrite warning must be visible before setup")
combat = true
UI.welcome.setupButton.OnClick()
assert(imports == 0 and reloads == 0, "setup must respect combat guard")
combat = false
allowImport = false
UI.welcome.setupButton.OnClick()
assert(reloads == 0 and UI.welcome.shown, "failed setup stays retryable")
allowImport = true
UI.welcome.setupButton.OnClick()
assert(reloads == 0 and ForeverbuddyuiDB.enabled and ForeverbuddyuiDB.welcomeVersion, "setup must not reload from completion callback")
assert(UI.welcome.description.text:find("/reload",1,true) and not UI.welcome.setupButton.shown, "completion asks for manual reload")
UI.welcome.closeButton.OnClick()
events.OnEvent(events, "PLAYER_REGEN_ENABLED")
assert(not UI.welcome.shown, "dismissed welcome must not reopen")
ForeverbuddyuiDB = {enabled=false}
UI.ShowWelcome()
assert(not UI.welcome.shown and not ForeverbuddyuiDB.welcomeVersion, "disabled addon stays quiet")
ForeverbuddyuiDB = {positions={}}
local before=imports
SlashCmdList.FOREVERBUDDYUI("on")
assert(UI.welcome.shown and imports==before, "on opens warning without overwriting")
UI.welcome.closeButton.OnClick()
UI.ShowWelcome()
assert(not UI.welcome.shown, "same version stays dismissed")
UI.VERSION="99.0.0"
UI.ShowWelcome()
assert(UI.welcome.shown and ForeverbuddyuiDB.welcomeVersion=="99.0.0", "version update reopens setup")
UI.welcome.closeButton.OnClick()
ForeverbuddyuiDB={positions={},welcomeSeen=true}
UI.ShowWelcome()
assert(UI.welcome.shown, "old boolean does not suppress version setup")

print("PASS: first-login setup, combat deferral, no automatic configuration, retry, dismissal and manual setup")
