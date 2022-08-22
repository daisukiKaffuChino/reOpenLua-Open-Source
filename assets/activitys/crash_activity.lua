require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
import "java.io.File"
import "android.os.Environment"
import "android.util.TypedValue"
import "android.content.ClipData"
import "android.graphics.drawable.ColorDrawable"
import "android.animation.LayoutTransition"

import "androidx.recyclerview.widget.RecyclerView"
import "androidx.recyclerview.widget.LinearLayoutManager"
import "androidx.appcompat.app.AlertDialog"

import "com.google.android.material.button.MaterialButton"

import "github.daisukiKaffuChino.LuaFileTabView"
import "github.daisukiKaffuChino.ExtendedEditText"
import "github.daisukiKaffuChino.CustomViewPager"
import "github.daisukiKaffuChino.AdapterCreator"
import "github.daisukiKaffuChino.LuaCustRecyclerAdapter"
import "github.daisukiKaffuChino.LuaCustRecyclerHolder"

import "rawio"

theme = ...
import ("themes."..theme)
activity.Title="Crash Log Viewer"
activity.setTheme(import ("themes."..theme))
activity.getWindow().setStatusBarColor(状态栏背景色)
activity.getWindow().setNavigationBarColor(状态栏背景色)
activity.getSupportActionBar().setElevation(0)
activity.getSupportActionBar().setBackgroundDrawable(ColorDrawable(状态栏背景色))
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)

--绝大部分代码都是以前TuMengR的遗产，我的评价是稍微看看就行了
--致谢 LuaFileTabView作者 dingyi

rippleRes = TypedValue()
activity.getTheme().resolveAttribute(android.R.attr.selectableItemBackground, rippleRes, true)

local cm=activity.getSystemService(activity.CLIPBOARD_SERVICE)

layout={
  LinearLayout,
  layout_width="-1",
  layout_height="-1",
  background=ColorDrawable(背景色),
  {
    CustomViewPager,
    layout_width="-1",
    layout_height="-1",
    id="vpg",
    pages={
      --------------
      {
        LinearLayout,
        layout_width="-1",
        layout_height="-1",
        orientation="vertical",
        layoutTransition=LayoutTransition().enableTransitionType(LayoutTransition.CHANGING),
        {
          LuaFileTabView,
          id="filetag",
          layout_width="fill",
          layout_height="52dp",
          tabMode=LuaFileTabView.MODE_SCROLLABLE,
          selectedTabIndicatorHeight=0,
          inlineLabel=true,
          clipToPadding=false,
          paddingLeft="16dp",
          paddingRight="16dp",
        },
        {
          RecyclerView,
          id="recyview",
          layout_width="fill",
          layout_height="fill";
        },
      },
      --------------
      {
        LinearLayout,
        layout_width="-1",
        layout_height="-1",
        orientation="vertical",
        {
          LinearLayout,
          layout_width="-1",
          layout_height="-2",
          paddingStart="16dp",
          paddingEnd="16dp",
          paddingTop="4dp",
          paddingBottom="4dp",
          gravity="center",
          {
            MaterialButton,
            onClick=function()
              vpg.setCurrentItem(0)
              activity.getSupportActionBar().setSubtitle(nil)
            end,
            text="返回",
          },
          {
            Space,
            layout_weight="1",
          },
          {
            TextView,
            text="全部复制",
            textSize="16dp",
            textColor=状态栏背景色,
            clickable="true",
            backgroundResource=rippleRes.resourceId,
            onClick=function()
              local cd = ClipData.newPlainText("log",edit.getText().toString())
              cm.setPrimaryClip(cd)
              print("ok")
            end,
          },
        },
        {
          ExtendedEditText,
          id="edit",
          textSize="12sp",
          backgroundColor=0,
          layout_width="-1",
          layout_height="-1",
        },
      },
    },
    --------------
  },
}

activity.setContentView(loadlayout(layout))

local listdata={}
basepath=tostring(activity.getExternalFilesDir(nil)).."/crash/"
local currentPath=nil

local function ends(s,End)
  return End=="" or string.sub(s,-string.len(End))== End
end

adp=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return #listdata
  end,
  getItemViewType=function(pos)
    return listdata[pos+1].type
  end,
  onCreateViewHolder=function(parent,viewType)
  local views={}
  switch viewType do
     case 0
      holder1=LuaCustRecyclerHolder(loadlayout("alys/filechooser_item_dir",views))
      holder1.view.setTag(views)
      return holder1
     case 1
      holder2=LuaCustRecyclerHolder(loadlayout("alys/filechooser_item_file",views))
      holder2.view.setTag(views)
      return holder2
    end
  end,
  onBindViewHolder=function(holder,pos)
    local view=holder.view.getTag()
    view.title.setText(listdata[pos+1].title)
    view.img.setImageBitmap(loadbitmap(listdata[pos+1].img))
    view.content.BackgroundResource=rippleRes.resourceId
    view.content.onClick=function()
      local function getPath() return listdata[pos+1].path.toString()end
      if pcall(getPath) then
        local crtpath=listdata[pos+1].path.toString()
        if (listdata[pos+1].type == 1)
          if ends(crtpath,".log") then
            activity.getSupportActionBar().setSubtitle(crtpath)
            local t=rawio.ioread(crtpath)
            edit.setText(t)
            vpg.setCurrentItem(1)
           else
            print("只能选择.log文件")
          end
         else
          if not pcall(function()updateRecy(crtpath)end) then
            print("打开失败")
          end
        end
       else
        print("不能再往上了")
      end
    end
    if holder.getItemViewType()==1 then
      view.subtitle.text=listdata[pos+1].sub
    end
  end,
}))
recyview.setAdapter(adp)
recyview.setLayoutManager(LinearLayoutManager(this))

function updateRecy(p)
  recyview.removeAllViews()
  listdata={}
  init(p)
  --task(30,function()init(p)end)
  --adp.notifyDataSetChanged()
end

function getFileInfo(file)
  --size=FileSizeUtil.format(tointeger(file.length()))
  size=LuaUtil.formatFileSize(tointeger(file.length()))
  lastModified=os.date("%y/%m/%d %H:%M:%S",file.lastModified()/1000)
  return size.."\t|\t"..lastModified
end

function listFile(strpath)
  pcall(function()fileList=luajava.astable(File(strpath).listFiles())end)
  if (!fileList) then
    fileList={}
  end
  table.sort(fileList,function(a,b)
    return string.upper(a.getName())<string.upper(b.getName())
  end)
  return fileList
end

function init(_p)
  currentPath=_p
  local fileList=listFile(_p)
  local dir={}
  local files={}
  for key,value in ipairs(fileList) do
    if value.isDirectory() then
      local name=value.getName()
      table.insert(dir,{n=name,p=value})
     elseif value.isFile() then
      local name=value.getName()
      table.insert(files,{n=name,p=value})
    end
  end
  for k,v in ipairs(dir) do
    table.insert(listdata,{title=v.n,path=v.p,img="imgs/folder",type=0})
  end
  for k,v in ipairs(files) do
    table.insert(listdata,{title=v.n,path=v.p,sub=getFileInfo(v.p),img="imgs/file",type=1})
  end
  local _dirn=#luajava.astable(String(_p).split("/"))
  --print(_dirn)
  if _dirn > 7 then
    table.insert(listdata,1,{title=".../",path=File(_p).getParentFile(),img="imgs/file_up",type=0})
    filetag.visibility=0
   elseif _dirn <= 7 then
    table.insert(listdata,1,{title="/私有根目录",path=activity.getExternalFilesDir(nil).toString(),img="imgs/folder_priv",type=0})
    filetag.visibility=8
   else
    filetag.visibility=8
  end
  filetag.setPath(_p)
  adp.notifyDataSetChanged()
end

task(20,function()init(basepath)end)

function onCreateOptionsMenu(menu)
  menu.add("说明")
end

function onOptionsItemSelected(m)
switch m.getItemId() do
   case android.R.id.home
    activity.finish()
   case
    AlertDialog.Builder(this)
    .setTitle("Crash Log Viewer")
    .setMessage("       不同于Lua的Logcat，本工具用于查阅未被捕获的造成程序崩溃的Java异常。这些文件通常都详细记录了设备信息和异常堆栈信息，可帮助开发者快速发现问题。"
    .."\n       出于如今的安卓应用行为规范考虑，reOpenLua+不会将日志写入公共存储。而由于安卓高版本的限制，访问data已不再容易，本工具提供了访问保存在data下的日志的途径。稍加改造也可以作为私有目录文件阅览器使用。")
    .setPositiveButton("知道了",nil)
    .show()
  end
end

--local _l=0
--local __l=#luajava.astable(String(basepath).split("/"))-7
filetag.addOnTabSelectedListener(LuaFileTabView.OnTabSelectedListener{
  onTabSelected=function(tab)
    --此回调方法会被异常调用，以后再修吧   
    -- _l=_l+1--阻止加载多次
    -- if _l>__l then
    task(100,function()
      updateRecy(filetag.getPath())
    end)
    --end
  end
})

function onKeyDown(code,event)
  if string.find(tostring(event),"KEYCODE_BACK") ~= nil then
    if vpg.getCurrentItem()==1 then
      vpg.setCurrentItem(0)
      return true
    end
  end
end