local _, UI = ...
local L = UI.L
-- Eigenständige Ausrüstungsanzeigen nach der BetterCharacterPanel-Vorlage.
-- Nur das eigene Charakterfenster; keine Veränderungen an Blizzard-Slots.
local slots = {
    {1,"Head","left"}, {2,"Neck","left"}, {3,"Shoulder","left"},
    {15,"Back","left"}, {5,"Chest","left"}, {9,"Wrist","left"},
    {10,"Hands","right"}, {6,"Waist","right"}, {7,"Legs","right"},
    {8,"Feet","right"}, {11,"Finger0","right"}, {12,"Finger1","right"},
    {13,"Trinket0","right"}, {14,"Trinket1","right"},
    {16,"MainHand","weaponLeft"}, {17,"SecondaryHand","weaponRight"},
}
local enchantSlots = {
    [11] = {[1]=true,[3]=true,[5]=true,[7]=true,[8]=true,[11]=true,[12]=true,[16]=true},
    [10] = {[15]=true,[5]=true,[9]=true,[7]=true,[8]=true,[11]=true,[12]=true,[16]=true},
    [9] = {[1]=true,[15]=true,[5]=true,[9]=true,[6]=true,[7]=true,[8]=true,[11]=true,[12]=true,[16]=true},
}
local displays, requested = {}, {}
local queued, hookedFrame, hookedUpdate
local function public(value, kind)
    return UI.Public(value) and type(value)==kind
end
local function accessible(frame)
    if not frame or not UI.Public(frame) then return false end
    -- Fremde Blizzard-Knöpfe nur gesichert lesen: IsForbidden kann werfen.
    local ok, forbidden = pcall(function()
        local value = frame:IsForbidden()
        if not UI.Public(value) then error("secret") end
        return value
    end)
    return ok and forbidden == false
end
local function visible()
    local ok, shown = pcall(function()
        if not accessible(CharacterFrame) then return false end
        return CharacterFrame:IsShown()
    end)
    return ok and UI.Public(shown) and shown
end
local function newDisplay(button, side)
    local display = CreateFrame("Frame", nil, button)
    display:SetAllPoints(button)
    display:EnableMouse(false)
    local right = side=="right" or side=="weaponLeft"
    local edge, other, offset = right and "RIGHT" or "LEFT", right and "LEFT" or "RIGHT", right and -8 or 8
    display.level = UI.Text(display, 16, "CENTER")
    display.enchant = UI.Text(display, 10, "CENTER")
    display.enchant:SetWidth(112)
    display.enchant:SetWordWrap(false)
    display.enchant:SetJustifyH(right and "RIGHT" or "LEFT")
    display.enchant:SetTextColor(.25, 1, .35)
    display.level:ClearAllPoints()
    display.enchant:ClearAllPoints()
    if side=="weaponLeft" or side=="weaponRight" then
        display.level:SetPoint("BOTTOM", button, "TOP", 0, 5)
        display.enchant:SetPoint("BOTTOM"..edge, button, "BOTTOM"..other, offset, 0)
    else
        display.level:SetPoint("BOTTOM"..edge, button, "BOTTOM"..other, offset, 1)
        display.enchant:SetPoint("TOP"..edge, button, "TOP"..other, offset, -5)
    end
    display.sockets = {}
    for i=1,4 do
        local icon = display:CreateTexture(nil, "OVERLAY")
        icon:SetSize(14,14)
        icon:SetPoint(edge, i==1 and display.level or display.sockets[i-1], other, right and -3 or 3, 0)
        icon:Hide()
        display.sockets[i] = icon
    end
    return display
end
local function clear(display)
    display.level:SetText("")
    display.level:SetTextColor(.92,.95,1)
    display.enchant:SetText("")
    display.enchant:SetTextColor(.25,1,.35)
    for _, icon in ipairs(display.sockets) do icon:Hide() end
end
local function enchantExpected(slot, link)
    if not (UnitLevel and GetExpansionForLevel and GameRulesUtil and GameRulesUtil.GetEffectiveMaxLevelForPlayer) then return false end
    local level, maximum = UnitLevel("player"), GameRulesUtil.GetEffectiveMaxLevelForPlayer()
    if not public(level,"number") or not public(maximum,"number") or level<maximum then return false end
    local expansion = GetExpansionForLevel(level)
    if not public(expansion,"number") or not enchantSlots[expansion] then return false end
    if slot==17 then
        local equip = select(4,C_Item.GetItemInfoInstant(link))
        return public(equip,"string") and (equip=="INVTYPE_WEAPON" or equip=="INVTYPE_WEAPONOFFHAND" or equip=="INVTYPE_2HWEAPON")
    end
    return enchantSlots[expansion][slot]
end
local function enchantText(text)
    if not public(text,"string") then return nil end
    -- Lokalisierte Vorlage als Literal behandeln, nicht als Lua-Muster.
    if public(ENCHANTED_TOOLTIP_LINE,"string") then
        local prefix, suffix = ENCHANTED_TOOLTIP_LINE:match("^(.-)%%s(.*)$")
        if prefix and text:sub(1,#prefix)==prefix and (suffix=="" or text:sub(-#suffix)==suffix) then
            return text:sub(#prefix+1, #text-#suffix)
        end
    end
end
local function updateSlot(entry)
    local slot, name, side = unpack(entry)
    local button = _G["Character"..name.."Slot"]
    if not accessible(button) then return end
    local shown = button:IsShown()
    if not UI.Public(shown) or not shown then return end
    local display = displays[slot]
    if not display then
        display = newDisplay(button,side)
        displays[slot] = display
    end
    clear(display)
    local link = GetInventoryItemLink("player",slot)
    if not public(link,"string") then return end
    local level = C_Item.GetDetailedItemLevelInfo(link)
    -- Auch geschützte API-Zahlen unverändert an den nativen Formatter geben.
    if not UI.Public(level) or type(level)=="number" then display.level:SetFormattedText("%d",level) end
    local quality = GetInventoryItemQuality("player",slot)
    if public(quality,"number") then
        local r,g,b = C_Item.GetItemQualityColor(quality)
        display.level:SetTextColor(r,g,b)
    end
    local data = C_TooltipInfo.GetInventoryItem("player",slot)
    if not public(data,"table") or not public(data.lines,"table") or #data.lines==0 or (UI.Public(level) and level==nil) then
        local id = C_Item.GetItemInfoInstant(link)
        if public(id,"number") and not requested[id] then
            requested[id] = true
            C_Item.RequestLoadItemDataByID(id)
        end
    end
    if not public(data,"table") or not public(data.lines,"table") then return end
    local enchant, count, unknown = nil, 0, false
    for _, line in ipairs(data.lines) do
        if public(line,"table") then
            local kind, text = line.type, line.leftText
            if not UI.Public(kind) or not UI.Public(text) then unknown = true end
            if UI.Public(kind) then
                if kind==15 then
                    if public(text,"string") then enchant = enchantText(text) or text end
                elseif not enchant then
                    enchant = enchantText(text)
                end
                if kind==3 and count<4 then
                    count = count+1
                    local icon, gem, socket = display.sockets[count], line.gemIcon, line.socketType
                    if public(gem,"number") or public(gem,"string") then
                        icon:SetTexture(gem)
                        icon:SetVertexColor(1,1,1)
                        icon:Show()
                    elseif UI.Public(gem) and gem==nil and public(socket,"string") then
                        icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-"..socket)
                        icon:SetVertexColor(1,.35,.35)
                        icon:Show()
                    end
                end
            end
        else
            unknown = true
        end
    end
    if enchant then
        -- Kein byteweises Abschneiden: Umlaute und Qualitätsatlanten erhalten.
        display.enchant:SetText(enchant)
    elseif not unknown and #data.lines>0 and enchantExpected(slot,link) then
        -- Ein vorhandener Enchant im Link darf bei nachladendem Tooltip nicht
        -- fälschlich als fehlend markiert werden.
        local enchantID = link:match("item:%d+:(%d*):")
        if enchantID=="0" or enchantID=="" then
            display.enchant:SetText(L["Verzauberung fehlt"])
            display.enchant:SetTextColor(1,.25,.25)
        end
    end
end
function UI.QueueEquipment()
    if not UI.started or queued or InCombatLockdown() or not visible() then return end
    queued = true
    C_Timer.After(.05,function()
        queued = nil
        if not UI.started or InCombatLockdown() or not visible() then return end
        for _, entry in ipairs(slots) do pcall(updateSlot,entry) end
    end)
end
function UI.InstallEquipment()
    if not UI.started or InCombatLockdown() then return end
    pcall(function()
        if accessible(CharacterFrame) and hookedFrame~=CharacterFrame then
            CharacterFrame:HookScript("OnShow",function()
                requested = {}
                UI.QueueEquipment()
            end)
            hookedFrame = CharacterFrame
        end
        if not hookedUpdate and type(PaperDollItemSlotButton_Update)=="function" then
            hooksecurefunc("PaperDollItemSlotButton_Update",UI.QueueEquipment)
            hookedUpdate = true
        end
    end)
    UI.QueueEquipment()
end
local events = CreateFrame("Frame")
for _, event in ipairs({"ADDON_LOADED","PLAYER_REGEN_ENABLED","PLAYER_EQUIPMENT_CHANGED","UNIT_INVENTORY_CHANGED","SOCKET_INFO_UPDATE","ITEM_DATA_LOAD_RESULT"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent",function(_,event,arg1)
    if not UI.started then return end
    if event=="ADDON_LOADED" or event=="PLAYER_REGEN_ENABLED" then
        UI.InstallEquipment()
    elseif event=="ITEM_DATA_LOAD_RESULT" then
        if public(arg1,"number") and requested[arg1] then UI.QueueEquipment() end
    elseif event~="UNIT_INVENTORY_CHANGED" or (UI.Public(arg1) and arg1=="player") then
        requested = {}
        UI.QueueEquipment()
    end
end)
