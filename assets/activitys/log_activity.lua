require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
import "android.graphics.Typeface"
import "android.text.Spannable"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "android.text.style.BackgroundColorSpan"
import "android.text.style.TypefaceSpan"
import "android.content.pm.PackageManager"

--开源致谢:杰西的日志猫高亮实现

theme = ...
import ("themes."..theme)
activity.setTitle("LogCat Pro")
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)
activity.getWindow().setNavigationBarColor(0)

local type2color={
  V=0xFF000000,
  D=0xff2196f3,
  I=0xff4caf50,
  W=0xffff9800,
  E=0xfff44336
}

local edit=EditText(activity)

edit.Hint="搜索标题或内容"
edit.Width=activity.Width/2.8
edit.SingleLine=true
edit.textColor=0xffffffff
edit.hintTextColor=0x80ffffff
edit.backgroundColor=0x00000000
edit.addTextChangedListener{
  onTextChanged=function(c)
    adapter.filter(tostring(c))
  end
}

--添加菜单
local items={"All","Lua","Test","Tcc","Error","Warning","Info","Debug","Verbose","Clear"}
function onCreateOptionsMenu(menu)
  local me=menu.add("搜索").setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
  me.setActionView(edit)
  for k,v in ipairs(items) do
    m=menu.add(v)
    items[v]=m
  end
end

function onOptionsItemSelected(item)
  if func[item.getTitle()] then
    func[item.getTitle()]()
   else
    activity.finish()
  end
end

function readlog(s)
  local p=io.popen("logcat -d -v long "..s)
  local s=p:read("*a")
  p:close()  
  return s
end

function clearlog()
  local p=io.popen("logcat -c")
  local s=p:read("*a")
  p:close()
  return s
end

func={}
func.All=function()
  activity.getSupportActionBar().setSubtitle("All")
  task(readlog,"",show)
end
func.Lua=function()
  activity.getSupportActionBar().setSubtitle("Lua")
  task(readlog,"lua:* *:S",show)
end
func.Test=function()
  activity.getSupportActionBar().setSubtitle("Test")
  task(readlog,"test:* *:S",show)
end
func.Tcc=function()
  activity.getSupportActionBar().setSubtitle("Tcc")
  task(readlog,"tcc:* *:S",show)
end
func.Error=function()
  activity.getSupportActionBar().setSubtitle("Error")
  task(readlog,"*:E",show)
end
func.Warning=function()
  activity.getSupportActionBar().setSubtitle("Warning")
  task(readlog,"*:W",show)
end
func.Info=function()
  activity.getSupportActionBar().setSubtitle("Info")
  task(readlog,"*:I",show)
end
func.Debug=function()
  activity.getSupportActionBar().setSubtitle("Debug")
  task(readlog,"*:D",show)
end
func.Verbose=function()
  activity.getSupportActionBar().setSubtitle("Verbose")
  task(readlog,"*:V",show)
end
func.Clear=function()
  task(clearlog,show)
end

scroll=ListView(activity)
scroll.FastScrollEnabled=true
--scroll.setBackgroundDrawable(ColorDrawable(编辑器背景色))

function show(s)
  adapter.clear()  
  if s and #s~=0 then
    local nowTitle=""
    local nowTag=""
    local nowContent=""
    for line in s:gmatch("(.-)\n") do
      if line:find("^%-%-%-%-%-%-%-%-%- beginning of ") then
        local appVerCode=activity.getPackageManager().getPackageInfo("github.daisukiKaffuChino.reopenlua",PackageManager.GET_ACTIVITIES).versionCode
        adapter.add({title=line,content="reOpenLua+ LogCatPro Ver."..appVerCode})
       elseif line:find("^%[ *%d+%-%d+ *%d+:%d+:%d+%.%d+ *%d+: *%d+ *%a/[^ ]+ *%]$") then
        local date,time,processId,threadId,logType,logTag=line:match("^%[ *(%d+%-%d+) *(%d+:%d+:%d+%.%d+) *(%d+): *(%d+) *(%a)/([^ ]+) *%]$")
        --print(date,time,processId,threadId,logType,logTag)
        local title
        if logTag~="LuaInvocationHandler" then
          title="[ "..date.." "..time.." "..processId..":"..threadId.."  "
          local typeIndex=utf8.len(title)
          title=title..logType.." /"..logTag.." ]"
          title=SpannableString(title)
          title.setSpan(BackgroundColorSpan(type2color[logType]),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          title.setSpan(ForegroundColorSpan(0xFFFFFFFF),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          title.setSpan(TypefaceSpan("monospace"),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
        end
        if nowContent~="" and nowTag~="LuaInvocationHandler" then
          adapter.add({title=nowTitle,content=String(nowContent).trim()})
        end
        nowTitle=title--line
        nowTag=logTag
        nowContent=""
       else
        nowContent=nowContent.."\n"..line
      end
    end
   else
    adapter.add({title="<此项日志为空，请运行以查看其输出>"})
  end
end

item={
    LinearLayout,
    layout_width="fill",
    orientation="vertical",
    padding="8dp",
    {
      TextView,
      textIsSelectable=true,
      textSize="14sp",
      id="title",
      textColor=textColor,
      textStyle="bold",
    },
    {
      TextView,
      textIsSelectable=true,
      textSize="14sp",
      id="content",
      textColor=subTextColor,
    },
  }


adapter=LuaAdapter(activity,item)
scroll.setAdapter(adapter)
adapter.setFilter(function(t,b,c)
  for i,v in ipairs(t)do
    if tostring(v.title):find(tostring(c),0,true) or tostring(v.content):find(tostring(c),0,true) then
      b[#b+1]=v
    end
  end
end)

activity.setContentView(scroll)
func.Lua()