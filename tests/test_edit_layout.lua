local combat = false
function InCombatLockdown() return combat end
local UI = {Message=function() end}
assert(loadfile('EditLayout.lua'))('Foreverbuddyui', UI)
local info = {activeLayout=1, layouts={{layoutName='Other'}}}
local imports, selections = 0, 0
Enum = {EditModeLayoutType={Account=1}}
C_EditMode = {
    GetLayouts=function() return info end,
    SetActiveLayout=function(index) selections=selections+1; info.activeLayout=index end,
    ConvertStringToLayoutInfo=function(value)
        assert(value:find("5 0 59 0 0 0 4 4 UIParent 0.0 -236.6 -1",1,true)==1)
        assert(value:find("0 1 0 6 0 MainActionBar 0.0 4.0 -1",1,true))
        assert(value:match('29 2 1 7 7'))
        return {systems={{}}}
    end,
}
EditModeManagerFrame = {
    layoutInfo=info,
    IsForbidden=function() return false end,
    IsShown=function() return false end,
    ImportLayout=function(_, layout, kind, name)
        imports=imports+1
        assert(kind==1)
        layout.layoutName=name
        table.insert(info.layouts,layout)
    end,
}
assert(UI.EnableEditLayout() and imports==1 and selections==1)
info.layouts[2].custom=true
info.activeLayout=1
assert(UI.EnableEditLayout() and imports==1 and selections==2 and info.layouts[2].custom)
assert(UI.EnableEditLayout() and selections==2)
combat=true
assert(not UI.EnableEditLayout() and selections==2)
combat=false
info.layouts[2]=nil
C_EditMode.ConvertStringToLayoutInfo=function() return nil end
assert(not UI.EnableEditLayout() and imports==1)
C_EditMode=nil
assert(not UI.EnableEditLayout())
print('PASS: layout import, selection, preserved edits, combat and unavailable API')

ForeverbuddyuiDB={editLayoutResult="bereits vorhanden"}
local messages={}
UI.Message=function(message) messages[#messages+1]=message end
C_EditMode={GetLayouts=function() return {activeLayout=1,layouts={{layoutName="ForeverBuddyUI Korrigiert"}}} end}
EditModeManagerFrame.layoutInfo=C_EditMode.GetLayouts()
UI.ReportEditLayoutResult()
assert(#messages==1 and messages[1]:find("Nach Reload aktiv",1,true))
UI.ReportEditLayoutResult()
assert(#messages==1 and ForeverbuddyuiDB.editLayoutResult==nil)
ForeverbuddyuiDB.editLayoutResult="neu importiert"
C_EditMode=nil
EditModeManagerFrame.layoutInfo=nil
UI.ReportEditLayoutResult()
assert(#messages==2 and messages[2]:find("nicht lesbar",1,true))
print("PASS: reload result reported once; missing API handled")

C_EditMode={GetLayouts=function() return {activeLayout=3,layouts={[3]={layoutName="ForeverBuddyUI Korrigiert"}}} end}
messages={}
EditModeManagerFrame.layoutInfo=C_EditMode.GetLayouts()
UI.PrintEditLayoutStatus()
assert(messages[1]:find("Diagnose 2",1,true))
assert(messages[3]:find("ForeverBuddyUI Korrigiert [aktiv]",1,true))
assert(messages[4]:find("vorhanden",1,true))
C_EditMode=nil
assert(pcall(UI.PrintEditLayoutStatus))
print("PASS: read-only layout status with sparse indices and unavailable API")

-- The dropdown includes preset indices; raw API arrays need not match them.
local dropdown={activeLayout=2,layouts={[3]={layoutName="ForeverBuddy"},[4]={layoutName="ForeverBuddyUI Korrigiert"}}}
EditModeManagerFrame.layoutInfo=dropdown
C_EditMode={
    GetLayouts=function() return {activeLayout=dropdown.activeLayout,layouts={{layoutName="ForeverBuddy"},{layoutName="ForeverBuddyUI Korrigiert"}}} end,
    SetActiveLayout=function(index) assert(index==4); dropdown.activeLayout=index end,
}
assert(UI.EnableEditLayout() and dropdown.activeLayout==4 and imports==1)
print("PASS: selection uses Blizzard dropdown indices instead of raw layout array indices")

dropdown.layouts[4].layoutName="Foreverbuddyui"
C_EditMode.ConvertStringToLayoutInfo=function() return {systems={{}}} end
EditModeManagerFrame.ImportLayout=function(_,layout,kind,name)
    imports=imports+1
    layout.layoutName=name
    dropdown.layouts[5]=layout
end
C_EditMode.SetActiveLayout=function(index) assert(index==5); dropdown.activeLayout=index end
assert(UI.EnableEditLayout() and dropdown.layouts[4].layoutName=="Foreverbuddyui" and dropdown.layouts[5].layoutName=="ForeverBuddyUI Korrigiert")
print("PASS: corrected template imported separately; old custom layout preserved")

-- Import notifications and manager cache must not decide whether reload is safe.
local queue, completed, writes = {}, 0, 0
C_Timer={After=function(_,callback) queue[#queue+1]=callback end}
local actual=1
local cached={activeLayout=4,layouts={[4]={layoutName="ForeverBuddyUI Korrigiert"}}}
EditModeManagerFrame={layoutInfo=cached,IsForbidden=function() return false end,IsShown=function() return false end}
ForeverbuddyuiDB={}
C_EditMode={GetLayouts=function() return {activeLayout=actual} end,
    SetActiveLayout=function(index) writes=writes+1; actual=index end}
assert(UI.EnableEditLayout() and actual==4 and writes==1, "stale manager cache must not skip real selection")
-- Simulate an import notification restoring the old selection in this frame.
actual=1
UI.CompleteEditLayoutSetup(function() completed=completed+1 end)
assert(completed==0, "never reload in the import call stack")
table.remove(queue,1)()
assert(completed==0 and #queue==1)
table.remove(queue,1)()
assert(completed==1 and actual==4 and writes==2 and ForeverbuddyuiDB.editLayoutResult)

-- Delayed selection confirmation is awaited, without repeated writes.
actual=1
C_EditMode.SetActiveLayout=function() writes=writes+1 end
assert(UI.EnableEditLayout())
UI.CompleteEditLayoutSetup(function() completed=completed+1 end)
table.remove(queue,1)()
assert(completed==1 and #queue==1)
actual=4
table.remove(queue,1)()
assert(completed==2 and #queue==0)

-- A rejected selection times out and never enables/reloads the addon.
actual=1
assert(UI.EnableEditLayout())
UI.CompleteEditLayoutSetup(function() error("must not reload on failure") end)
local checks=0
while #queue>0 do checks=checks+1; assert(checks<=5); table.remove(queue,1)() end
assert(not UI.editLayoutPending and not UI.editLayoutFinalizing)

actual=4
assert(UI.EnableEditLayout())
UI.CompleteEditLayoutSetup(function() error("must not reload in combat") end)
combat=true
table.remove(queue,1)()
combat=false
assert(not UI.editLayoutFinalizing)
assert(UI.EnableEditLayout())
UI.CompleteEditLayoutSetup(function() error("off must cancel pending setup") end)
UI.editLayoutPending=nil
table.remove(queue,1)()
assert(not UI.editLayoutFinalizing)
print("PASS: stale import cache, deferred selection, bounded confirmation, failure, combat and cancellation")
