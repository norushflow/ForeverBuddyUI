local _, UI = ...
local L = UI.L

-- Let Blizzard's private aura renderer own filtering, secret aura data,
-- cooldowns, stacks and dispel indicators. This only supplies a plain host and
-- its presentation settings; no Blizzard mixin/template is copied or hooked.
function UI.CreateGroupDebuffs(frame)
    if frame.debuffContainer then return true end
    if InCombatLockdown() then return false end
    if not C_UnitAuras or not C_UnitAuras.AddPrivateAuraAnchor
        or not Enum or not Enum.RaidAuraOrganizationType
        or not Enum.RaidDispelDisplayType or not Enum.RaidDispelOverlayType
        or not CompactRaidGroupTypeEnum then
        if not UI.debuffWarning then
            UI.debuffWarning = true
            UI.Message(L["Blizzards Gruppen-Debuff-Anzeige ist in diesem Client nicht verfügbar."])
        end
        return false
    end
    local host = CreateFrame("Frame", nil, frame)
    host:SetAllPoints(frame)
    local settings = {
        ["max-buffs"] = 0,
        ["max-debuffs"] = 3,
        ["max-dispel-debuffs"] = 3,
        ["aura-organization-type"] = Enum.RaidAuraOrganizationType.Legacy,
        ["ignore-buffs"] = true,
        ["ignore-debuffs"] = false,
        ["ignore-dispel-debuffs"] = false,
        ["display-only-dispellable-debuffs"] = false,
        ["dispel-indicator-option"] = Enum.RaidDispelDisplayType.DispellableByMe,
        ["dispel-indicator-overlay-type"] = Enum.RaidDispelOverlayType.UseDebuffColor,
        ["dispel-indicator-overlay-animation"] = false,
        ["dispel-indicator-animated-border"] = false,
        ["display-larger-role-specific-debuffs"] = true,
        ["show-big-defensive"] = false,
        ["big-defensive-size"] = 16,
        ["debuff-size"] = 10,
        ["buff-size"] = 10,
        ["debuff-border-scale"] = .6,
        ["buff-border-scale"] = .6,
        ["always-hide-duration"] = true,
        ["set-aura-size-to-icon-size"] = true,
        ["power-bar-used-height"] = 2,
        ["group-type"] = frame.unit:match("^raid") and CompactRaidGroupTypeEnum.Raid or CompactRaidGroupTypeEnum.Party,
    }
    for key, value in pairs(settings) do host:SetAttribute(key, value) end
    local ok, anchorID = pcall(C_UnitAuras.AddPrivateAuraAnchor, {
        unitToken = frame.unit,
        auraIndex = 1,
        parent = host,
        isContainer = true,
        showCooldownFrame = true,
        showCooldownEdge = false,
        showCountdownNumbers = true,
        showDispelIcon = true,
        iconInfo = {
            iconAnchor = {point="CENTER", relativeTo=host, relativePoint="CENTER", offsetX=0, offsetY=0},
            iconWidth = 10,
            iconHeight = 10,
            borderScale = .6,
        },
    })
    if not ok or not UI.Public(anchorID) or type(anchorID) ~= "number" then
        host:Hide()
        if not UI.debuffWarning then
            UI.debuffWarning = true
            UI.Message(L["Blizzards Gruppen-Debuff-Anzeige konnte nicht eingerichtet werden."])
        end
        return false
    end
    -- Unit tokens stay fixed for the lifetime of these buttons. The renderer
    -- follows visibility, roster changes and inherited scale itself.
    frame.debuffContainer = host
    frame.debuffAnchorID = anchorID
    return true
end
