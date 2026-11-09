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
local watchedEditModeFrames = setmetatable({}, {__mode = "k"})
function UI.WatchEditMode()
    UI.Foreign(EditModeManagerFrame, function(frame)
        if watchedEditModeFrames[frame] then return end
        frame:HookScript("OnHide", function()
            if UI.started and not InCombatLockdown() then UI.ApplyLayout() end
        end)
        watchedEditModeFrames[frame] = true
    end)
end

-- Tint only native normal borders; icons, cooldowns and state highlights stay intact.
function UI.StyleActionBars()
    if InCombatLockdown() then return end
    for _, prefix in ipairs({"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
        "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button",
        "MultiBar7Button", "PetActionButton", "StanceButton"}) do
        for index=1,12 do
            UI.Foreign(_G[prefix..index], function(button)
                local texture = button:GetNormalTexture()
                UI.Foreign(texture, function(border) border:SetVertexColor(.08, .08, .08) end)
            end)
        end
    end
end

function UI.CreateLayout()
    UI.InstallTooltips()
    UI.footer = UI.Panel(UIParent,1,38)
    UI.footer:SetBackdropColor(0,0,0,.9)
    UI.footer:SetBackdropBorderColor(.08,.08,.08,1)
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
    -- The minute is the smallest unit shown: check once per second but only
    -- rewrite the text when it actually changes, so the clock never lags.
    local function tickClock()
        local hour, minute = GetGameTime()
        if minute == lastMinute then return end
        lastMinute = minute
        UI.clock:SetFormattedText("%02d:%02d", hour, minute)
    end
    UI.timer = C_Timer.NewTicker(1, tickClock)
    tickClock()
    -- Class resources are drawn by our own widgets; native hierarchy stays intact.
    UI.playerCast = UI.CreateCastBar(UI.playerCastAnchor, "player", 296, 22)
    UI.playerCast:SetPoint("TOP", UI.playerCastAnchor, "TOP", 0, -6)
    UI.targetCast = UI.CreateCastBar(UI.target, "target", 260)
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
    for i=1,#UI.bosses do hideNative(_G["Boss"..i.."TargetFrame"]) end
    hideNative(PetFrame)
    -- PartyFrame participates in Blizzard EditMode: keep its parent intact.
    -- Own group and raid grids replace the native ones. Keep the native
    -- hierarchy and secure show/hide callbacks untouched; suppress only
    -- rendering and mouse input, outside combat.
    UI.MaskNativeGroupFrames()
    UI.WatchEditMode()
end
function UI.ApplyLayout()
    if InCombatLockdown() then return end
    UI.StyleActionBars()
    UI.WatchEditMode()
    UI.MaskNativeGroupFrames()
    UI.PositionUnits()
    place(UI.playerCastAnchor, "TOP", UI.combatAnchor, "BOTTOM", 0, -10)
    place(UI.targetCast, "BOTTOM", UI.target, "TOP", 0, 5)
    place(UI.focusCast, "TOP", UI.focus, "BOTTOM", 0, -24)
    for _, boss in ipairs(UI.bosses) do place(boss.cast, "TOP", boss, "BOTTOM", 0, -22) end
end

-- Blizzard restores castbar alpha on cast start and during its animations.
-- A permanently hidden secure parent keeps it invisible even after Show/SetAlpha,
-- without changing protected visibility from an addon callback during combat.
local nativeCastHosts = setmetatable({}, {__mode = "k"})
function UI.HideNativePlayerCastBars()
    if InCombatLockdown() then return end
    for _, name in ipairs({"PlayerCastingBarFrame", "CastingBarFrame"}) do
        UI.Foreign(_G[name], function(frame)
            local host = nativeCastHosts[frame]
            if not host then
                host = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
                host:SetAllPoints(UIParent)
                RegisterStateDriver(host, "visibility", "hide")
                nativeCastHosts[frame] = host
            end
            if frame:GetParent() ~= host then frame:SetParent(host) end
        end)
    end
end

function UI.MaskNativeGroupFrames()
    if InCombatLockdown() then return end
    UI.HideNativePlayerCastBars()
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
    for _, name in ipairs({"PartyFrame", "CompactPartyFrame", "CompactRaidFrameContainer", "CompactRaidFrameManager",
        "PlayerCastingBarFrame", "CastingBarFrame"}) do
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
