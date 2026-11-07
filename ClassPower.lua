local _, UI = ...
function UI.CreateClassPower()
    local _, class = UnitClass("player")
    if not UI.Public(class) or class == "PALADIN" or class == "WARLOCK" then return end
    local holder = CreateFrame("Frame", "ForeverbuddyuiClassPower", UI.player)
    holder:SetSize(148, 10)
    holder:SetPoint("BOTTOMLEFT", UI.player, "TOPLEFT", 8, 5)
    holder.segments = {}
    for i=1,10 do
        local segment = CreateFrame("StatusBar", nil, holder)
        segment:SetStatusBarTexture(UI.WHITE)
        local bg = segment:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(.055, .06, .075, 1)
        holder.segments[i] = segment
    end
    local function layout(count, color)
        local width = (148-(count-1)*2)/count
        for i, segment in ipairs(holder.segments) do
            if i <= count then
                segment:ClearAllPoints()
                segment:SetPoint("LEFT", holder, "LEFT", (i-1)*(width+2), 0)
                segment:SetSize(width, 8)
                segment:SetStatusBarColor(color.r, color.g, color.b)
                segment:Show()
            else segment:Hide() end
        end
        holder.count = count
    end
    local syncPoll
    local function refresh()
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
            syncPoll()
            return
        end
        holder:Show()
        local color = UI.Public(token) and token and PowerBarColor[token] or {r=.2,g=.55,b=.9}
        if kind then color = PowerBarColor[kind] or RAID_CLASS_COLORS[class] or color end
        if mode == "runes" then
            color = spec==1 and {r=.8,g=.16,b=.24} or spec==3 and {r=.35,g=.8,b=.25} or {r=.3,g=.7,b=1}
        elseif mode == "stagger" then color = {r=.35,g=.8,b=.3} end
        if kind then
            local maximum = UnitPowerMax("player", kind)
            if UI.Public(maximum) and maximum and maximum > 0 then
                count = math.min(10, math.floor(maximum))
                holder.lastCounts = holder.lastCounts or {}
                holder.lastCounts[kind] = count
            elseif holder.lastCounts and holder.lastCounts[kind] then count = holder.lastCounts[kind] end
        end
        layout(count, color)
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
