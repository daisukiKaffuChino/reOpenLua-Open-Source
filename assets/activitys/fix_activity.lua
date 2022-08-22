require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "com.myopicmobile.textwarrior.common.*"
import "android.content.*"
import "android.graphics.drawable.ColorDrawable"


dir,path,theme=...
import ("themes."..theme)
activity.Title="导入分析"
activity.setTheme(android.R.style.Theme_Material)
activity.getWindow().setStatusBarColor(状态栏背景色)
activity.getWindow().setNavigationBarColor(状态栏背景色)
activity.getSupportActionBar().setElevation(0)
activity.getSupportActionBar().setBackgroundDrawable(ColorDrawable(状态栏背景色))
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)


import "alys.fix"
classes=require "activitys.android"
activity.setTitle('需要导入的类')


activity.setContentView(loadlayout(fix))


function fiximport(path)
  require "import"
  import "android.app.*"
  import "android.os.*"
  import "android.widget.*"
  import "android.view.*"
  --import "com.myopicmobile.textwarrior.common.*"
  
  classes=require "activitys.android"
  local searchpath=path:gsub("[^/]+%.lua","?.lua;")..path:gsub("[^/]+%.lua","?.aly;")
  local cache={}
  function checkclass(path,ret)
    if cache[path] then
      return
    end
    cache[path]=true
    local f=io.open(path)
    local str=f:read("a")
    f:close()
    if not str then
      return
      end
    for s,e,t in str:gfind("(import \"[%w%.]+%*\")") do
      --local p=package.searchpath(t,searchpath)
      --print(t,p)
    end
    for s,e,t in str:gfind("import \"([%w%.]+)\"") do
      local p=package.searchpath(t,searchpath)
      if p then
        checkclass(p,ret)
      end
    end
    local lex=LuaLexer(str)
    local buf={}
    local last=nil
    while true do
      local t=lex.advance()
      if not t then
        break
      end
      if last~=LuaTokenTypes.DOT and t==LuaTokenTypes.NAME then
        local text=lex.yytext()
        buf[text]=true
      end
      last=t
    end
    table.sort(buf)

    for k,v in pairs(buf) do
      k="[%.$]"..k.."$"
      for a,b in ipairs(classes) do
        if string.find(b,k) then
          if cache[b]==nil then
            table.insert(ret,b)
            cache[b]=true
          end
        end
      end
    end
  end
  local ret={}
  checkclass(path,ret)

  return String(ret)
end
--path="/storage/emulated/0/AndroLua/draw2.lua"
--path=luajava.luapath

--path=luajava.luapath
list=ListView(activity)
list.backgroundColor=状态栏背景色
list.ChoiceMode=ListView.CHOICE_MODE_MULTIPLE;
task(fiximport,path,function(v)
    rs=v
  adp=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,v)
  list.Adapter=adp
  activity.setContentView(list)
end)
--Toast.makeText(activity,"正在分析。。。",1000).show()
function onCreateOptionsMenu(menu)
  menu.add("全选").setShowAsAction(1)
  menu.add("复制").setShowAsAction(1)
end

cm=activity.getSystemService(Context.CLIPBOARD_SERVICE)

function onOptionsItemSelected(item)
  if item.Title=="复制" then
    local buf={}

    local cs=list.getCheckedItemPositions()
    local buf={}
    for n=0,#rs-1 do
      if cs.get(n) then
        table.insert(buf,string.format("import \"%s\"",rs[n]))
      end
    end

    local str=table.concat(buf,"\n")
    local cd = ClipData.newPlainText("label", str)
    cm.setPrimaryClip(cd)
    Toast.makeText(activity,"已复制到剪切板",1000).show()
  elseif item.Title=="全选" then
    for n=0,#rs-1 do
      list.setItemChecked(n,not list.isItemChecked(n))
    end
    else
    activity.finish()
  end
end
