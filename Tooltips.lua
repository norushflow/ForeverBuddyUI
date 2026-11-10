local _, UI = ...
local Color = UI.Style.Color
local skins = setmetatable({}, {__mode="k"})
local tooltipNames = {"GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2", "ItemRefShoppingTooltip1", "ItemRefShoppingTooltip2"}

function UI.SkinTooltip(tooltip)
    if not tooltip then return end
    -- Never read tooltip contents or touch forbidden/private aura tooltips.
    pcall(function()
        if tooltip:IsForbidden() then return end
        local skin = skins[tooltip]
        if not skin then
            skin = UI.Panel(tooltip, 1, 1)
            skin:SetAllPoints(tooltip)
            skin:SetBackdropColor(unpack(Color.inset))
            skin:SetBackdropBorderColor(unpack(Color.bronze))
            skin:EnableMouse(false)
            skins[tooltip] = skin
            tooltip:HookScript("OnShow", function() UI.SkinTooltip(tooltip) end)
        end
        skin:SetFrameLevel(math.max(0, tooltip:GetFrameLevel()-1))
        local nineSlice = tooltip.NineSlice
        if nineSlice and not nineSlice:IsForbidden() then nineSlice:SetAlpha(0) end
    end)
end

function UI.InstallTooltips()
    for _, name in ipairs(tooltipNames) do UI.SkinTooltip(_G[name]) end
    if not UI.tooltipStyleHooked and type(SharedTooltip_SetBackdropStyle)=="function" then
        UI.tooltipStyleHooked = true
        hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tooltip)
            if skins[tooltip] then UI.SkinTooltip(tooltip) end
        end)
    end
end

function UI.ShowUnitTooltip(frame, defaultAnchor)
    if not GameTooltip then return end
    pcall(function()
        if GameTooltip:IsForbidden() then return end
        if defaultAnchor then
            GameTooltip_SetDefaultAnchor(GameTooltip, frame)
        else
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        end
        GameTooltip:SetUnit(frame.unit)
    end)
end
function UI.HideUnitTooltip()
    if not GameTooltip then return end
    pcall(function()
        if not GameTooltip:IsForbidden() then GameTooltip:Hide() end
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function()
    if UI.started then UI.InstallTooltips() end
end)
