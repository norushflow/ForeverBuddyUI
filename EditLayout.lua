local _, UI = ...
local layoutName = "ForeverBuddyUI Korrigiert"
local layoutString = [=[5 0 59 0 0 0 4 4 UIParent 0.0 -236.6 -1 ##$$%*&''%)$+#,$ 0 1 0 6 0 MainActionBar 0.0 4.0 -1 ##$$%*&''%(#,$ 0 2 0 0 6 MainActionBar 0.0 -4.0 -1 ##$$%*&''%(#,$ 0 3 0 8 6 BagsBar -3.5 0.5 -1 ##$$%/&%'%(#,$ 0 4 1 5 5 UIParent -5.0 -77.0 -1 #$$$%/&('%(#,$ 0 5 1 1 4 UIParent 0.0 0.0 -1 ##$$%/&('%(#,$ 0 6 1 1 4 UIParent 0.0 -50.0 -1 ##$$%/&('%(#,$ 0 7 1 1 4 UIParent 0.0 -100.0 -1 ##$$%/&('%(#,$ 0 10 0 4 4 UIParent 0.0 -149.0 -1 ##$$&('% 0 11 1 7 7 UIParent 0.0 -4.0 -1 ##$$&('%,# 0 12 1 7 7 UIParent 0.0 -4.0 -1 ##$$&('% 1 -1 0 4 4 UIParent 0.0 -323.0 -1 #&$#%# 2 -1 1 2 2 UIParent 0.0 0.0 -1 ##$#%(&( 3 0 0 2 0 MainActionBar 16.0 16.0 -1 $#3# 3 1 0 0 2 MainActionBar -16.0 16.0 -1 %#3# 3 2 0 4 4 UIParent 900.0 143.3 -1 %#&#3# 3 3 0 0 0 UIParent 1111.3 -956.0 -1 '$(#)$-[.G/#1$3#5#6(7-7$8(9( 3 4 1 0 2 CompactRaidFrameManager 0.0 -5.0 -1 ,#-=.+/#0#1#2(3#5#6(7-7$8(9( 3 5 0 2 2 UIParent -391.7 -502.0 -1 &#*$3# 3 6 1 5 5 UIParent 0.0 0.0 -1 -=.+/#4$5#6(7-7$8(9( 3 7 1 4 4 UIParent 0.0 0.0 -1 3# 4 -1 1 7 7 UIParent 0.0 -4.0 -1 # 5 -1 1 7 7 UIParent 0.0 -4.0 -1 # 6 0 0 1 1 UIParent 963.3 -2.0 -1 ##$#%#&.(()( 6 1 0 4 4 UIParent -300.0 -120.0 -1 ##$#%#'+(()(-$ 6 2 1 1 1 UIParent 0.0 -25.0 -1 ##$#%$&.(()(+#,-,$ 7 -1 1 7 7 UIParent 0.0 -4.0 -1 # 8 -1 0 1 1 UIParent -1209.5 -962.0 -1 #'$A%$&i 9 -1 1 7 7 UIParent 0.0 -4.0 -1 # 10 -1 1 0 0 UIParent 16.0 -116.0 -1 # 11 -1 1 8 8 UIParent -9.0 85.0 -1 # 12 -1 0 1 1 UIParent -1238.0 -2.0 -1 #K$#%# 13 -1 0 0 6 ChatFrame1 -32.0 -36.0 -1 ##$#%$ 14 -1 0 7 7 UIParent 1313.7 1.5 -1 ##$#%# 15 0 0 1 1 UIParent 0.0 -2.0 -1 && 15 1 1 7 7 UIParent 0.0 17.0 -1 &- 16 -1 1 5 5 UIParent 0.0 0.0 -1 #( 17 -1 1 1 1 UIParent 0.0 -100.0 -1 ## 18 -1 1 5 5 UIParent 0.0 0.0 -1 #- 19 -1 1 7 7 UIParent 0.0 0.0 -1 ## 20 0 1 7 7 UIParent 0.0 310.0 -1 ##$/%$&('%(-($)#+$,$-$ 20 1 1 7 7 UIParent 0.0 240.0 -1 ##$*%$&('%(-($)#+$,$-$ 20 2 1 7 7 UIParent 0.0 370.0 -1 ##$$%$&('((-($)#+$,$-$ 20 3 1 7 7 UIParent 420.0 430.0 -1 #$$$%#&('((-($)#*#+$,$-$.-.$ 21 -1 1 7 7 UIParent -410.0 380.0 -1 ##%#&#'((()#*-*$+#,&-#.#/(0#1# 22 0 1 8 7 UIParent -457.0 336.0 -1 #$$$%#&('((#)U*$+%,$-#.#/U0% 22 1 1 1 1 UIParent 0.0 -40.0 -1 &('()U*#+% 22 2 1 1 1 UIParent 0.0 -90.0 -1 &('()U*#+% 22 3 1 1 1 UIParent 0.0 -130.0 -1 &('()U*#+% 23 -1 1 0 0 UIParent 0.0 0.0 -1 ##$#%$&7&%'7(%)U+$,$-$.(/U 24 -1 1 1 1 UIParent 0.0 -182.0 -1 # 25 -1 0 4 4 UIParent 0.0 -152.0 -1 # 26 0 0 1 1 UIParent 545.3 -141.0 -1 #$ 26 1 0 2 2 UIParent -656.5 -143.0 -1 #$ 27 -1 1 4 4 Minimap -68.0 -68.0 -1 #- 28 -1 1 4 4 UIParent 0.0 0.0 -1 #( 29 0 1 7 7 UIParent 0.0 450.0 -1 #($U%#&D&%'2($)$ 29 1 1 7 7 UIParent 0.0 425.0 -1 #($U%#&D&%'2($)$ 29 2 1 7 7 UIParent 0.0 400.0 -1 #($U%#&D&%'2($)$]=]

-- Explicit /fbui on only; never change the selected layout during login.
function UI.EnableEditLayout()
    if InCombatLockdown() or UI.editLayoutFinalizing then return false end
    local action = "bereits vorhanden"
    local ok, failure = pcall(function()
        local api = C_EditMode
        assert(api and type(api.GetLayouts) == "function" and type(api.SetActiveLayout) == "function")
        if C_AddOns and C_AddOns.LoadAddOn then C_AddOns.LoadAddOn("Blizzard_EditMode") end
        local manager = EditModeManagerFrame
        assert(manager and not manager:IsForbidden(), "Bearbeitungsmodus nicht verfügbar")
        assert(not manager:IsShown(), "Bitte Bearbeitungsmodus schließen")
        local function findLayout()
            -- Use the same indexed list as Blizzard's dropdown (including presets).
            local info = manager.layoutInfo
            assert(type(info) == "table" and type(info.layouts) == "table")
            for index, layout in pairs(info.layouts) do
                if layout.layoutName == layoutName then return index, info.activeLayout end
            end
        end
        local index, active = findLayout()
        if not index then
            assert(type(manager.ImportLayout) == "function", "Layoutimport nicht verfügbar")
            local info = api.ConvertStringToLayoutInfo(layoutString)
            assert(type(info) == "table" and type(info.systems) == "table" and #info.systems > 0)
            manager:ImportLayout(info, Enum.EditModeLayoutType.Account, layoutName)
            action = "neu importiert"
            index, active = findLayout()
            assert(index, "Layout import failed")
        end
        -- The manager may already show the imported layout before it is active.
        active = api.GetLayouts().activeLayout
        if index ~= active then
            api.SetActiveLayout(index)
            action = action .. ", ausgewählt"
        else
            action = action .. ", bereits aktiv"
        end
        UI.editLayoutPending = {index=index, action=action}
    end)
    if not ok then
        UI.Message("Layout konnte nicht aktiviert werden: " .. tostring(failure))
    end
    return ok
end

-- Let import notifications settle before committing the explicit setup/reload.
function UI.CompleteEditLayoutSetup(onReady)
    local pending = UI.editLayoutPending
    if not pending or UI.editLayoutFinalizing then return end
    UI.editLayoutFinalizing = true
    local attempts = 0
    local function finish()
        if UI.editLayoutPending ~= pending then UI.editLayoutFinalizing = nil; return end
        local ok, selected = pcall(function()
            assert(not InCombatLockdown(), "Bitte nach dem Kampf erneut versuchen")
            local manager = EditModeManagerFrame
            assert(manager and not manager:IsForbidden() and not manager:IsShown(), "Bitte Bearbeitungsmodus schließen")
            local layout = manager.layoutInfo.layouts[pending.index]
            assert(layout and layout.layoutName == layoutName, "Layoutliste hat sich geändert")
            local active = C_EditMode.GetLayouts().activeLayout
            if attempts == 0 and active ~= pending.index then
                C_EditMode.SetActiveLayout(pending.index)
                return false -- Confirm on the next tick, never reload in a write callback.
            end
            return active == pending.index
        end)
        attempts = attempts + 1
        if ok and not selected and attempts < 5 then
            C_Timer.After(0.1, finish)
            return
        end
        UI.editLayoutFinalizing = nil
        UI.editLayoutPending = nil
        if not ok or not selected then
            UI.Message("Layoutauswahl nicht bestätigt. Bitte Einrichtung erneut starten.")
            return
        end
        ForeverbuddyuiDB.editLayoutResult = pending.action
        onReady()
    end
    C_Timer.After(0, finish)
end

-- One-shot confirmation for the explicit command, surviving its ReloadUI.
function UI.ReportEditLayoutResult()
    local result = ForeverbuddyuiDB and ForeverbuddyuiDB.editLayoutResult
    if not result then return end
    ForeverbuddyuiDB.editLayoutResult = nil
    local ok, activeName = pcall(function()
        local info = EditModeManagerFrame and EditModeManagerFrame.layoutInfo or C_EditMode.GetLayouts()
        local layout = info.layouts[info.activeLayout]
        return layout and layout.layoutName
    end)
    if ok and activeName == layoutName then
        UI.Message("Layout-Import: " .. result .. ". Nach Reload aktiv: " .. activeName .. ".")
    else
        UI.Message("Layout-Import: " .. result .. ". Nach Reload nicht bestätigt; aktives Layout: " .. (ok and tostring(activeName) or "nicht lesbar") .. ".")
    end
end

-- Read-only diagnosis without a reload, including when the addon is disabled.
function UI.PrintEditLayoutStatus()
    UI.Message("Layoutstatus: Import-Erweiterung geladen (Diagnose 2).")
    local ok, failure = pcall(function()
        assert(C_EditMode and type(C_EditMode.GetLayouts) == "function", "Layout-API fehlt")
        local info = EditModeManagerFrame and EditModeManagerFrame.layoutInfo or C_EditMode.GetLayouts()
        assert(type(info) == "table" and type(info.layouts) == "table", "Layoutliste nicht verfügbar")
        UI.Message("Aktiver Layoutindex: " .. tostring(info.activeLayout))
        local found = false
        for index, layout in pairs(info.layouts) do
            if type(layout) == "table" then
                UI.Message("Layout " .. tostring(index) .. ": " .. tostring(layout.layoutName)
                    .. (index == info.activeLayout and " [aktiv]" or ""))
                if layout.layoutName == layoutName then found = true end
            end
        end
        UI.Message("ForeverBuddyUI Korrigiert-Layout: " .. (found and "vorhanden" or "fehlt"))
    end)
    if not ok then UI.Message("Layoutstatus: " .. tostring(failure)) end
end
