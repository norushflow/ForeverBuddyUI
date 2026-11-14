local _, UI = ...

local activeUnits = {}
local indicators = {}
UI.nameplateQuestProgressIndicators = indicators

local function parseCount(text)
    local current, total = text:match("(%d+)%s*/%s*(%d+)")
    current, total = tonumber(current), tonumber(total)
    if not current or not total or total < 1 then return end
    return current, total
end

local function progressFor(unit)
    -- The unit tooltip associates the objective with this particular creature,
    -- including loot objectives whose text does not contain the creature name.
    if C_TooltipInfo and type(C_TooltipInfo.GetUnit) == "function" then
        local ok, data = pcall(C_TooltipInfo.GetUnit, unit)
        if ok and UI.Public(data) and type(data) == "table"
            and UI.Public(data.lines) and type(data.lines) == "table" then
            local objectiveType = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestObjective or 8
            local completedProgress
            for _, line in ipairs(data.lines) do
                if UI.Public(line) and type(line) == "table" and UI.Public(line.type)
                    and line.type == objectiveType then
                    local current, total = line.numFulfilled, line.numRequired
                    if not UI.Public(current) or not UI.Public(total)
                        or type(current) ~= "number" or type(total) ~= "number" then
                        local text = line.leftText
                        if UI.Public(text) and type(text) == "string" then current, total = parseCount(text) end
                    end
                    if UI.Public(current) and UI.Public(total) and type(current) == "number"
                        and type(total) == "number" and total > 0 then
                        local result = current .. "/" .. total
                        if current < total then return result, false end
                        completedProgress = result
                    end
                end
            end
            if completedProgress then return completedProgress, true end
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle
        or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then return end
    local name = UnitName(unit)
    if not UI.Public(name) or type(name) ~= "string" or name == "" then return end
    local needle = name:lower()
    local entries = GetNumQuestLogEntries()
    if not UI.Public(entries) or type(entries) ~= "number" then return end
    local completedProgress
    for questIndex = 1, entries do
        local title, _, _, isHeader = GetQuestLogTitle(questIndex)
        if isHeader ~= true and UI.Public(title) and type(title) == "string" then
            local objectives = GetNumQuestLeaderBoards(questIndex)
            if UI.Public(objectives) and type(objectives) == "number" then
                for objectiveIndex = 1, objectives do
                    local text, _, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                    if UI.Public(text) and type(text) == "string"
                        and text:lower():find(needle, 1, true) then
                        local current, total = parseCount(text)
                        if current and total then
                            local result = current .. "/" .. total
                            if finished or current >= total then
                                completedProgress = result
                            else
                                return result, false
                            end
                        end
                    end
                end
            end
        end
    end
    if completedProgress then return completedProgress, true end
end

local function makeIndicator()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(48, 20)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font = (GameFontNormal and GameFontNormal:GetFont()) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    frame.text:SetFont(font, 12, "OUTLINE")
    frame.text:SetTextColor(1, 1, 1)
    frame.text:SetPoint("LEFT", frame, "LEFT")
    return frame
end

local function updateUnit(unit)
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if not ok or not plate then return end
    local reference = plate.UnitFrame or plate
    local okProgress, progress = pcall(progressFor, unit)
    local indicator = indicators[unit]
    if not okProgress then
        if indicator then indicator:Hide() end
        return
    end
    if not progress then
        if indicator then indicator:Hide() end
        return
    end
    if not indicator then
        indicator = makeIndicator()
        indicators[unit] = indicator
    end
    if indicator.relativeTo ~= reference then
        indicator:ClearAllPoints()
        indicator:SetPoint("LEFT", reference, "RIGHT", 32, 0)
        indicator.relativeTo = reference
    end
    indicator.text:SetText(progress)
    indicator:Show()
end

local function updateAll()
    for unit in pairs(activeUnits) do updateUnit(unit) end
end

function UI.CreateNameplateQuestProgress()
    if UI.nameplateQuestProgressFrame then return end
    if not C_NamePlate or type(C_NamePlate.GetNamePlateForUnit) ~= "function" then return end
    local frame = CreateFrame("Frame", "ForeverbuddyuiNameplateQuestProgress", UIParent)
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    frame:RegisterEvent("QUEST_LOG_UPDATE")
    frame:RegisterEvent("QUEST_WATCH_UPDATE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(_, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" and type(unit) == "string" then
            activeUnits[unit] = true
            updateUnit(unit)
        elseif event == "NAME_PLATE_UNIT_REMOVED" and type(unit) == "string" then
            activeUnits[unit] = nil
            local indicator = indicators[unit]
            if indicator then
                indicator:Hide()
                indicator:ClearAllPoints()
                indicator.relativeTo = nil
            end
        else
            updateAll()
        end
    end)
    UI.nameplateQuestProgressFrame = frame
end
