local _, UI = ...
local L = UI.L

function UI.ShowWelcome(force)
    local db = ForeverbuddyuiDB
    if not db then return end
    local character = UI.GetCharacterSettings()
    if not force and (character.welcomeVersion == UI.VERSION or db.enabled == false) then return end
    if InCombatLockdown() then return end
    if not UI.welcome then
        local panel = UI.Panel(UIParent, 480, 380)
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 70)
        panel:SetFrameStrata("DIALOG")
        panel:EnableMouse(true)
        panel:SetClampedToScreen(true)
        local title = UI.Text(panel, 22, "TOP", panel, 0, -24)
        title:SetText(L["ForeverBuddyUI einrichten"])
        local warning = UI.Text(panel, 16, "TOP", panel, 0, -65)
        warning:SetText(L["Vorsicht: Layout wird überschrieben!"])
        warning:SetTextColor(1, .35, .2)
        local description = UI.Text(panel, 14, "TOP", panel, 0, -98)
        description:SetWidth(420)
        description:SetWordWrap(true)
        local setup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        setup:SetSize(220, 32)
        setup:SetPoint("BOTTOM", panel, "BOTTOM", 0, 42)
        setup:SetText(L["One Button Setup"])
        setup:SetScript("OnClick", function() UI.RunSetup() end)
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
        close:SetScript("OnClick", function() panel:Hide() end)
        local hint = UI.Text(panel, 12, "BOTTOM", panel, 0, 18)
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
