local _, UI = ...
-- Do not instantiate Blizzard's CastingBarMixin in addon execution: it branches
-- on restricted interruptibility/timestamps. Native duration widgets handle time.
function UI.CreateCastBar(parent, unit, width)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, 18)
    UI.BindRoundedBackground(frame, width, 18)
    frame.unit = unit
    frame.fill = CreateFrame("StatusBar", nil, frame)
    frame.fill:SetPoint("TOPLEFT", 2, -2)
    frame.fill:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.fill:SetStatusBarTexture(UI.WHITE)
    frame.fill:SetStatusBarColor(.18, .55, .65)
    local mask = frame.fill:CreateMaskTexture()
    mask:SetTexture("Interface\\AddOns\\Foreverbuddyui\\Media\\UnitMasks\\"..width.."x18",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(frame)
    frame.fill:GetStatusBarTexture():AddMaskTexture(mask)
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    overlay:SetFrameLevel(frame.fill:GetFrameLevel()+1)
    frame.label = UI.Text(overlay, 11, "CENTER")
    frame.label:SetWidth(width-10)
    frame.label:SetWordWrap(false)
    local function refresh()
        local name, _, _, _, _, _, _, _, _, castBarID = UnitCastingInfo(unit)
        local channel, empowered = false, false
        if not UI.Public(castBarID) then frame:Hide(); return end
        if not castBarID then
            local channelName, _, _, _, _, _, _, _, isEmpowered, _, channelID = UnitChannelInfo(unit)
            if not UI.Public(channelID) or not channelID then frame:Hide(); return end
            name, channel, empowered = channelName, true, UI.Public(isEmpowered) and isEmpowered
        end
        local duration
        if channel then duration = UnitChannelDuration(unit)
        else duration = UnitCastingDuration(unit) end
        -- A stopped cast can disappear between the info and duration calls.
        if UI.Public(duration) and duration == nil then frame:Hide(); return end
        -- A duration may itself be secret. Forward it without a boolean test.
        frame.fill:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate,
            channel and not empowered and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime)
        frame.label:SetText(name)
        frame:Show()
    end
    for _, event in ipairs({"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP", "UNIT_SPELLCAST_EMPOWER_UPDATE"}) do
        frame:RegisterUnitEvent(event, unit)
    end
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    if unit == "target" then frame:RegisterEvent("PLAYER_TARGET_CHANGED") end
    if unit == "focus" then frame:RegisterEvent("PLAYER_FOCUS_CHANGED") end
    if unit:match("^boss") then frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT") end
    frame:SetScript("OnEvent", refresh)
    frame.Refresh = refresh
    refresh()
    return frame
end
