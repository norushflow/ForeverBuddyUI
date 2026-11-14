local addonName, UI = ...
local L = UI.L
local Style = UI.Style
UI.VERSION = C_AddOns.GetAddOnMetadata(addonName, "Version")
-- Setup acknowledgement belongs to this character, not the account layout.
function UI.GetCharacterSettings()
    ForeverbuddyuiCharDB = ForeverbuddyuiCharDB or {}
    return ForeverbuddyuiCharDB
end
function UI.Public(value)
    return not (issecretvalue and issecretvalue(value))
end
-- Spezialisierungen sind optional; fehlende APIs liefern keine Retail-Annahme.
function UI.GetSpecialization()
    if type(C_SpecializationInfo) ~= "table" or type(C_SpecializationInfo.GetSpecialization) ~= "function" then return nil end
    local ok, spec = pcall(C_SpecializationInfo.GetSpecialization)
    if ok and UI.Public(spec) and type(spec) == "number" then return spec end
end
-- Auch Methoden-/Feldauflösung fremder Frames gehört in den Schutzblock.
function UI.Foreign(frame, action)
    if not UI.Public(frame) or not frame then return false end
    return pcall(function()
        local forbidden = frame:IsForbidden()
        if not UI.Public(forbidden) or forbidden then error("forbidden") end
        return action(frame)
    end)
end
function UI.Text(parent, size, point, relative, x, y, color, flags)
    local text = Style.Text(parent, size, color, flags)
    text:SetPoint(point, relative or parent, point, x or 0, y or 0)
    return text
end
-- Pure Lua frames: no BackdropTemplate OnSizeChanged handler (secret geometry).
function UI.Panel(parent, width, height)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(width, height)
    return Style.Panel(panel)
end
function UI.StyleStatusBar(bar)
    Style.Bar(bar)
    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(bar)
    background:SetColorTexture(unpack(Style.Color.inset))
end
function UI.Message(text)
    print(Style.Hex(Style.Color.gold) .. "ForeverBuddyUI:|r " .. text)
end
function UI.Anchor(frame, key, point, x, y, relative, relativePoint)
    frame:ClearAllPoints()
    local position = ForeverbuddyuiDB.positions[key]
    if position then
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", position.x, position.y)
    else
        frame:SetPoint(point, relative or UIParent, relativePoint or point, x, y)
    end
end
local questAnchorPending
local function anchorQuestDialog(dialog)
    UI.Foreign(dialog, function(frame)
        if not frame:IsShown() then return end
        if frame == GossipFrame and C_GossipInfo.GetNumAvailableQuests() == 0
            and C_GossipInfo.GetNumActiveQuests() == 0 then return end
        if InCombatLockdown() and frame:IsProtected() then
            questAnchorPending = true
            return
        end
        local inset = -250 / frame:GetScale()
        local horizontalOffset = inset - frame:GetWidth() / 2
        frame:ClearAllPoints()
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", horizontalOffset, inset)
    end)
end

local function anchorOpenQuestDialogs()
    anchorQuestDialog(QuestFrame)
    anchorQuestDialog(GossipFrame)
end

local function watchQuestDialog(dialog)
    UI.Foreign(dialog, function(frame)
        frame:HookScript("OnShow", anchorQuestDialog)
    end)
end

local events = CreateFrame("Frame")
for _, event in ipairs({
    "PLAYER_LOGIN", "PLAYER_REGEN_ENABLED",
    "DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED", "PLAYER_ENTERING_WORLD",
    "GROUP_ROSTER_UPDATE", "ADDON_LOADED",
}) do
    events:RegisterEvent(event)
end

-- Blizzard can apply its own Edit-Mode/bar layout after our handler has already
-- run, which leaves the bars misplaced until the next layout pass (previously
-- the end of the first fight). Reapply shortly after zone, scale and roster
-- changes, but only outside combat.
local REAPPLY = {
    PLAYER_ENTERING_WORLD = true,
    UI_SCALE_CHANGED = true,
    DISPLAY_SIZE_CHANGED = true,
}
function UI.ReapplySoon()
    for _, delay in ipairs({0.6, 2}) do
        C_Timer.After(delay, function()
            if UI.started and not InCombatLockdown() then UI.ApplyLayout() end
        end)
    end
end

local raidState, groupUpdatePending
local function inRaid()
    return IsInRaid ~= nil and IsInRaid() == true
end
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        ForeverbuddyuiDB = ForeverbuddyuiDB or {}
        ForeverbuddyuiDB.positions = ForeverbuddyuiDB.positions or {}
        UI.ReportEditLayoutResult()
        if ForeverbuddyuiDB.enabled == false then return end
        if InCombatLockdown() then UI.pendingStart = true; return end
        UI.Start()
    elseif event == "PLAYER_REGEN_ENABLED" and UI.pendingStart then
        UI.pendingStart = nil
        UI.Start()
    elseif event == "ADDON_LOADED" then
        -- Nachgeladenes Blizzard_EditMode: Schließen-Hook einmalig nachziehen.
        if UI.started then
            UI.WatchEditMode()
            UI.QueueNativeGroupMask()
        end
    elseif UI.started then
        local rosterUpdate = event == "GROUP_ROSTER_UPDATE"
        if InCombatLockdown() then
            -- Unit data and secure visibility still update on their own.
            if rosterUpdate then groupUpdatePending = true end
            return
        end
        if event == "PLAYER_REGEN_ENABLED" and questAnchorPending then
            questAnchorPending = nil
            anchorOpenQuestDialogs()
        end
        local reapply = REAPPLY[event]
        if rosterUpdate or groupUpdatePending then
            UI.QueueNativeGroupMask()
            local raid = inRaid()
            local raidChanged = raid ~= raidState
            raidState = raid
            if groupUpdatePending then
                groupUpdatePending = nil
                UI.RefreshGroupUnits(raid)
            end
            if rosterUpdate and not raidChanged then
                UI.PositionRaid()
                return
            end
            reapply = reapply or raidChanged
        end
        UI.ApplyLayout()
        if reapply then UI.ReapplySoon() end
    end
end)
function UI.Start()
    if UI.started then return end
    if not ForeverbuddyuiDB.bossFocusLayout018 then
        local bossPosition = ForeverbuddyuiDB.positions.bosses
        if bossPosition then bossPosition.x = bossPosition.x - 360 end
        ForeverbuddyuiDB.positions.focus = nil
        ForeverbuddyuiDB.bossFocusLayout018 = true
    end
    if not ForeverbuddyuiDB.bossFocusLayout019 then
        for _, key in ipairs({"bosses", "focus"}) do
            local position = ForeverbuddyuiDB.positions[key]
            if position then position.y = position.y - 100 end
        end
        ForeverbuddyuiDB.bossFocusLayout019 = true
    end
    if not ForeverbuddyuiDB.combatLayout024 then
        -- Retain the previous group row's height as the centre layout origin.
        local group = ForeverbuddyuiDB.positions.group
        if group then
            ForeverbuddyuiDB.positions.combatOrigin = {x=group.x, y=group.y-7}
        end
        for _, key in ipairs({"player", "target", "group"}) do
            ForeverbuddyuiDB.positions[key] = nil
        end
        ForeverbuddyuiDB.combatLayout024 = true
    end
    if not ForeverbuddyuiDB.upperUnits026 then
        ForeverbuddyuiDB.positions.player = nil
        ForeverbuddyuiDB.positions.target = nil
        ForeverbuddyuiDB.upperUnits026 = true
    end
    if not ForeverbuddyuiDB.combatOffset028 then
        -- Stored positions are absolute; relative attachments follow the block
        -- automatically and must not receive the offset a second time.
        for _, key in ipairs({"combatOrigin", "player", "target", "group"}) do
            local position = ForeverbuddyuiDB.positions[key]
            if position then position.y = position.y + 10 end
        end
        ForeverbuddyuiDB.combatOffset028 = true
    end
    UI.CreateUnits()
    UI.CreateLayout()
    UI.ApplyLayout()
    UI.started = true
    watchQuestDialog(QuestFrame)
    watchQuestDialog(GossipFrame)
    if type(UpdateUIPanelPositions) == "function" then
        hooksecurefunc("UpdateUIPanelPositions", anchorOpenQuestDialogs)
    end
    UI.InstallEquipment()
    raidState = inRaid()
    UI.Message(L["Version %s (Forever) geladen. /fbui zeigt die Hilfe."]:format(UI.VERSION))
end
-- Only the explicit on command changes Blizzard options.
function UI.EnableActionBars()
    if InCombatLockdown() then return false end
    local ok = pcall(function()
        assert(Settings and Settings.GetValue and Settings.SetValue)
        local current = {}
        for bar=2,4 do
            local value = Settings.GetValue("PROXY_SHOW_ACTIONBAR_"..bar)
            assert(UI.Public(value) and type(value)=="boolean")
            current[bar] = value
        end
        for bar=2,4 do
            if not current[bar] then Settings.SetValue("PROXY_SHOW_ACTIONBAR_"..bar, true) end
        end
        for bar=2,4 do
            local value = Settings.GetValue("PROXY_SHOW_ACTIONBAR_"..bar)
            assert(UI.Public(value) and value==true)
        end
    end)
    if not ok then UI.Message(L["Aktionsleisten konnten nicht aktiviert werden. Bitte die WoW-Optionen prüfen."]) end
    return ok
end
-- Called only by the explicit setup button after displaying the overwrite warning.
function UI.RunSetup()
    if InCombatLockdown() then UI.Message(L["Bitte nach dem Kampf erneut versuchen."]); return end
    if not UI.EnableActionBars() then return end
    if not UI.EnableEditLayout() then return end
    UI.CompleteEditLayoutSetup(function()
        UI.GetCharacterSettings().welcomeVersion = UI.VERSION
        ForeverbuddyuiDB.enabled = true
        UI.ShowSetupComplete()
    end)
end

SLASH_FOREVERBUDDYUI1 = "/fbui"
SlashCmdList.FOREVERBUDDYUI = function(message)
    local command = (message or ""):lower():match("^%s*(.-)%s*$")
    if InCombatLockdown() then UI.Message(L["Bitte nach dem Kampf erneut versuchen."]); return end
    if command == "restore" then
        if UI.ActionStorage then UI.ActionStorage.RestoreCharacter() end
    elseif command == "layoutstatus" then
        if type(UI.PrintEditLayoutStatus) == "function" then
            UI.PrintEditLayoutStatus()
        else
            UI.Message(L["Layoutstatus: EditLayout.lua fehlt oder ist veraltet. Bitte Addon-Dateien vollständig ersetzen."])
        end
    elseif command == "blizzard" then
        UI.editLayoutPending = nil
        ForeverbuddyuiDB.enabled = false
        UI.Message(L["Neustart ohne UI-Eingriffe. Danach Blizzard-Bearbeitungsmodus normal öffnen; zurück mit /fbui on."])
        ReloadUI()
    elseif command == "on" then
        UI.ShowWelcome(true)
    elseif command == "off" then
        UI.editLayoutPending = nil
        ForeverbuddyuiDB.enabled = false
        ReloadUI()
    elseif not UI.started then
        UI.Message(L["Deaktiviert. Mit /fbui on einschalten."])
    elseif command == "" then
        UI.Message(L["/fbui reset · restore · raidtest 20 · raidtest off · blizzard · off · on · layoutstatus. Aktionsleisten verwaltet die Blizzard-UI."])
    elseif command == "raidtest" or command:match("^raidtest%s") then
        UI.RaidTest(command:match("^raidtest%s*(.*)$"))
    elseif command == "reset" then
        ForeverbuddyuiDB.positions = {}
        UI.ApplyLayout()
    else
        UI.Message(L["/fbui reset · restore · raidtest 20 · raidtest off · blizzard · off · on · layoutstatus. Aktionsleisten verwaltet die Blizzard-UI."])
    end
end
