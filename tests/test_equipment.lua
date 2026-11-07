local combat, timers, frames, hooks = false, {}, {}, {}
local secret = setmetatable({}, {__tostring=function() error("secret formatted") end})
function issecretvalue(v) return rawequal(v,secret) end
function InCombatLockdown() return combat end
local methods = {}
local function frame(parent)
    local f=setmetatable({parent=parent,shown=true,scripts={},events={},children={}},{__index=methods})
    frames[#frames+1]=f
    if parent then parent.children[#parent.children+1]=f end
    return f
end
function CreateFrame(_,_,parent) assert(not (combat and parent));return frame(parent) end
function methods:IsForbidden() return self.forbidden or false end
function methods:IsShown() return self.shown end
function methods:SetAllPoints(target) assert(not combat);self.target=target end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetPoint(...) assert(not combat);self.point={...} end
function methods:ClearAllPoints() assert(not combat);self.point=nil end
function methods:SetSize(w,h) self.width=w;self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:SetWordWrap(v) self.wrap=v end
function methods:SetJustifyH(v) self.justify=v end
function methods:SetText(v) self.text=v;self.value=nil end
function methods:SetFormattedText(fmt,v) self.format=fmt;self.value=v end
function methods:SetTextColor(...) self.color={...} end
function methods:SetTexture(v) self.texture=v end
function methods:SetVertexColor(...) self.color={...} end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:CreateTexture() return frame(self) end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:SetScript(e,fn) self.scripts[e]=fn end
function methods:HookScript(e,fn)
    local old=self.scripts[e]
    self.scripts[e]=function(...) if old then old(...) end;fn(...) end
end
function hooksecurefunc(name,fn) hooks[name]=fn end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local function flush()
    local callbacks=timers;timers={}
    for _,fn in ipairs(callbacks) do fn() end
    assert(#timers==0,"refresh schedules itself")
end
CharacterFrame=frame()
local opened=0
CharacterFrame.scripts.OnShow=function() opened=opened+1 end
for _,name in ipairs({"Head","Finger0","Finger1","MainHand","SecondaryHand"}) do _G["Character"..name.."Slot"]=frame(CharacterFrame) end
function PaperDollItemSlotButton_Update() end
ENCHANTED_TOOLTIP_LINE="Verzaubert: %s"
local links={[1]="item:100:7:",[11]="item:200:0:",[12]="item:200:0:",[16]="item:300:5:",[17]="item:400:0:"}
local levels={[100]=285,[300]=secret,[400]=280}
local calls,loads=0,{}
local data={
    [1]={lines={{type=15,leftText="Verzaubert: Stärke |A:quality:20:20|a"},{type=3,gemIcon=123},{type=3,socketType="Prismatic"}}},
    [11]={lines={{type=0,leftText="Ring"}}},[12]={lines={{type=0,leftText="Ring"}}},
    [16]={lines={{type=15,leftText="Verzaubert: Tempo"}}},[17]={lines={{type=0,leftText="Schild"}}},
}
function GetInventoryItemLink(_,slot) return links[slot] end
function GetInventoryItemQuality() return 4 end
function UnitLevel() return 90 end
function GetExpansionForLevel() return 11 end
GameRulesUtil={GetEffectiveMaxLevelForPlayer=function() return 90 end}
C_Item={
    GetDetailedItemLevelInfo=function(link) return levels[tonumber(link:match("item:(%d+)"))] end,
    GetItemInfoInstant=function(link) return tonumber(link:match("item:(%d+)")),nil,nil,"INVTYPE_SHIELD" end,
    GetItemQualityColor=function(q) assert(q==4);return .64,.2,.9 end,
    RequestLoadItemDataByID=function(id) loads[id]=(loads[id] or 0)+1 end,
}
C_TooltipInfo={GetInventoryItem=function(_,slot) calls=calls+1;return data[slot] end}
local UI={started=false,Public=function(v) return not issecretvalue(v) end,Text=function(parent) return frame(parent) end}
assert(loadfile("Equipment.lua"))("Foreverbuddyui",UI)
local function event(name,arg)
    for _,f in ipairs(frames) do if f.events[name] then f.scripts.OnEvent(f,name,arg) end end
end
UI.InstallEquipment();event("UNIT_INVENTORY_CHANGED","player");flush()
assert(#CharacterHeadSlot.children==0,"disabled UI installed equipment")
UI.started=true;combat=true;UI.InstallEquipment();flush()
assert(#CharacterHeadSlot.children==0,"combat startup installed equipment")
combat=false;event("PLAYER_REGEN_ENABLED");flush()
local head,ring1,ring2=CharacterHeadSlot.children[1],CharacterFinger0Slot.children[1],CharacterFinger1Slot.children[1]
local main,off=CharacterMainHandSlot.children[1],CharacterSecondaryHandSlot.children[1]
assert(head and head.level.value==285 and head.level.color[1]==.64)
assert(head.enchant.text=="Stärke |A:quality:20:20|a","localized enchant/atlas damaged")
assert(head.sockets[1].texture==123 and head.sockets[1].shown)
assert(head.sockets[2].texture:find("EmptySocket-Prismatic",1,true) and head.sockets[2].shown)
assert(not head.sockets[3].shown and not head.sockets[4].shown)
assert(head.sockets[1].point[1]=="LEFT" and ring1.sockets[1].point[1]=="RIGHT")
assert(main.level.value==secret,"secret ilvl not forwarded unchanged")
assert(off.enchant.text=="","shield warning")
assert(ring1.enchant.text=="Verzauberung fehlt" and loads[200]==1,"duplicate item load")
levels[200]=282;event("ITEM_DATA_LOAD_RESULT",200);flush()
assert(ring1.level.value==282 and ring2.level.value==282,"duplicate slots not refreshed")
local before=calls
for i=1,20 do hooks.PaperDollItemSlotButton_Update(CharacterHeadSlot) end
assert(#timers==1);flush();assert(calls==before+5,"not batched")
CharacterFrame.shown=false;before=calls
event("UNIT_INVENTORY_CHANGED","player");event("SOCKET_INFO_UPDATE");flush()
assert(calls==before,"hidden window scanned")
CharacterFrame.shown=true;CharacterFrame.scripts.OnShow();flush()
assert(opened==1 and #CharacterHeadSlot.children==1,"OnShow replaced or duplicate display")
links[1]=nil;combat=true;event("PLAYER_EQUIPMENT_CHANGED");flush()
assert(head.level.value==285,"combat mutation")
combat=false;event("PLAYER_REGEN_ENABLED");flush()
assert(head.level.text=="" and head.enchant.text=="" and not head.sockets[1].shown,"stale unequip display")
links[1]="item:100:0:"
data[1]={lines={{type=15,leftText=secret},{type=secret,leftText=secret},{type=3,gemIcon=secret,socketType="Prismatic"}}}
event("UNIT_INVENTORY_CHANGED","player");flush()
assert(head.enchant.text=="" and not head.sockets[1].shown,"secret tooltip interpreted")
data[1]=secret;event("SOCKET_INFO_UPDATE");flush();assert(head.enchant.text=="")
data[1]=nil;event("SOCKET_INFO_UPDATE");flush()
local requested=loads[100];event("ITEM_DATA_LOAD_RESULT",100);flush()
assert(loads[100]==requested,"endless failed load retries")
data[1]={lines={{type=0,leftText="Verzaubert: Beweglichkeit"}}}
CharacterHeadSlot.forbidden=true;event("SOCKET_INFO_UPDATE");flush();assert(head.enchant.text=="")
CharacterHeadSlot.forbidden=false;event("SOCKET_INFO_UPDATE");flush()
assert(head.enchant.text=="Beweglichkeit","localized fallback")
before=calls;event("UNIT_INVENTORY_CHANGED",secret);flush();assert(calls==before)
links[1]="item:100::";data[1]={lines={{type=0,leftText="Helm"}}}
event("PLAYER_EQUIPMENT_CHANGED");flush()
assert(head.enchant.text=="Verzauberung fehlt","empty enchant field not detected")
-- Verspaetete Itemantwort darf nicht die vorherige Ausruestung wiederherstellen.
levels[100]=nil;event("PLAYER_EQUIPMENT_CHANGED");flush()
links[1]=nil;levels[100]=285;event("ITEM_DATA_LOAD_RESULT",100);flush()
assert(head.level.text=="" and head.enchant.text=="","stale item result restored removed item")
before=calls;UI.QueueEquipment();combat=true;flush();assert(calls==before,"queued update crossed combat boundary")
combat=false;event("PLAYER_REGEN_ENABLED");flush()
CharacterFrame=frame();UI.InstallEquipment();flush();assert(CharacterFrame.scripts.OnShow,"late frame not hooked")
assert(not BetterCharacterPanel,"must run without BetterCharacterPanel")
print("PASS: equipment, localization, sockets, raw ilvl, duplicate loading, hidden/combat/secret/forbidden guards")
