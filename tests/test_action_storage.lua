local loadfile = dofile("tests/load_locales.lua")
-- Vertrags-/Zustandstests für die Aktionsleisten-Vorlagen.
-- Kein Client, keine Taint-Simulation: geprüft werden Guards, Profile und Ereignisfluss.
local secret=setmetatable({},{__tostring=function() error('secret formatted') end})
function issecretvalue(v) return rawequal(v,secret) end

local queue={}
local now=10
function GetTime() return now end
C_Timer={After=function(_,fn) queue[#queue+1]=fn end}
local function drain()
    local count=0
    while #queue>0 do
        local fn=table.remove(queue,1);fn();count=count+1
        assert(count<300,'timer loop')
    end
end

local methods={}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:GetScript(k) return self.scripts[k] end
function methods:RegisterEvent(k) self.events[k]=true end
function methods:UnregisterEvent(k) self.events[k]=nil end
function methods:IsShown() return self.shown end
function methods:SetShown(v) self.shown=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetText(v) self.text=v end
function methods:GetText() return self.text end
function methods:SetSize(w,h) self.width=w;self.height=h end
function methods:SetWidth(v) self.width=v end
function methods:SetPoint(...) self.points[#self.points+1]={...} end
function methods:SetJustifyH(v) self.justify=v end
function methods:SetFrameStrata(v) self.strata=v end
function methods:SetFrameLevel(v) self.level=v end
function methods:GetWidth() return self.width or 100 end
function methods:GetHeight() return self.height or 24 end
function methods:CreateTexture() return setmetatable({scripts={},events={},points={},shown=true},{__index=function(_,k) return methods[k] or function() end end}) end
function methods:CreateFontString() return setmetatable({scripts={},events={},points={},shown=true},{__index=function(_,k) return methods[k] or function() end end}) end
local frames={}
local function object()
    local f=setmetatable({scripts={},events={},points={},shown=true},{__index=function(_,k) return methods[k] or function() end end})
    frames[#frames+1]=f
    return f
end
function CreateFrame() return object() end
UIParent=object();UISpecialFrames={};SlashCmdList={}

local function fire(event,arg)
    for _,frame in ipairs(frames) do
        if frame.events[event] and frame.scripts.OnEvent then
            frame.scripts.OnEvent(frame,event,arg)
        end
    end
end

-- Forever hat keine Spezialisierungs-API.
function UnitClass() return "Jäger","HUNTER" end
function UnitGUID() return "Player-1-ABC" end
function UnitFullName() return "Buddy","Realm" end
function GetRealmName() return "Realm" end
local clicks={{type=1,actionID=133,button="LeftButton",modifiers=0}}
C_ClickBindings={
    GetProfileInfo=function() return clicks end,
    SetProfileByInfo=function(info) clicks=info end,
    ResetCurrentProfile=function() clicks={} end,
}
function hooksecurefunc(api,key,hook)
    local original=api[key]
    api[key]=function(...) original(...);hook(...) end
end
function GetServerTime() return 1000 end

local combat,bonus=false,false
function InCombatLockdown() return combat end
function HasBonusActionBar() return bonus end
function HasVehicleActionBar() return false end
function HasOverrideActionBar() return false end
function HasTempShapeshiftActionBar() return false end
function HasPossessBar() return false end
function HasAlternateActionBar() return false end
NUM_ACTIONBAR_SLOTS=180

-- Aktionsleistenmodell: Pickup/Place bewegen nur den Cursor.
local bar,cursor={},nil
local macroIndexes={Raid=1,Extra=19,Heal=20}
local function clone(entry)
    if not entry then return end
    return {action=entry.action,value=entry.value}
end
function GetActionInfo(slot)
    local entry=bar[slot]
    if not entry then return end
    if entry.action=="macro" then return "macro",entry.index or macroIndexes[entry.value] end
    if entry.action=="equipmentset" then return "equipmentset",entry.value end
    return entry.action,entry.value
end
function PickupAction(slot)
    cursor=clone(bar[slot]);bar[slot]=nil
    fire("ACTIONBAR_SLOT_CHANGED",slot)
end
function PlaceAction(slot)
    if not cursor then return end
    bar[slot]=clone(cursor);cursor=nil
    fire("ACTIONBAR_SLOT_CHANGED",slot)
end
function ClearCursor() cursor=nil end
function GetCursorInfo() return cursor end

local known={[100]=true,[1943]=true,[133]=true}
C_Spell={PickupSpell=function(id)
    if known[id] then cursor={action="spell",value=id} end
end}
C_Item={PickupItem=function(id) cursor={action="item",value=id} end}
local macroNames={[1]="Raid",[19]="Extra",[20]="Heal"}
function GetNumMacros() return 1,2 end
function GetMacroInfo(index) return macroNames[index] end
function PickupMacro(index)
    local name=macroNames[index]
    if name then cursor={action="macro",index=index,value=name} end
end
MAX_ACCOUNT_MACROS=18

local setIDs={Raid=5}
local setNames={[5]="Raid"}
C_EquipmentSet={
    GetEquipmentSetID=function(name) return setIDs[name] end,
    GetEquipmentSetInfo=function(id) return setNames[id] end,
    PickupEquipmentSet=function(id)
        local name=setNames[id]
        if name then cursor={action="equipmentset",value=name} end
    end,
}
Enum={SpellBookSpellBank={Player=0,Pet=1},SpellBookItemType={Spell=1,Flyout=4}}
C_SpellBook={
    IsSpellKnownOrInSpellBook=function(id) return known[id]==true end,
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=2} end,
    GetSpellBookItemInfo=function(slot)
        if slot==1 then return {itemType=4,actionID=999} end
        return {itemType=1,actionID=100}
    end,
    PickupSpellBookItem=function(slot)
        if slot==1 then cursor={action="flyout",value=999} end
    end,
}

local messages={}
local UI={Message=function(text) messages[#messages+1]=text end}
function UI.GetCharacterSettings()
    ForeverbuddyuiCharDB=ForeverbuddyuiCharDB or {}
    return ForeverbuddyuiCharDB
end
-- Fail if storage ever depends on level, class, role or specialization.
function UnitLevel() return 1 end
function UnitClass() error("class dependency") end
function GetSpecialization() error("specialization dependency") end
C_SpecializationInfo=nil
bar[1]={action="spell",value=133}
assert(loadfile('ActionStorageGame.lua'))('Foreverbuddyui',UI)
assert(loadfile('ActionStorage.lua'))('Foreverbuddyui',UI)
local B=UI.ActionStorage
fire('PLAYER_LOGIN');drain()
local first=ForeverbuddyuiCharDB
assert(first.actions.initialized and first.actions.slots[1].value==133,'level 1 initial snapshot')
assert(first.actions.clickBindings[1].actionID==133)
clicks[1].actionID=100
assert(first.actions.clickBindings[1].actionID==133,'click bindings copied')
bar[1]={action="spell",value=100}
assert(B.RestoreCharacter())
assert(bar[1].value==133 and clicks[1].actionID==133,'restore without specialization')
now=20
bar[1]={action="spell",value=100};fire('ACTIONBAR_SLOT_CHANGED',1);drain()
C_ClickBindings.SetProfileByInfo({{type=1,actionID=100,button="RightButton",modifiers=1}});drain()
assert(first.actions.slots[1].value==100 and first.actions.clickBindings[1].button=='RightButton','automatic edits')
-- Talent/spec changes restore this same snapshot without querying their APIs.
now=25
bar[1]={action="spell",value=1943}
fire('PLAYER_SPECIALIZATION_CHANGED','player')
fire('ACTIONBAR_SLOT_CHANGED',1);fire('PLAYER_TALENT_UPDATE');drain()
assert(bar[1].value==100 and first.actions.slots[1].value==100,'same character snapshot across talent changes')
-- A second character of the same class has an independent snapshot.
ForeverbuddyuiCharDB=nil
bar[1]={action="spell",value=1943}
B.RestoreCharacter()
local second=ForeverbuddyuiCharDB
assert(second~=first and second.actions.slots[1].value==1943)
ForeverbuddyuiCharDB=first
combat=true;bar[1]={action="spell",value=1943}
assert(not B.RestoreCharacter() and bar[1].value==1943,'no combat writes')
fire('ACTIONBAR_SLOT_CHANGED',1);drain()
assert(first.actions.slots[1].value==100,'combat does not erase saved state')
combat=false;fire('PLAYER_REGEN_ENABLED');drain()
assert(bar[1].value==100,'restore deferred to combat end')
now=30
cursor={action='item',value=12};bar[1]={action='spell',value=1943}
assert(not B.RestoreCharacter() and cursor.value==12,'occupied cursor preserved')
cursor=nil;fire('CURSOR_CHANGED');drain();assert(bar[1].value==100)
now=40
bonus=true;bar[1]={action='spell',value=1943}
assert(not B.RestoreCharacter())
bonus=false;fire('UPDATE_BONUS_ACTIONBAR');assert(bar[1].value==100)
-- API rejection must not report success or overwrite the backup.
now=50
local place=PlaceAction
PlaceAction=function() end
bar[1]={action='spell',value=1943}
assert(not B.RestoreCharacter() and first.actions.slots[1].value==100)
assert(#messages>0)
PlaceAction=place
local setClicks=C_ClickBindings.SetProfileByInfo
C_ClickBindings.SetProfileByInfo=function() end
clicks={}
assert(not B.RestoreCharacter() and first.actions.clickBindings[1].actionID==100)
C_ClickBindings.SetProfileByInfo=setClicks
assert(B.RestoreCharacter())
-- Unknown/secret reads retain the prior slot; macro exclusions remain intact.
now=60
local get=GetActionInfo
GetActionInfo=function(slot) if slot==1 then return secret,secret end;return get(slot) end
fire('ACTIONBAR_SLOT_CHANGED',1);drain()
assert(first.actions.slots[1].value==100)
GetActionInfo=get
bar[1]={action='unknown',value=3};fire('ACTIONBAR_SLOT_CHANGED',1);drain()
assert(first.actions.slots[1].value==100)
bar[1]={action='macro',index=1};fire('ACTIONBAR_SLOT_CHANGED',1);drain()
assert(first.actions.slots[1]==nil,'account macro excluded')
bar[121]={action='spell',value=1943}
first.actions.slots[121]={action='spell',value=100}
B.RestoreCharacter();assert(bar[121].value==1943,'reserved slots never written')
-- Completely unavailable action data must not become a valid empty snapshot.
ForeverbuddyuiCharDB=nil
GetActionInfo=nil
B.RestoreCharacter();assert(not ForeverbuddyuiCharDB.actions.initialized)
GetActionInfo=get
B.RestoreCharacter();assert(ForeverbuddyuiCharDB.actions.initialized)
ForeverbuddyuiDB={enabled=false}
assert(not B.OwnsAutomaticStorage() and not B.RestoreCharacter(),'off retains native behavior')
print('PASS: level 1, character isolation, click bindings, combat/cursor/special bars, API rejection, secret values and unavailable data')
