local combat, shown, forbidden = false, false, false
function InCombatLockdown() return combat end
local UI={Message=function() end}
assert(loadfile("EditLayout.lua"))("Foreverbuddyui",UI)
ForeverbuddyuiDB={}
Enum={EditModeLayoutType={Preset=0,Account=1}}
local raw, cache, active, imports, saves, writes, completed, queue
local reject, delayed, invalid
local function reset(existing)
    raw={{layoutName="Other",layoutType=1,systems={{keep=true}}}}
    cache={[3]=raw[1]}
    if existing then
        raw[2]={layoutName="ForeverBuddyUI",layoutType=1,systems={{custom=true}}}
        cache[4]=raw[2]
    end
    active=3;imports=0;saves=0;writes=0;completed=0;queue={}
    reject=false;delayed=false;invalid=false
    UI.editLayoutPending=nil;UI.editLayoutFinalizing=nil
    C_Timer={After=function(_,callback) queue[#queue+1]=callback end}
    C_EditMode={
        GetLayouts=function() return {activeLayout=active,layouts=raw} end,
        ConvertStringToLayoutInfo=function(value)
            assert(#value>1000)
            if invalid then return nil end
            return {systems={{template=true}}}
        end,
        SetActiveLayout=function(index)
            writes=writes+1
            if not reject and not delayed then active=index end
        end,
        SaveLayouts=function(data)
            saves=saves+1
            assert(data.layouts~=raw and data.layouts[1]~=raw[1], "never mutate original API or manager tables")
            assert(data.layouts[1].systems[1].keep)
            assert(data.layouts[2].systems[1].template and not data.layouts[2].systems[1].custom)
            assert(cache[4].systems[1].custom, "manager cache must stay untouched")
            raw=data.layouts
        end,
    }
    EditModeManagerFrame={layoutInfo={activeLayout=3,layouts=cache},
        IsForbidden=function() return forbidden end, IsShown=function() return shown end,
        ImportLayout=function(_,data,kind,title)
            imports=imports+1;data.layoutName=title;data.layoutType=kind
            raw[#raw+1]=data;cache[#raw+2]=data
        end,
    }
end
local function complete()
    UI.CompleteEditLayoutSetup(function() completed=completed+1 end)
end
local function drain()
    local count=0
    while #queue>0 do count=count+1;assert(count<=5);table.remove(queue,1)() end
end
reset(false)
assert(UI.EnableEditLayout() and imports==1 and saves==0 and active==4)
complete();assert(completed==0);drain();assert(completed==1)
assert(ForeverbuddyuiDB.editLayoutResult)
UI.ReportEditLayoutResult();assert(not ForeverbuddyuiDB.editLayoutResult)
assert(pcall(UI.PrintEditLayoutStatus))
reset(true)
assert(UI.EnableEditLayout() and saves==1 and imports==0 and active==4)
assert(raw[2].layoutName=="ForeverBuddyUI" and raw[1].systems[1].keep)
complete();drain();assert(completed==1)
reset(true)
EditModeManagerFrame.layoutInfo.activeLayout=4
assert(UI.EnableEditLayout() and writes==1, "stale manager selection must not skip actual activation")
active=3;complete();table.remove(queue,1)()
assert(completed==0 and writes==2);drain();assert(completed==1)
reset(true);delayed=true
assert(UI.EnableEditLayout());complete();table.remove(queue,1)()
assert(completed==0);active=4;drain();assert(completed==1)
reset(true);reject=true
assert(UI.EnableEditLayout());complete();drain();assert(completed==0 and not UI.editLayoutFinalizing)
reset(true);combat=true
assert(not UI.EnableEditLayout() and saves==0);combat=false
shown=true;assert(not UI.EnableEditLayout() and saves==0);shown=false
forbidden=true;assert(not UI.EnableEditLayout() and saves==0);forbidden=false
invalid=true;assert(not UI.EnableEditLayout() and saves==0 and raw[2].systems[1].custom)
reset(true);assert(UI.EnableEditLayout());complete();combat=true;drain();combat=false;assert(completed==0)
reset(true);assert(UI.EnableEditLayout());complete();UI.editLayoutPending=nil;drain();assert(completed==0)
reset(true);C_EditMode.SaveLayouts=nil;assert(not UI.EnableEditLayout() and raw[2].systems[1].custom)
reset(true);C_EditMode=nil;assert(not UI.EnableEditLayout())
print("PASS: import, overwrite exact name, preserve other layouts, snapshot isolation, actual selection, timeout and guards")
