local _, UI = ...
local L = UI.L
local Style = UI.Style
local classes = {"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER"}
function UI.RaidTest(argument)
    if InCombatLockdown() then UI.Message(L["Raid-Vorschau nur außerhalb des Kampfes."]); return end
    if argument == "off" then
        if UI.raidPreview then UI.raidPreview:Hide() end
        return
    end
    local count = argument == "" and 20 or tonumber(argument)
    if not count or count < 1 or count > 40 or count ~= math.floor(count) then
        UI.Message(L["/fbui raidtest 1–40 (z. B. 10, 20, 25, 30, 40) · /fbui raidtest off"])
        return
    end
    local panel = UI.raidPreview
    if not panel then
        -- Bare preview cells at the live raid anchor; no window decoration.
        panel = CreateFrame("Frame", nil, UIParent)
        UI.raidPreview = panel
        panel:SetPoint("TOP", UI.raidAnchor, "TOP", 0, 0)
        panel:SetFrameStrata("DIALOG")
        panel.cells = {}
        for i=1,40 do
            local cell = UI.Panel(panel, 56, 58)
            local color = RAID_CLASS_COLORS[classes[(i-1)%#classes+1]] or {r=.2,g=.6,b=.8}
            local health = CreateFrame("StatusBar", nil, cell)
            health:SetPoint("TOPLEFT", 2, -2)
            health:SetSize(52, 51)
            UI.StyleStatusBar(health)
            health:SetStatusBarColor(color.r, color.g, color.b)
            health:SetMinMaxValues(0, 100)
            local percent = 100 - ((i*7)%45)
            health:SetValue(percent)
            local overlay = CreateFrame("Frame", nil, cell)
            overlay:SetAllPoints(cell)
            overlay:SetFrameLevel(health:GetFrameLevel()+1)
            UI.Text(overlay, 10, "CENTER", nil, 0, 6):SetFormattedText("Raid %02d", i)
            local label = UI.Text(overlay, 11, "BOTTOM", nil, 0, 17)
            label:SetFormattedText("%d%%", percent)
            label:SetTextColor(.2, 1, .05)
            local power = cell:CreateTexture(nil, "ARTWORK")
            power:SetPoint("BOTTOMLEFT", 2, 2)
            power:SetSize(52, 2)
            Style.BarTexture(power)
            power:SetVertexColor(.15, .55, 1)
            -- Static sample debuffs only; preview never registers live unit auras.
            cell.debuffIcons = {}
            for j, texture in ipairs({"Spell_Shadow_ShadowWordPain", "Spell_Frost_FrostNova", "Ability_Poisons"}) do
                local icon = overlay:CreateTexture(nil, "ARTWORK")
                icon:SetSize(10, 10)
                icon:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 3+(j-1)*11, 4)
                icon:SetTexture("Interface\\Icons\\"..texture)
                icon:SetTexCoord(.07, .93, .07, .93)
                cell.debuffIcons[j] = icon
            end
            panel.cells[i] = cell
        end
        panel:RegisterEvent("PLAYER_REGEN_DISABLED")
        panel:SetScript("OnEvent", function(self) self:Hide() end)
    end
    local scale, rows, _, columns, vertical = UI.RaidLayout(count)
    panel:SetSize((columns*59-3)*scale, (rows*60-2)*scale)
    for i, cell in ipairs(panel.cells) do
        cell:SetScale(scale)
        cell:ClearAllPoints()
        local column, row = UI.RaidCell(i, vertical, columns, rows)
        cell:SetPoint("TOPLEFT", panel, "TOPLEFT", column*59, -row*60)
        if i <= count then cell:Show() else cell:Hide() end
    end
    panel:Show()
end
