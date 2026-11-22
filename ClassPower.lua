local addonName, UI = ...
local defaultColor = {r=.2,g=.55,b=.9}
local bloodColor = {r=.8,g=.16,b=.24}
local unholyColor = {r=.35,g=.8,b=.25}
local frostColor = {r=.3,g=.7,b=1}
local staggerColor = {r=.35,g=.8,b=.3}

local dotTexture = "Interface\\AddOns\\" .. addonName .. "\\Media\\ComboPoint"

local function createDisplay(name, parent, roundPoints)
    local holder = CreateFrame("Frame", name, parent)
    holder:SetSize(148, 10)
    holder.segments = {}
    for i=1,10 do
        local segment = CreateFrame("StatusBar", nil, holder)
        if roundPoints then
            segment:SetStatusBarTexture(dotTexture)
            local background = segment:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(segment)
            background:SetTexture(dotTexture)
            background:SetVertexColor(unpack(UI.Style.Color.inset))
        else
            UI.StyleStatusBar(segment)
        end
        holder.segments[i] = segment
    end
    return holder
end

local function layout(holder, count, roundPoints)
    if holder.count == count then return end
    local gap = roundPoints and 3 or 2
    local width = roundPoints and 10 or (148-(count-1)*gap)/count
    if roundPoints then holder:SetWidth(count*width + (count-1)*gap) end
    for i, segment in ipairs(holder.segments) do
        if i <= count then
            segment:ClearAllPoints()
            segment:SetPoint("LEFT", holder, "LEFT", (i-1)*(width+gap), 0)
            segment:SetSize(width, roundPoints and width or 8)
            segment:Show()
        else segment:Hide() end
    end
    holder.count = count
end

function UI.CreateClassPower()
    local _, class = UnitClass("player")
    if not UI.Public(class) or class == "PALADIN" or class == "WARLOCK" then return end
    local usesComboPoints = class == "ROGUE" or class == "DRUID"
    local roundNameplatePoints = class == "ROGUE"
    local holder = createDisplay("ForeverbuddyuiClassPower", UI.player)
    holder:SetPoint("BOTTOMLEFT", UI.player, "TOPLEFT", 8, 5)
    local nameplatePoints
    if usesComboPoints then
        nameplatePoints = createDisplay(nil, UIParent, roundNameplatePoints)
        nameplatePoints:Hide()
        holder.nameplatePoints = nameplatePoints
    end
    local syncPoll
    local function refresh(_, event, unit)
        local spec = UI.GetSpecialization()
        if not UI.Public(spec) then spec = nil end
        local mainType, token = UnitPowerType("player")
        local kind, count, mode = nil, 1, "hidden"
        if class == "DEATHKNIGHT" then
            mode, count = "runes", 6
        elseif class == "ROGUE" or (class == "DRUID" and UI.Public(mainType) and mainType == Enum.PowerType.Energy) then
            kind, count, mode = Enum.PowerType.ComboPoints, 5, "points"
        elseif class == "MONK" and spec == 3 then
            kind, count, mode = Enum.PowerType.Chi, 5, "points"
        elseif class == "MONK" and spec == 1 then
            mode = "stagger"
        elseif class == "MAGE" and spec == 1 then
            kind, count, mode = Enum.PowerType.ArcaneCharges, 4, "points"
        elseif class == "EVOKER" then
            kind, count, mode = Enum.PowerType.Essence, 5, "points"
        end
        -- The active resource already has a bar inside the player frame.
        -- Only additional class resources belong above it; re-evaluate on
        -- form/spec changes so the same holder can disappear and return.
        if mode == "hidden" then
            holder.mode, holder.powerType = mode, nil
            holder:Hide()
            if nameplatePoints then nameplatePoints:Hide() end
            syncPoll()
            return
        end
        holder:Show()
        if nameplatePoints then
            local plate
            local attackable = UnitCanAttack("player", "target")
            if UI.Public(attackable) and attackable and C_NamePlate and C_NamePlate.GetNamePlateForUnit then
                local ok, targetPlate = pcall(C_NamePlate.GetNamePlateForUnit, "target")
                if ok and UI.Public(targetPlate) then plate = targetPlate end
                if plate and event == "NAME_PLATE_UNIT_REMOVED" and unit then
                    local removed, removedPlate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
                    if removed and UI.Public(removedPlate) and removedPlate == plate then plate = nil end
                end
            end
            if plate and plate ~= nameplatePoints.nameplate then
                local anchored = UI.Foreign(plate, function(frame)
                    nameplatePoints:ClearAllPoints()
                    nameplatePoints:SetParent(frame)
                    nameplatePoints:SetPoint("BOTTOM", frame, "TOP", 0, 5)
                end)
                nameplatePoints.nameplate = anchored and plate or nil
            end
            if plate and nameplatePoints.nameplate == plate then
                nameplatePoints:Show()
            else
                nameplatePoints:Hide()
            end
        end
        local color = UI.Public(token) and token and PowerBarColor[token] or defaultColor
        if roundNameplatePoints then
            color = RAID_CLASS_COLORS.ROGUE or PowerBarColor[kind] or color
        elseif kind then
            color = PowerBarColor[kind] or RAID_CLASS_COLORS[class] or color
        end
        if mode == "runes" then
            color = spec==1 and bloodColor or spec==3 and unholyColor or frostColor
        elseif mode == "stagger" then color = staggerColor end
        if kind then
            local maximum = UnitPowerMax("player", kind)
            if UI.Public(maximum) and maximum and maximum > 0 then
                count = math.min(10, math.floor(maximum))
                holder.lastCounts = holder.lastCounts or {}
                holder.lastCounts[kind] = count
            elseif holder.lastCounts and holder.lastCounts[kind] then count = holder.lastCounts[kind] end
        end
        layout(holder, count)
        for i=1,count do holder.segments[i]:SetStatusBarColor(color.r, color.g, color.b) end
        holder.mode, holder.powerType = mode, kind
        if mode == "runes" then
            for i=1,6 do
                local segment = holder.segments[i]
                local start, duration, ready = GetRuneCooldown(i)
                segment:SetMinMaxValues(0, 1)
                -- Rune timing is normally public. Never calculate with restricted values.
                if UI.Public(ready) and ready then segment:SetValue(1)
                elseif UI.Public(start) and UI.Public(duration) and start and duration and duration > 0 then
                    segment:SetValue(math.max(0, math.min(1, (GetTime()-start)/duration)))
                else segment:SetValue(0) end
            end
        elseif mode == "points" then
            local value = UnitPower("player", kind)
            -- Essence refill is optional: only combine genuinely public numbers.
            if class == "EVOKER" and UnitPartialPower and UI.Public(value) then
                local partial = UnitPartialPower("player", kind)
                if UI.Public(partial) and partial then value = value + partial/1000 end
            end
            for i=1,count do
                holder.segments[i]:SetMinMaxValues(i-1, i)
                holder.segments[i]:SetValue(value)
            end
            if nameplatePoints and nameplatePoints:IsShown() then
                layout(nameplatePoints, count, roundNameplatePoints)
                for i=1,count do
                    local segment = nameplatePoints.segments[i]
                    segment:SetStatusBarColor(color.r, color.g, color.b)
                    segment:SetMinMaxValues(i-1, i)
                    segment:SetValue(value)
                end
            end
        elseif mode == "stagger" then
            holder.segments[1]:SetMinMaxValues(0, UnitHealthMax("player"))
            holder.segments[1]:SetValue(UnitStagger("player"))
        end
        syncPoll()
    end
    for _, event in ipairs({"UNIT_POWER_FREQUENT", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_HEALTH"}) do
        holder:RegisterUnitEvent(event, "player")
    end
    for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "UPDATE_SHAPESHIFT_FORM", "TRAIT_CONFIG_UPDATED"}) do holder:RegisterEvent(event) end
    if usesComboPoints then
        holder:RegisterEvent("PLAYER_TARGET_CHANGED")
        holder:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        holder:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        holder:RegisterUnitEvent("UNIT_FACTION", "target")
    end
    if class == "DEATHKNIGHT" then holder:RegisterEvent("RUNE_POWER_UPDATE") end
    holder:SetScript("OnEvent", refresh)
    -- Runen und Essenz ändern sich zeitabhängig. Statt eines dauerhaften
    -- OnUpdate läuft ein Ticker nur bei sichtbarer Anzeige und nur für die
    -- Klassen, die ihn tatsächlich brauchen (Todesritter, Rufer).
    local poll
    local function needsPoll()
        return holder:IsShown() and (holder.mode == "runes" or class == "EVOKER")
    end
    local function stopPoll()
        if poll and poll.Cancel then pcall(poll.Cancel, poll) end
        poll = nil
    end
    function syncPoll()
        if not needsPoll() then stopPoll(); return end
        if poll then return end
        poll = C_Timer.NewTicker(.1, function()
            if not needsPoll() then stopPoll(); return end
            refresh()
        end)
    end
    -- Testbarer Vertrag: ein Abruf entspricht genau einem Tickerlauf.
    holder.Poll = refresh
    holder.SyncPoll = syncPoll
    holder:SetScript("OnShow", syncPoll)
    holder:SetScript("OnHide", stopPoll)
    UI.classPower = holder
    refresh()
end
