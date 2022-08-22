require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.text.InputType"
import "android.graphics.drawable.ColorDrawable"
--import "com.google.android.material.textfield.TextInputLayout"
import "com.google.android.material.textfield.TextInputEditText"
import "androidx.appcompat.app.AlertDialog"

require "permission"

projectdir,theme = ...
import ("themes."..theme)
activity.setTitle('工程属性')
activity.setTheme(android.R.style.Theme_Material)

activity.getSupportActionBar().setElevation(0)
activity.getSupportActionBar().setBackgroundDrawable(ColorDrawable(状态栏背景色))
activity.getSupportActionBar().setDisplayShowHomeEnabled(false)
activity.getWindow().setStatusBarColor(状态栏背景色)
activity.getWindow().setNavigationBarColor(状态栏背景色)

import "alys.pro"
activity.setContentView(loadlayout(pro))

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

plist.ChoiceMode=ListView.CHOICE_MODE_MULTIPLE;
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

local tadp=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(tss))
tlist.Adapter=tadp

for k,v in ipairs(tss) do
  if v==app.theme then
    tlist.setSelection(k-1)
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
theme="%s"
welcome_time="%s"
debugmode=%s
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
  local ss=string.format(template,appname.Text,appver.Text,appcode.Text,packagename.Text,thm,apptime.Text,debugmode.isChecked(),extendedOutputBtn.isChecked(),dialogLogBtn.isChecked(),dump(rs))
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

