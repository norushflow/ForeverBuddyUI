local _, UI = ...

-- Account-wide welcome; installation remains an explicit user action.
function UI.ShowWelcome()
    local db = ForeverbuddyuiDB
    if not db or db.welcomeSeen or db.enabled == false then return end
    if InCombatLockdown() then return end
    if not UI.welcome then
        local panel = UI.Panel(UIParent, 460, 250)
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 70)
        panel:SetFrameStrata("DIALOG")
        panel:EnableMouse(true)
        panel:SetClampedToScreen(true)
        local title = UI.Text(panel, 22, "TOP", panel, 0, -24)
        title:SetText("Willkommen bei Foreverbuddyui")
        local description = UI.Text(panel, 14, "TOP", panel, 0, -68)
        description:SetWidth(408)
        description:SetWordWrap(true)
        description:SetText("Mit einem Klick aktivierst du das mitgelieferte Layout. Vorhandene Anpassungen am gleichnamigen Layout bleiben erhalten.\n\nSchließe vorher den Bearbeitungsmodus. Danach wird die Oberfläche neu geladen.")
        local setup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        setup:SetSize(220, 32)
        setup:SetPoint("BOTTOM", panel, "BOTTOM", 0, 42)
        setup:SetText("One Button Setup")
        setup:SetScript("OnClick", function()
            SlashCmdList.FOREVERBUDDYUI("on")
        end)
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
        close:SetScript("OnClick", function() panel:Hide() end)
        local hint = UI.Text(panel, 12, "BOTTOM", panel, 0, 18)
        hint:SetText("Auch später möglich: /fbui on")
        panel.setupButton = setup
        panel.closeButton = close
        UI.welcome = panel
    end
    UI.welcome:Show()
    db.welcomeSeen = true
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        -- Defer until all login handlers have initialized saved settings.
        C_Timer.After(0, UI.ShowWelcome)
    else
        UI.ShowWelcome()
    end
end)
