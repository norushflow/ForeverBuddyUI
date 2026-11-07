local _, UI = ...
function UI.ClickFooterClock(_, mouse)
    if mouse ~= "LeftButton" and mouse ~= "RightButton" then return end
    pcall(function()
        if mouse == "LeftButton" then
            local native = GameTimeFrame
            if not UI.Public(native) then return end
            if native then
                local forbidden = native:IsForbidden()
                if not UI.Public(forbidden) or forbidden then return end
                local click = native:GetScript("OnClick")
                if type(click)=="function" then click(native, "LeftButton"); return end
            end
            if type(ToggleCalendar)=="function" then ToggleCalendar() end
            return
        end
        -- Direkt das Menü öffnen: der native Uhrklick quittiert ggf. nur einen Alarm.
        if not TimeManager_Toggle and C_AddOns and C_AddOns.LoadAddOn and not InCombatLockdown() then
            C_AddOns.LoadAddOn("Blizzard_TimeManager")
        end
        if type(TimeManager_Toggle)=="function" then TimeManager_Toggle() end
    end)
end
-- Blizzards EditMode-SetPoint merkt sich den relativen Rahmen als "Snap".
-- Unsere Anordnung ist kein EditMode-Snap: beim Ausblenden der Ziel-Leiste
-- bricht Blizzard sonst die Verankerung der geschützten Leiste (auch im Kampf),
-- sie bleibt ohne Punkt zurück und UpdateSystemAnchorInfo rechnet mit nil.
local function place(frame, point, relative, relativePoint, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, relative, relativePoint, x, y)
    if type(frame.ClearFrameSnap) == "function" then frame:ClearFrameSnap() end
end
local function hideNative(frame, vehicle, raid)
    if InCombatLockdown() then return end
    UI.Foreign(frame, function(native)
        local host = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
        host:SetAllPoints(UIParent)
        native:SetParent(host)
        RegisterStateDriver(host, "visibility", vehicle and "[vehicleui] show; hide" or raid and "[group:raid] show; hide" or "hide")
    end)
end
-- Das Schließen des Bearbeitungsmodus löst das Layout erneut aus. Ereignis-
-- gesteuert über OnHide statt mit einem dauerhaften 0,5-s-Ticker.
function UI.WatchEditMode()
    UI.Foreign(EditModeManagerFrame, function(frame)
        if frame.abuiEditWatcher then return end
        frame:HookScript("OnHide", function()
            if UI.started and not InCombatLockdown() then UI.ApplyLayout() end
        end)
        frame.abuiEditWatcher = true
    end)
end

function UI.CreateLayout()
    UI.InstallTooltips()
    UI.footer = UI.Panel(UIParent,1,38)
    UI.footer:SetBackdropColor(.025,.022,.012,.65)
    UI.footer:SetBackdropBorderColor(.75,.58,.12,.45)
    UI.footer:SetPoint("BOTTOMLEFT")
    UI.footer:SetPoint("BOTTOMRIGHT")
    UI.footer:SetFrameStrata("BACKGROUND")
    UI.clockButton = CreateFrame("Button", nil, UI.footer)
    UI.clockButton:SetSize(100, 38)
    UI.clockButton:SetPoint("CENTER", UI.footer, "CENTER", 0, 0)
    UI.clockButton:SetFrameStrata("MEDIUM")
    UI.clockButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    UI.clockButton:SetScript("OnClick", UI.ClickFooterClock)
    UI.clock = UI.Text(UI.clockButton, 27, "CENTER")
    local lastMinute
    local function refreshInfo()
        local hour, minute = GetGameTime()
        lastMinute = minute
        UI.clock:SetFormattedText("%02d:%02d", hour, minute)
    end
    -- The minute is the smallest unit shown: check once per second but only
    -- rewrite the text when it actually changes, so the clock never lags.
    local function tickClock()
        local _, minute = GetGameTime()
        if minute ~= lastMinute then refreshInfo() end
    end
    UI.timer = C_Timer.NewTicker(1, tickClock)
    refreshInfo()
    -- Class resources are drawn by our own widgets; native hierarchy stays intact.
    UI.targetCast = UI.CreateCastBar(UI.target, "target", 260)
    UI.playerCast = UI.CreateCastBar(UIParent, "player", 264)
    UI.focusCast = UI.CreateCastBar(UI.focus, "focus", 220)
    for _, boss in ipairs(UI.bosses) do boss.cast = UI.CreateCastBar(boss, boss.unit, 220) end
    UI.CreateHolyPower()
    UI.CreateSoulShards()
    UI.CreateClassPower()
    hideNative(PaladinPowerBarFrame)
    hideNative(PlayerFrame, true)
    hideNative(TargetFrameToT)
    hideNative(TargetFrame)
    hideNative(FocusFrame)
    hideNative(PlayerCastingBarFrame)
    for i=1,#UI.bosses do hideNative(_G["Boss"..i.."TargetFrame"]) end
    hideNative(PetFrame)
    hideNative(PartyFrame)
    -- Own group and raid grids replace the native ones. Keep the native
    -- hierarchy and secure show/hide callbacks untouched; suppress only
    -- rendering and mouse input, outside combat.
    UI.MaskNativeGroupFrames()
    UI.WatchEditMode()
end
function UI.ApplyLayout()
    if InCombatLockdown() then return end
    UI.WatchEditMode()
    UI.MaskNativeGroupFrames()
    UI.PositionUnits()
    place(UI.playerCastAnchor, "TOP", UI.combatAnchor, "BOTTOM", 0, -10)
    place(UI.playerCast, "TOP", UI.playerCastAnchor, "TOP", 0, 0)
    place(UI.targetCast, "BOTTOM", UI.target, "TOP", 0, 5)
    place(UI.focusCast, "TOP", UI.focus, "BOTTOM", 0, -24)
    for _, boss in ipairs(UI.bosses) do place(boss.cast, "TOP", boss, "BOTTOM", 0, -22) end
end

function UI.MaskNativeGroupFrames()
    if InCombatLockdown() then return end
    local function mask(frame)
        -- Selection highlights and ready-check icons ignore parent alpha in
        -- Blizzard's template. Restore inheritance for every region and child.
        pcall(function()
            if frame:IsForbidden() then return end
            frame:SetIgnoreParentAlpha(false)
            frame:EnableMouse(false)
            for _, region in ipairs({frame:GetRegions()}) do
                pcall(function()
                    if not region:IsForbidden() then region:SetIgnoreParentAlpha(false) end
                end)
            end
            for _, child in ipairs({frame:GetChildren()}) do mask(child) end
        end)
    end
    for _, name in ipairs({"CompactPartyFrame", "CompactRaidFrameContainer", "CompactRaidFrameManager"}) do
        local frame = _G[name]
        if frame then
            pcall(function()
                if frame:IsForbidden() then return end
                frame:SetAlpha(0)
                mask(frame)
            end)
        end
    end
end

-- Roster changes can create native children even when raid membership stays
-- unchanged. Coalesce the pass and run after Blizzard's event handlers.
function UI.QueueNativeGroupMask()
    if UI.nativeMaskPending then return end
    UI.nativeMaskPending = true
    C_Timer.After(0, function()
        UI.nativeMaskPending = nil
        if UI.started then UI.MaskNativeGroupFrames() end
    end)
end
