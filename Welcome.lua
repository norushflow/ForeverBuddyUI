local addonName, UI = ...
local L = UI.L
local Style = UI.Style
local backdrop = "Interface\\AddOns\\" .. addonName .. "\\Media\\WelcomeFade.tga"

function UI.ShowWelcome(force)
    local db = ForeverbuddyuiDB
    if not db then return end
    local character = UI.GetCharacterSettings()
    if not force and (character.welcomeVersion == UI.VERSION or db.enabled == false) then return end
    if InCombatLockdown() then return end
    if not UI.welcome then
        local spacing = Style.Spacing
        local width = 452
        local panel = CreateFrame("Frame", nil, UIParent)
        panel:SetSize(width, 300)
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 70)
        panel:SetFrameStrata("DIALOG")
        panel:EnableMouse(true)
        panel:SetClampedToScreen(true)
        local background = panel:CreateTexture(nil, "BACKGROUND")
        background:SetPoint("TOPLEFT", panel, "TOPLEFT", -36, 36)
        background:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 36, -36)
        background:SetTexture(backdrop)

        local _, class = UnitClass("player")
        local classColor = UI.Public(class) and class and RAID_CLASS_COLORS[class]
        local r, g, b = unpack(Style.Color.bronze)
        if classColor then r, g, b = classColor.r, classColor.g, classColor.b end

        local titleColor = {.72 + .28 * r, .72 + .28 * g, .72 + .28 * b, 1}
        local title = UI.Text(panel, "heading", "TOPLEFT", panel, spacing.panel, -spacing.gap, titleColor, "OUTLINE")
        title:SetText(L["ForeverBuddyUI einrichten"])
        local warning = Style.Text(panel, "heading", Style.Color.gold)
        warning:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, spacing.gap - spacing.panel)
        warning:SetText(L["Vorsicht: Layout wird überschrieben!"])
        local description = Style.Text(panel, "body")
        description:SetPoint("TOPLEFT", warning, "BOTTOMLEFT", 0, -spacing.gap)
        description:SetWidth(width - 2 * spacing.panel)
        description:SetJustifyH("LEFT")
        description:SetWordWrap(true)
        local setup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        setup:SetSize(172, 30)
        setup:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -spacing.panel, spacing.panel)
        setup:SetText(L["One Button Setup"])
        Style.Button(setup)
        setup:SetScript("OnClick", function() UI.RunSetup() end)
        local close = Style.Close(CreateFrame("Button", nil, panel, "UIPanelCloseButton"))
        close:SetSize(24, 24)
        close:ClearAllPoints()
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -spacing.small, -spacing.small)
        close:SetScript("OnClick", function() panel:Hide() end)
        local hint = Style.Text(panel, "small", Style.Color.muted)
        hint:SetPoint("LEFT", panel, "BOTTOMLEFT", spacing.panel, spacing.panel + 15)
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
