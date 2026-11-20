local loadfile = dofile("tests/load_locales.lua")
local UI = {}
local frames, timers = {}, {}
local combat, reloads, imports, bars = false, 0, 0, 0
local allowImport, allowBars = true, true
local expressway = "Interface\\AddOns\\Foreverbuddyui\\Media\\Expressway.ttf"
local standardFont = "Fonts\\FRIZQT__.TTF"
local methods = {}
for _, method in ipairs({"SetPoint", "SetSize", "SetText", "SetWidth", "SetHeight", "SetWordWrap", "SetJustifyH", "SetTextColor", "SetAllPoints", "ClearAllPoints", "SetTexture", "SetColorTexture", "SetShadowColor", "SetShadowOffset", "SetFrameStrata", "EnableMouse", "SetClampedToScreen", "RegisterEvent"}) do
    methods[method] = function() end
end
function methods:SetText(text) self.text=text end
function methods:SetScript(event, callback) self[event] = callback end
function methods:Show() self.shown = true end
function methods:IsShown() return self.shown end
function methods:Hide() self.shown = false end
function methods:CreateFontString() return CreateFrame() end
function methods:CreateTexture() return CreateFrame() end
function methods:SetFont(path) self.fontPath=path;return true end
function CreateFrame()
    local frame = setmetatable({}, {__index=methods})
    frames[#frames+1] = frame
    return frame
end
UIParent = {}
SlashCmdList = {}
RAID_CLASS_COLORS = {SHAMAN = {r = 0, g = .44, b = .87}}
function UnitClass(unit)
    assert(unit == "player", "welcome color must follow the player")
    return "Shaman", "SHAMAN"
end
function InCombatLockdown() return combat end
function ReloadUI()
    assert(not combat, "reload must respect combat lockdown")
    reloads = reloads + 1
end
local width, height = 3440, 1440
function GetPhysicalScreenSize() return width, height end
C_Timer = {After=function(_, callback) timers[#timers+1] = callback end}
local fallback = {}
assert(loadfile("Style.lua"))("Foreverbuddyui", fallback)
local attempted = {}
local missingFont = {
    SetFont = function(_, path)
        attempted[#attempted+1] = path
        return path ~= expressway
    end,
}
fallback.Style.Font(missingFont, "body")
fallback.Style.Font(missingFont, "heading")
assert(#attempted == 3 and attempted[1] == expressway and attempted[2] == standardFont
    and attempted[3] == standardFont, "missing Expressway falls back once to the client font")

assert(loadfile("Style.lua"))("Foreverbuddyui", UI)
assert(loadfile("Core.lua"))("Foreverbuddyui", UI)
local toc=assert(io.open("Foreverbuddyui.toc","r")):read("*a")
assert(toc:match("## Version: ([^\r\n]+)")==UI.VERSION, "setup version must match TOC")
UI.Message = function() end
local completeSetup
UI.CompleteEditLayoutSetup = function(callback) completeSetup = callback end
UI.EnableEditLayout = function() imports = imports + 1; return allowImport end
UI.EnableActionBars = function() bars = bars + 1; return allowBars end
assert(loadfile("Welcome.lua"))("Foreverbuddyui", UI)
local events = frames[#frames]
ForeverbuddyuiDB = {positions={}}
events.OnEvent(events, "PLAYER_LOGIN")
assert(not UI.welcome and #timers == 1, "login must defer and not install")
combat = true
timers[1]()
assert(not UI.welcome and (not ForeverbuddyuiCharDB or not ForeverbuddyuiCharDB.welcomeVersion), "combat login waits")
combat = false
events.OnEvent(events, "PLAYER_REGEN_ENABLED")
assert(UI.welcome.shown and ForeverbuddyuiCharDB.welcomeVersion, "welcome shown once after combat")
assert(UI.welcome.description.fontPath == expressway, "welcome prefers the addon-local Expressway file")
assert(imports == 0 and bars == 0 and reloads == 0, "showing must not configure")
assert(UI.welcome.description.text:find("3440 × 1440 Pixel (43:18)", 1, true))
local display = UI.GetDisplayInfo()
assert(display.width == 3440 and display.height == 1440 and display.aspectRatio == 3440 / 1440)
width, height = 1920, 1080
events.OnEvent(events, "DISPLAY_SIZE_CHANGED")
assert(UI.welcome.description.text:find("1920 × 1080 Pixel (16:9)", 1, true))
width, height = 0, nil
events.OnEvent(events, "DISPLAY_SIZE_CHANGED")
assert(not UI.GetDisplayInfo() and UI.welcome.description.text:find("nicht verfügbar", 1, true))
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
assert(reloads == 0, "wait for confirmed layout activation")
combat = true
completeSetup()
assert(reloads == 0 and UI.welcome.setupButton.shown, "combat at completion leaves setup retryable")
combat = false
UI.welcome.setupButton.OnClick()
completeSetup()
assert(reloads == 0 and ForeverbuddyuiDB.enabled and ForeverbuddyuiCharDB.welcomeVersion,
    "successful setup waits for a new click before reloading")
assert(UI.welcome.description.text:find("/reload", 1, true))
events.OnEvent(events, "DISPLAY_SIZE_CHANGED")
assert(UI.welcome.description.text:find("/reload", 1, true), "resize preserves completion text")
local beforeReloadClick = imports
combat = true
UI.welcome.setupButton.OnClick()
assert(reloads == 0)
combat = false
UI.welcome.setupButton.OnClick()
assert(reloads == 1 and imports == beforeReloadClick, "reload click must not reapply the layout")
UI.welcome.closeButton.OnClick()
events.OnEvent(events, "PLAYER_REGEN_ENABLED")
assert(not UI.welcome.shown and reloads == 1, "closing or leaving combat must not reopen or reload")
ForeverbuddyuiCharDB = {}
ForeverbuddyuiDB = {enabled=false}
UI.ShowWelcome()
assert(not UI.welcome.shown and not ForeverbuddyuiCharDB.welcomeVersion, "disabled addon stays quiet")
ForeverbuddyuiDB = {positions={}}
local before=imports
SlashCmdList.FOREVERBUDDYUI("on")
assert(UI.welcome.shown and imports==before, "on opens warning without overwriting")
UI.welcome.closeButton.OnClick()
UI.ShowWelcome()
assert(not UI.welcome.shown, "same version stays dismissed")
UI.VERSION="99.0.0"
UI.ShowWelcome()
assert(UI.welcome.shown and ForeverbuddyuiCharDB.welcomeVersion=="99.0.0", "version update reopens setup")
UI.welcome.closeButton.OnClick()
ForeverbuddyuiCharDB={}
ForeverbuddyuiDB={positions={},welcomeSeen=true}
UI.ShowWelcome()
assert(UI.welcome.shown, "old boolean does not suppress version setup")

print("PASS: first-login setup, combat deferral, no automatic configuration, retry, dismissal and confirmed setup reload")

assert(toc:find("## SavedVariablesPerCharacter: ForeverbuddyuiCharDB",1,true))
UI.welcome.closeButton.OnClick()
local firstCharacter=ForeverbuddyuiCharDB
ForeverbuddyuiDB.welcomeVersion=UI.VERSION
ForeverbuddyuiCharDB=nil
UI.ShowWelcome()
assert(UI.welcome.shown and ForeverbuddyuiCharDB~=firstCharacter, "new character must show setup despite account acknowledgement")
local secondCharacter=ForeverbuddyuiCharDB
UI.welcome.closeButton.OnClick()
ForeverbuddyuiCharDB=firstCharacter
UI.ShowWelcome()
assert(not UI.welcome.shown, "returning character keeps its own acknowledgement")
UI.VERSION="100.0.0"
UI.ShowWelcome()
assert(UI.welcome.shown and firstCharacter.welcomeVersion==UI.VERSION)
UI.welcome.closeButton.OnClick()
ForeverbuddyuiCharDB=secondCharacter
UI.ShowWelcome()
assert(UI.welcome.shown and secondCharacter.welcomeVersion==UI.VERSION, "update must show independently on each character")
UI.welcome.closeButton.OnClick()
UI.ShowWelcome()
assert(not UI.welcome.shown, "reload on same character/version must stay quiet")
print("PASS: per-character persistence, new character, account migration, returning character and version update on both characters")
