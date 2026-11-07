local _, UI = ...
function UI.CreateHolyPower()
    local _, class = UnitClass("player")
    if not UI.Public(class) or class ~= "PALADIN" then return end
    local powerType = Enum.PowerType.HolyPower
    local holder = CreateFrame("Frame", "ForeverbuddyuiHolyPower", UI.player)
    holder:SetSize(148, 10)
    holder:SetPoint("BOTTOMLEFT", UI.player, "TOPLEFT", 0, 5)
    holder.segments = {}
    for i=1,5 do
        local segment = CreateFrame("StatusBar", nil, holder)
        segment:SetSize(28, 8)
        segment:SetPoint("LEFT", holder, "LEFT", (i-1)*30, 0)
        segment:SetStatusBarTexture(UI.WHITE)
        segment:SetStatusBarColor(1, .78, .18)
        segment:SetMinMaxValues(i-1, i)
        local bg = segment:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(.14, .12, .06, 1)
        holder.segments[i] = segment
    end
    local function refresh()
        -- No Lua arithmetic/comparisons on resource values, including in combat.
        local power = UnitPower("player", powerType)
        for _, segment in ipairs(holder.segments) do segment:SetValue(power) end
    end
    holder:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    holder:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    holder:RegisterEvent("PLAYER_ENTERING_WORLD")
    holder:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    holder:SetScript("OnEvent", refresh)
    UI.holyPower = holder
    refresh()
end

function UI.CreateSoulShards()
    local _, class = UnitClass("player")
    if not UI.Public(class) or class ~= "WARLOCK" then return end
    local powerType = Enum.PowerType.SoulShards
    local holder = CreateFrame("Frame", "ForeverbuddyuiSoulShards", UI.player)
    holder:SetSize(148, 10)
    holder:SetPoint("BOTTOMLEFT", UI.player, "TOPLEFT", 0, 5)
    holder.segments = {}
    for i=1,5 do
        local segment = CreateFrame("StatusBar", nil, holder)
        segment:SetSize(28, 8)
        segment:SetPoint("LEFT", holder, "LEFT", (i-1)*30, 0)
        segment:SetStatusBarTexture(UI.WHITE)
        segment:SetStatusBarColor(.67, .42, .91)
        local bg = segment:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(.10, .06, .14, 1)
        holder.segments[i] = segment
    end
    local function refresh()
        local spec = UI.GetSpecialization()
        local partial = UI.Public(spec) and spec == (SPEC_WARLOCK_DESTRUCTION or 3)
        local step = 1
        if partial then
            local modifier = UnitPowerDisplayMod(powerType)
            if UI.Public(modifier) and modifier and modifier > 0 then step = modifier
            else partial = false end
        end
        -- Scale the public segment bounds, never calculate with secret power.
        local power = UnitPower("player", powerType, partial)
        for i, segment in ipairs(holder.segments) do
            segment:SetMinMaxValues((i-1)*step, i*step)
            segment:SetValue(power)
        end
    end
    holder:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    holder:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    holder:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    holder:RegisterEvent("PLAYER_ENTERING_WORLD")
    holder:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    holder:SetScript("OnEvent", refresh)
    UI.soulShards = holder
    refresh()
end
