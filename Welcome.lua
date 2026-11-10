local _, UI = ...
local L = UI.L
local Style = UI.Style

function UI.ShowWelcome(force)
    local db = ForeverbuddyuiDB
    if not db then return end
    local character = UI.GetCharacterSettings()
    if not force and (character.welcomeVersion == UI.VERSION or db.enabled == false) then return end
    if InCombatLockdown() then return end
    if not UI.welcome then
        local panel = CreateFrame("Frame", nil, UIParent)
        panel:SetSize(480, 380)
        Style.Window(panel, 56)
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 70)
        panel:SetFrameStrata("DIALOG")
        panel:EnableMouse(true)
        panel:SetClampedToScreen(true)
        local title = UI.Text(panel, "title", "TOP", panel, 0, -25, Style.Color.gold)
        title:SetText(L["ForeverBuddyUI einrichten"])
        local warning = UI.Text(panel, "heading", "TOP", panel, 0, -72, Style.Color.danger)
        warning:SetText(L["Vorsicht: Layout wird überschrieben!"])
        local description = UI.Text(panel, "body", "TOP", panel, 0, -104)
        description:SetWidth(480 - 2 * Style.Spacing.panel)
        description:SetWordWrap(true)
        local footer = Style.Divider(panel)
        footer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", Style.Spacing.panel, 88)
        footer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -Style.Spacing.panel, 88)
        local setup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        setup:SetSize(220, 32)
        setup:SetPoint("BOTTOM", panel, "BOTTOM", 0, 42)
        setup:SetText(L["One Button Setup"])
        Style.Button(setup)
        setup:SetScript("OnClick", function() UI.RunSetup() end)
        local close = Style.Close(CreateFrame("Button", nil, panel, "UIPanelCloseButton"))
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
        close:SetScript("OnClick", function() panel:Hide() end)
        local hint = UI.Text(panel, "small", "BOTTOM", panel, 0, 18, Style.Color.muted)
        hint:SetText(L["Erneut öffnen: /fbui on"])
        panel.description = description
        panel.setupButton = setup
        panel.closeButton = close
        UI.welcome = panel
    end
    UI.welcome.description:SetText("Version " .. UI.VERSION .. L["\nLayout für 3440 × 1440 Pixel.\n\nDas Layout ForeverBuddyUI wird durch die mitgelieferte Vorlage ersetzt. Eigene Änderungen an diesem Layout gehen verloren. Andere Layouts bleiben erhalten.\n\nBitte vorher den Bearbeitungsmodus schließen."])
    UI.welcome.setupButton:Show()
    UI.welcome:Show()
    character.welcomeVersion = UI.VERSION
end

function UI.ShowSetupComplete()
    UI.Message(L["Layout eingerichtet. Bitte jetzt /reload eingeben."])
    if UI.welcome then
        UI.welcome.description:SetText(L["Layout erfolgreich eingerichtet.\n\nBitte jetzt /reload im Chat eingeben, um die Einrichtung abzuschließen."])
        UI.welcome.setupButton:Hide()
        UI.welcome:Show()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(0, function() UI.ShowWelcome() end)
    else
        UI.ShowWelcome()
    end
end)
