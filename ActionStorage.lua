local _, UI = ...
local L = UI.L
local B = UI.ActionStorage
-- Optional coordination with ForeverBuddy; neither addon requires the other.
ForeverBuddyUIActionStorage = B
function B.OwnsAutomaticStorage()
    return not ForeverbuddyuiDB or ForeverbuddyuiDB.enabled ~= false
end
local ready, applying, pending, queued, suppressUntil = false, false, false, false, 0
local dirty, clicksDirty = {}, false
local restoreQueued=false
local clickFields={"type","actionID","button","modifiers"}

local function database()
    local character = UI.GetCharacterSettings()
    if not B.Table(character.actions) then character.actions = {slots={}} end
    if not B.Table(character.actions.slots) then character.actions.slots = {} end
    return character.actions
end
local function equalClicks(a,b)
    if not a or not b or #a~=#b then return false end
    for i,v in ipairs(a) do
        local other=b[i]
        for _,key in ipairs(clickFields) do
            if v[key]~=other[key] then return false end
        end
    end
    return true
end
function B.SaveCharacter(initial)
    if not B.OwnsAutomaticStorage() or not ready or applying or pending or B.Reason() then return false end
    local db=database()
    local readable=0
    initial=initial or not db.initialized
    for _,slot in ipairs(B.slots) do
        if initial or dirty[slot] then
            local entry=B.Read(slot)
            -- Unknown/unreadable data never erases an earlier usable snapshot.
            if entry then readable=readable+1 end
            if entry and entry.action~="keep" then
                db.slots[slot]=entry.action~="ignored" and entry or nil
            end
        end
    end
    if initial or clicksDirty or db.clickBindings==nil then
        local clicks=B.ReadClickBindings()
        if clicks then db.clickBindings=clicks;clicksDirty=false end
    end
    dirty={}
    if not initial or readable>0 then db.initialized=true end
    return db.initialized==true
end
function B.RestoreCharacter()
    if not B.OwnsAutomaticStorage() or not ready or applying then return false end
    if B.Reason() or not B.CursorFree() then pending=true;return false end
    local db=database()
    if not db.initialized then pending=false;return B.SaveCharacter(true) end
    if not B.APIs() then pending=true;return false end
    pending=false;applying=true
    local complete=true
    local ok=pcall(function()
        for _,slot in ipairs(B.slots) do
            if B.Reason() then error("combat") end
            local entry=db.slots[slot]
            if B.Table(entry) and B.Settable(slot) and entry.action~="keep" and entry.action~="ignored" then
                local current=B.Read(slot)
                if current and (current.action=="keep" or current.action=="ignored") then
                    complete=false
                elseif current and (current.action~=entry.action or current.value~=entry.value) then
                    if entry.action=="empty" then
                        PickupAction(slot);B.ClearCursor()
                    elseif B.Pick(entry) then
                        if B.Reason() then error("combat") end
                        PlaceAction(slot);B.ClearCursor()
                    else complete=false end
                    local actual=B.Read(slot)
                    if not actual or actual.action~=entry.action or actual.value~=entry.value then complete=false end
                elseif not current then complete=false end
            end
        end
        if db.clickBindings then
            local desired=B.CopyClickBindings(db.clickBindings)
            if not equalClicks(desired,B.ReadClickBindings()) then
                if not B.ApplyClickBindings(db) or not equalClicks(desired,B.ReadClickBindings()) then complete=false end
            end
        end
    end)
    B.ClearCursor();applying=false
    suppressUntil=B.Now()+1.5
    pending=not ok and B.Reason()~=nil
    -- No polling or repeated protected writes after an API rejection.
    -- A manual slash invocation supplies a hardware event on clients requiring it.
    if not ok or not complete then
        UI.Message(L["Leisten oder Klickzauber konnten nicht vollständig geladen werden. Außerhalb des Kampfes /fbui restore versuchen; die Sicherung bleibt erhalten."])
    end
    return ok and complete
end
local function queueSave()
    if queued then return end
    queued=true
    C_Timer.After(.5,function() queued=false;B.SaveCharacter(false) end)
end
local function changedClicks()
    if not ready or applying or pending or B.Now()<suppressUntil then return end
    clicksDirty=true;queueSave()
end
local hooked={}
local function installClickHooks()
    if C_ClickBindings and type(hooksecurefunc)=="function" then
        for _,method in ipairs({"SetProfileByInfo","ResetCurrentProfile"}) do
            if not hooked[method] and type(C_ClickBindings[method])=="function" then
                hooksecurefunc(C_ClickBindings,method,changedClicks)
                hooked[method]=true
            end
        end
    end
end
installClickHooks()
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_LOGOUT","ACTIONBAR_SLOT_CHANGED","PLAYER_REGEN_ENABLED",
    "CURSOR_CHANGED","UPDATE_OVERRIDE_ACTIONBAR","UPDATE_VEHICLE_ACTIONBAR","UPDATE_POSSESS_BAR",
    "UPDATE_SHAPESHIFT_FORM","UPDATE_BONUS_ACTIONBAR"}) do events:RegisterEvent(event) end
-- Optional events vary between clients; no specialization API is queried.
local contextEvents={PLAYER_SPECIALIZATION_CHANGED=true,ACTIVE_TALENT_GROUP_CHANGED=true,PLAYER_TALENT_UPDATE=true}
for event in pairs(contextEvents) do pcall(events.RegisterEvent,events,event) end
events:SetScript("OnEvent",function(_,event,slot)
    if event=="PLAYER_LOGIN" then
        installClickHooks()
        C_Timer.After(2,function() ready=true;B.RestoreCharacter() end)
    elseif contextEvents[event] then
        if not ready or (event=="PLAYER_SPECIALIZATION_CHANGED" and slot and slot~="player") then return end
        pending=true;dirty={};clicksDirty=false
        if not restoreQueued then
            restoreQueued=true
            C_Timer.After(1,function() restoreQueued=false;B.RestoreCharacter() end)
        end
    elseif event=="ACTIONBAR_SLOT_CHANGED" then
        if not ready or applying or pending or B.Now()<suppressUntil then return end
        if B.ValidSlot(slot) then dirty[slot]=true;queueSave() end
    elseif event=="PLAYER_LOGOUT" then
        B.SaveCharacter(false)
    elseif ready then
        if pending then B.RestoreCharacter()
        elseif next(dirty) or clicksDirty then queueSave() end
    end
end)
