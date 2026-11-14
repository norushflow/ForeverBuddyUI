local _, UI = ...
local Style = UI.Style
local frames = {}
local partyFrames = {}
-- Percent colours by remaining health. Health percentages are secret in
-- Midnight, so comparing or formatting them in Lua is barred. Instead each of
-- the three overlapping labels gets a step-curve result as its alpha: the
-- native UnitHealthPercent curve evaluation does the thresholding, the addon
-- never reads the value. Boundaries sit at the display rounding edge so 40 %
-- stays red and 41 % turns yellow.
local function alphaCurve(points)
    if not C_CurveUtil or not C_CurveUtil.CreateCurve or not Enum or not Enum.LuaCurveType then return nil end
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    for _, point in ipairs(points) do curve:AddPoint(point[1], point[2]) end
    return curve
end
local percentAlpha = {
    low = alphaCurve({{0, 1}, {.405, 0}}),
    warn = alphaCurve({{0, 0}, {.405, 1}, {.755, 0}}),
    high = alphaCurve({{0, 0}, {.755, 1}}),
}
local function setPercentFont(frame, size)
    Style.Font(frame.percent, size)
    if frame.percentWarn then Style.Font(frame.percentWarn, size) end
    if frame.percentLow then Style.Font(frame.percentLow, size) end
end
local function bar(parent, x, y, width, height)
    local status = CreateFrame("StatusBar", nil, parent)
    status:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    status:SetSize(width, height)
    UI.StyleStatusBar(status)
    status:SetMinMaxValues(0, 1)
    return status
end
local function update(frame)
    local unit = frame.unit
    -- Health and power may be secret in Midnight: pass straight to native widgets.
    frame.health:SetMinMaxValues(0, UnitHealthMax(unit))
    frame.health:SetValue(UnitHealth(unit))
    frame.power:SetMinMaxValues(0, UnitPowerMax(unit))
    frame.power:SetValue(UnitPower(unit))
    frame.name:SetText(UnitName(unit))
    if UnitHealthPercent and CurveConstants and CurveConstants.ScaleTo100 then
        -- Pass the value straight to the widget. Midnight renders protected
        -- numbers there; reading or formatting them ourselves is what is barred.
        local percent = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
        frame.percent:SetFormattedText("%.0f%%", percent)
        if frame.percentWarn and percentAlpha.warn then
            frame.percentWarn:SetFormattedText("%.0f%%", percent)
            frame.percentLow:SetFormattedText("%.0f%%", percent)
            frame.percentLow:SetAlpha(UnitHealthPercent(unit, true, percentAlpha.low))
            frame.percentWarn:SetAlpha(UnitHealthPercent(unit, true, percentAlpha.warn))
            frame.percent:SetAlpha(UnitHealthPercent(unit, true, percentAlpha.high))
        end
    end
    local _, class = UnitClass(unit)
    local color = UI.Public(class) and class and RAID_CLASS_COLORS[class]
    if unit == "pet" then
        frame.health:SetStatusBarColor(.04, .6, .08)
    elseif color then
        frame.health:SetStatusBarColor(color.r, color.g, color.b)
    elseif unit == "target" or unit == "focus" or unit:match("^boss") then
        frame.health:SetStatusBarColor(.68, .035, .09)
    else
        frame.health:SetStatusBarColor(.13, .57, .7)
    end
    local _, token = UnitPowerType(unit)
    local powerColor = UI.Public(token) and token and PowerBarColor[token]
    if powerColor then frame.power:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
    else frame.power:SetStatusBarColor(.15, .55, 1) end
    if frame.role then
        local role = UnitGroupRolesAssigned(unit)
        if UI.Public(role) then
            frame.role:SetText(role == "TANK" and "T" or role == "HEALER" and "+" or "")
        else frame.role:SetText("") end
    end
end
local function unitFrame(unit, width, height, compact, parent)
    local frame = CreateFrame("Button", "Foreverbuddyui_"..unit..(compact and "Group" or ""), parent, "SecureUnitButtonTemplate")
    frame.unit = unit
    frame:SetSize(width, height)
    -- Use the same marble inset and border as ForeverBuddy's content panels.
    local stone = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
    stone:SetAllPoints(frame)
    stone:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")
    if stone.SetHorizTile then stone:SetHorizTile(true) end
    if stone.SetVertTile then stone:SetVertTile(true) end
    Style.Panel(frame)
    frame.background:SetColorTexture(unpack(Style.Color.inset))
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("type1", "target")
    frame:SetAttribute("type2", "togglemenu")
    frame:RegisterForClicks("AnyUp")
    frame.health = bar(frame, 2, -2, width-4, height-7)
    frame.power = bar(frame, 2, -(height-4), width-4, 2)
    -- Text belongs to a separate overlay, never anchors to a secret status bar.
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    overlay:SetFrameLevel(frame.health:GetFrameLevel()+2)
    -- Static translucent shading; never inspect or anchor to secret health fills.
    local sheen = overlay:CreateTexture(nil, "ARTWORK")
    sheen:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    sheen:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 5)
    sheen:SetTexture(Style.WHITE)
    sheen:SetGradient("VERTICAL", CreateColor(0, 0, 0, .28), CreateColor(0, 0, 0, .12))
    frame.name = UI.Text(overlay, compact and 10 or 20, compact and "CENTER" or "LEFT", nil, compact and 0 or 7, compact and 4 or 1)
    frame.name:SetWidth(compact and width-6 or width-74)
    frame.name:SetWordWrap(false)
    frame.name:SetJustifyH(compact and "CENTER" or "LEFT")
    frame.percent = UI.Text(overlay, compact and 11 or 19, compact and "BOTTOM" or "RIGHT", nil, compact and 0 or -6, compact and 8 or 0)
    frame.percent:SetTextColor(.2, 1, .05)
    if percentAlpha.warn then
        local size = compact and 11 or 19
        local point = compact and "BOTTOM" or "RIGHT"
        local x = compact and 0 or -6
        local y = compact and 8 or 0
        frame.percentWarn = UI.Text(overlay, size, point, nil, x, y)
        frame.percentWarn:SetTextColor(1, .82, .1)
        frame.percentLow = UI.Text(overlay, size, point, nil, x, y)
        frame.percentLow:SetTextColor(.92, .12, .09)
    end
    if compact then
        frame.role = UI.Text(overlay, 11, "TOPLEFT", nil, 3, 5)
        if UI.CreateGroupDebuffs(frame) then
            -- Keep names/percentages above the native bottom-row debuffs.
            frame.name:ClearAllPoints()
            frame.name:SetPoint("CENTER", overlay, "CENTER", 0, 6)
            for _, text in ipairs({frame.percent, frame.percentWarn, frame.percentLow}) do
                text:ClearAllPoints()
                text:SetPoint("BOTTOM", overlay, "BOTTOM", 0, 17)
            end
        end
    end
    frame:SetScript("OnEnter", function(self)
        UI.ShowUnitTooltip(self, compact)
    end)
    frame:SetScript("OnLeave", UI.HideUnitTooltip)
    frame:SetScript("OnEvent", function(self) update(self) end)
    for _, event in ipairs({"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE", "UNIT_CONNECTION"}) do
        frame:RegisterUnitEvent(event, unit)
    end
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    if unit == "target" or unit == "targettarget" then frame:RegisterEvent("PLAYER_TARGET_CHANGED") end
    if unit == "focus" then frame:RegisterEvent("PLAYER_FOCUS_CHANGED") end
    if unit:match("^boss") then frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT") end
    if unit == "targettarget" then
        frame:RegisterUnitEvent("UNIT_TARGET", "target")
        -- Ziel-des-Ziels ändert sich auch ohne PLAYER_TARGET_CHANGED. Statt
        -- eines dauerhaften OnUpdate läuft ein 0,2-s-Ticker nur bei sichtbarer
        -- Anzeige; Poll bleibt der testbare Einzelabruf.
        local poll
        local function stopPoll()
            if poll and poll.Cancel then pcall(poll.Cancel, poll) end
            poll = nil
        end
        local function syncPoll()
            if not frame:IsShown() then stopPoll(); return end
            if poll then return end
            poll = C_Timer.NewTicker(.2, function() update(frame) end)
        end
        frame.Poll = function() update(frame) end
        frame.SyncPoll = syncPoll
        frame:SetScript("OnShow", syncPoll)
        frame:SetScript("OnHide", stopPoll)
    end
    frames[#frames+1] = frame
    return frame
end
local function auraAccessAllowed()
    -- Check BEFORE calling the restricted API, not after receiving its result.
    -- On builds without the predicate, do not guess whether access is permitted.
    if InCombatLockdown() then return false end
    if not C_Secrets or not C_Secrets.ShouldAurasBeSecret then return false end
    local restricted = C_Secrets.ShouldAurasBeSecret()
    return UI.Public(restricted) and not restricted
end
local function addAuras(parent, unit, count, size, filter, offset)
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    -- These are unprotected children: aura visibility never controls the unit button.
    local host = CreateFrame("Frame", nil, parent)
    host:SetSize(count*(size+2), size)
    host:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, offset)
    local icons = {}
    for i=1,count do
        local icon = CreateFrame("Frame", nil, host)
        icon:SetSize(size, size)
        icon:SetPoint("LEFT", host, "LEFT", (i-1)*(size+2), 0)
        icon.image = icon:CreateTexture(nil, "ARTWORK")
        icon.image:SetAllPoints()
        icon.image:SetTexCoord(.07, .93, .07, .93)
        Style.Border(icon, Style.Color.border, "OVERLAY")
        icon:EnableMouse(true)
        icon:SetScript("OnEnter", function(self)
            if not auraAccessAllowed() then UI.HideUnitTooltip(); return end
            UI.Foreign(GameTooltip, function(tooltip)
                tooltip:SetOwner(self, "ANCHOR_RIGHT")
                tooltip:SetUnitAura(unit, i, filter)
            end)
        end)
        icon:SetScript("OnLeave", UI.HideUnitTooltip)
        icons[i] = icon
    end
    local function refresh()
        if not auraAccessAllowed() then
            for _, icon in ipairs(icons) do icon:Hide() end
            return
        end
        for i, icon in ipairs(icons) do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
            if UI.Public(aura) and aura then
                icon.image:SetTexture(aura.icon)
                icon:Show()
            else
                icon:Hide()
            end
        end
    end
    host:RegisterUnitEvent("UNIT_AURA", unit)
    host:RegisterEvent("PLAYER_ENTERING_WORLD")
    host:RegisterEvent("PLAYER_REGEN_DISABLED")
    host:RegisterEvent("PLAYER_REGEN_ENABLED")
    host:RegisterEvent("ENCOUNTER_START")
    host:RegisterEvent("ENCOUNTER_END")
    -- Encounter-/Kampf-/PvP-Einschränkungen können sich ohne UNIT_AURA ändern.
    -- Statt eines dauerhaften OnUpdate löst jedes registrierte Ereignis genau
    -- einen kurzen Nachlauf aus, der sich danach selbst beendet.
    local followUp
    local function onAuraEvent()
        refresh()
        if followUp then return end
        followUp = true
        C_Timer.After(.5, function()
            followUp = nil
            refresh()
        end)
    end
    host.RefreshAuras = refresh
    host:RegisterEvent("GROUP_ROSTER_UPDATE")
    if unit == "target" then host:RegisterEvent("PLAYER_TARGET_CHANGED") end
    if unit == "focus" then host:RegisterEvent("PLAYER_FOCUS_CHANGED") end
    if unit:match("^boss") then host:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT") end
    host:SetScript("OnEvent", onAuraEvent)
    refresh()
end
function UI.CreateUnits()
    -- Stable anchor for the three action rows, independent of target visibility.
    UI.combatAnchor = CreateFrame("Frame", nil, UIParent)
    UI.combatAnchor:SetSize(264, 112)
    -- Secure group/raid buttons depend on this static layout frame, never on
    -- the cast bar whose visibility changes during combat.
    UI.playerCastAnchor = CreateFrame("Frame", nil, UIParent)
    UI.playerCastAnchor:SetSize(264, 18)
    UI.player = unitFrame("player", 300, 46, false, UIParent)
    UI.target = unitFrame("target", 300, 46, false, UIParent)
    UI.targettarget = unitFrame("targettarget", 148, 28, false, UIParent)
    Style.Font(UI.targettarget.name, 12)
    setPercentFont(UI.targettarget, 11)
    RegisterStateDriver(UI.targettarget, "visibility", "[petbattle] hide; [@targettarget,exists] show; hide")
    UI.focus = unitFrame("focus", 240, 38, false, UIParent)
    Style.Font(UI.focus.name, 15)
    setPercentFont(UI.focus, 14)
    RegisterStateDriver(UI.focus, "visibility", "[petbattle] hide; [@focus,exists] show; hide")
    addAuras(UI.focus, "focus", 10, 15, "HARMFUL", -3)
    UI.bossAnchor = CreateFrame("Frame", nil, UIParent)
    UI.bossAnchor:SetSize(240, (MAX_BOSS_FRAMES or 5)*88)
    UI.bosses = {}
    for i=1,MAX_BOSS_FRAMES or 5 do
        local unit = "boss"..i
        local boss = unitFrame(unit, 240, 38, false, UI.bossAnchor)
        Style.Font(boss.name, 15)
        setPercentFont(boss, 14)
        boss:SetPoint("TOPLEFT", UI.bossAnchor, "TOPLEFT", 0, -(i-1)*88)
        RegisterStateDriver(boss, "visibility", "[petbattle] hide; [@"..unit..",exists] show; hide")
        addAuras(boss, unit, 10, 15, "HARMFUL", -3)
        UI.bosses[i] = boss
    end
    UI.pet = unitFrame("pet", 148, 28, false, UIParent)
    Style.Font(UI.pet.name, 12)
    setPercentFont(UI.pet, 11)
    RegisterStateDriver(UI.pet, "visibility", "[petbattle] hide; [vehicleui] hide; [@pet,exists] show; hide")
    addAuras(UI.target, "target", 12, 15, "HELPFUL", -4)
    addAuras(UI.target, "target", 12, 15, "HARMFUL", -22)
    UI.group = CreateFrame("Frame", "ForeverbuddyuiGroup", UIParent, "SecureHandlerStateTemplate")
    UI.group:SetSize(441, 90)
    -- The secure driver controls the row, and each fixed slot follows its unit.
    -- Keep visibility independent of the layout work deferred during combat.
    RegisterStateDriver(UI.group, "visibility",
        "[petbattle][vehicleui][group:raid][@raid1,exists] hide; [group:party][@party1,exists] show; hide")
    local units = {"party1", "party2", "party3", "party4", "player"}
    for i, unit in ipairs(units) do
        local frame = unitFrame(unit, 56, 58, true, UI.group)
        frame:SetScale(1.5)
        frame:SetPoint("LEFT", UI.group, "LEFT", (i-1)*59, 0)
        frame:SetScript("OnShow", update)
        RegisterUnitWatch(frame)
        partyFrames[i] = frame
    end
    RegisterStateDriver(UI.player, "visibility", "[petbattle] hide; [vehicleui] hide; show")
    RegisterStateDriver(UI.target, "visibility", "[petbattle] hide; [@target,exists] show; hide")
    -- Own raid grid; debuffs are rendered by Blizzard's private containers,
    -- without per-member aura queries or addon refresh timers.
    UI.raidAnchor = CreateFrame("Frame", "ForeverbuddyuiRaid", UIParent)
    -- Five slots per row, matching the group row, eight rows for 40 players.
    UI.raidAnchor:SetSize((5*59-3)*1.5, 3*60*1.5)
    UI.raid = {}
    for i = 1, 40 do
        local unit = "raid"..i
        local frame = unitFrame(unit, 56, 58, true, UI.raidAnchor)
        frame:SetScale(1.5)
        RegisterStateDriver(frame, "visibility", "[petbattle] hide; [vehicleui] hide; [group:raid,@"..unit..",exists] show; hide")
        UI.raid[i] = frame
    end
    -- The grid hangs off the group row, so both stay together.
    for _, frame in ipairs(frames) do update(frame) end
end
function UI.RefreshGroupUnits(raid)
    for _, frame in ipairs(raid and UI.raid or partyFrames) do update(frame) end
end
function UI.PositionUnits()
    local h = UIParent:GetHeight()
    -- Align unit centres with the upper action row (38 above block centre).
    -- Each unit frame keeps a 20-point gap to the central action block.
    UI.Anchor(UI.combatAnchor, "combatOrigin", "BOTTOM", 0, h*.278-23)
    UI.Anchor(UI.player, "player", "RIGHT", -20, 38, UI.combatAnchor, "LEFT")
    UI.Anchor(UI.target, "target", "LEFT", 20, 38, UI.combatAnchor, "RIGHT")
    UI.Anchor(UI.group, "group", "TOP", 0, -20, UI.playerCastAnchor, "BOTTOM")
    -- Raid starts at the group row and adds horizontal rows downwards.
    UI.raidAnchor:ClearAllPoints()
    UI.raidAnchor:SetPoint("TOP", UI.group, "TOP", 0, 0)
    UI.PositionRaid()
    UI.targettarget:ClearAllPoints()
    UI.targettarget:SetPoint("BOTTOMRIGHT", UI.target, "TOPRIGHT", 0, 32)
    UI.Anchor(UI.bossAnchor, "bosses", "TOPRIGHT", -390, -410)
    if ForeverbuddyuiDB.positions.focus then
        UI.Anchor(UI.focus, "focus", "TOPRIGHT", -390, -314)
    else
        UI.focus:ClearAllPoints()
        UI.focus:SetPoint("BOTTOMLEFT", UI.bossAnchor, "TOPLEFT", 0, 58)
    end
    UI.pet:ClearAllPoints()
    UI.pet:SetPoint("BOTTOMLEFT", UI.player, "TOPLEFT", 0, 32)
end
-- Keep the confirmed large size up to ten and the confirmed 15-player size
-- above ten. Add columns rather than shrinking or exceeding three rows.
function UI.RaidLayout(count)
    if not UI.Public(count) or type(count) ~= "number" then return nil end
    count = math.max(1, math.min(40, math.floor(count)))
    local vertical = count >= 20
    local columns = math.max(5, math.ceil(count/3))
    local rows = math.ceil(count/columns)
    if vertical then
        rows = 3
        columns = math.ceil(count/rows)
    end
    local scale = count <= 10 and 1.5 or 1.5*math.sqrt(10/15)
    return scale, rows, count, columns, vertical
end
function UI.RaidCell(index, vertical, columns, rows)
    if vertical then return math.floor((index-1)/rows), (index-1)%rows end
    return (index-1)%columns, math.floor((index-1)/columns)
end
function UI.PositionRaid()
    if InCombatLockdown() or not UI.raid then return end
    local count = GetNumGroupMembers()
    local scale, rows, members, columns, vertical = UI.RaidLayout(count)
    if not scale or UI.raidLayoutCount == members then return end
    UI.raidLayoutCount = members
    UI.raidAnchor:SetSize((columns*59-3)*scale, 270)
    -- Top edge and centre stay fixed; hidden secure slots share the same scale.
    -- Secure slots cannot be moved during combat, so a full grid may only grow
    -- sideways: the spare slots already sit in further columns to the right.
    -- A member joining mid-fight then appears next to the grid instead of in a
    -- fourth row underneath it; the normal layout follows after combat.
    local capacity = columns*rows
    for i, frame in ipairs(UI.raid) do
        frame:SetScale(scale)
        frame:ClearAllPoints()
        local column, row
        if i <= capacity then
            column, row = UI.RaidCell(i, vertical, columns, rows)
        else
            local spare = i - capacity - 1
            column, row = columns + math.floor(spare/3), spare%3
        end
        frame:SetPoint("TOPLEFT", UI.raidAnchor, "TOPLEFT", column*59, -row*60)
    end
end
