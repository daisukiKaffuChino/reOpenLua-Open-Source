require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.text.InputType"
import "com.google.android.material.textfield.TextInputLayout"
import "com.google.android.material.textfield.TextInputEditText"

require "permission"

projectdir,theme = ...
import ("themes."..theme)
activity.setTitle('工程属性')
activity.getWindow().setNavigationBarColor(0)

MDC_R=luajava.bindClass"com.google.android.material.R"
import "alys.page_project_info"
activity.setContentView(loadlayout(page_project_info))

plist=ListView(activity)
dlg=LuaDialog(activity)
dlg.title="更改权限"
dlg.view=plist
dlg.setPositiveButton("确定",nil)
btn.onClick=function()
  dlg.show()
end

luaproject=projectdir.."/init.lua"
app={}
loadfile(luaproject,"bt",app)()
appname.Text=app.appname or "OpenLua"
appver.Text=app.appver or "1.0"
appcode.Text=app.appcode or "1"
packagename.Text=app.packagename or "com.open.demo"
debugmode.Checked=app.debugmode==nil or app.debugmode
extendedOutputBtn.Checked=app.enableExtendedOutputSupport==nil or app.enableExtendedOutputSupport
dialogLogBtn.Checked=app.enableDialogLog==nil or app.enableDialogLog
apptime.Text = app.welcome_time or "0"
if app.enableLegacyTheme==nil then legacyThemeSw.Checked=false else legacyThemeSw.Checked=app.enableLegacyTheme end

local function isShowTlist(b)
  if b then
    tlist.Visibility=0
   else
    tlist.Visibility=8
  end
end

isShowTlist(legacyThemeSw.isChecked())

legacyThemeSw.onClick=function(v)
  isShowTlist(v.isChecked())
end

plist.ChoiceMode=ListView.CHOICE_MODE_MULTIPLE
pss={}
ps={}
for k,v in pairs(permission_info) do
  table.insert(ps,k)
end
table.sort(ps)

for k,v in ipairs(ps) do
  table.insert(pss,permission_info[v])
end

adp=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,String(pss))
plist.Adapter=adp

pcs={}
for k,v in ipairs(app.user_permission or {}) do
  pcs[v]=true
end
for k,v in ipairs(ps) do
  if pcs[v] then
    plist.setItemChecked(k-1,true)
  end
end

local fs=luajava.astable(android.R.style.getFields())
local tss={"Theme"}
for k,v in ipairs(fs) do
  local nm=v.Name
  if nm:find("^Theme_") then
    table.insert(tss,nm)
  end
end

local otss={
  "Theme.Material3.Light",
  "Theme.Material3.Light.NoActionBar",
  "Theme.Material3.Dark",
  "Theme.Material3.Dark.NoActionBar",
  "Theme.Material3.DayNight",
  "Theme.MaterialComponents.Light",
  "Theme.MaterialComponents.Light.NoActionBar",
  "Theme.MaterialComponents.Dark",
  "Theme.MaterialComponents.Dark.NoActionBar",
  "Theme.MaterialComponents.DayNight"}

local tadp=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(tss))
tlist.Adapter=tadp

local otadp=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(otss))
otlist.Adapter=otadp

for k,v in ipairs(tss) do
  if v==app.theme then
    tlist.setSelection(k-1)
  end
end

for k,v in ipairs(otss) do
  if v==app.reOpenLuaTheme then
    otlist.setSelection(k-1)
  end
end

function callback(c,j)
  print(dump(j))
end

local template=[[
appname="%s"
appver="%s"
appcode="%s"
packagename="%s"
welcome_time="%s"
debugmode=%s
reOpenLuaTheme="%s"
theme="%s"--Deprecated in reOpenLua+
enableLegacyTheme=%s
enableExtendedOutputSupport=%s
enableDialogLog=%s
user_permission={
  %s
}
]]
local function dump(t)
  for k,v in ipairs(t) do
    t[k]=string.format("%q",v)
  end
  return table.concat(t,",\n  ")
end

function onCreateOptionsMenu(menu)
  menu.add("保存").setShowAsAction(1)
end

function onOptionsItemSelected(item)
  if appname.Text=="" or appver.Text=="" or packagename.Text=="" then
    Toast.makeText(activity,"项目不能为空",500).show()
    return true
  end

  local cs=plist.getCheckedItemPositions()
  local rs={}
  for n=1,#ps do
    if cs.get(n-1) then
      table.insert(rs,ps[n])
    end
  end
  local thm=tss[tlist.getSelectedItemPosition()+1]
  local othm=otss[otlist.getSelectedItemPosition()+1]
  local ss=string.format(template,appname.Text,appver.Text,appcode.Text,packagename.Text,apptime.Text,debugmode.isChecked(),othm,thm,legacyThemeSw.isChecked(),extendedOutputBtn.isChecked(),dialogLogBtn.isChecked(),dump(rs))
  local f=io.open(luaproject,"w")
  f:write(ss)
  f:close()
  Toast.makeText(activity, "已保存.", Toast.LENGTH_SHORT ).show()
  activity.result({appname.Text})
end

lastclick=os.time()-2
function onKeyDown(e)
  local now=os.time()
  if e==4 then
    if now-lastclick>2 then
      Toast.makeText(activity,"再按一次返回", Toast.LENGTH_SHORT ).show()
      lastclick=now
      return true
    end
  end
end
