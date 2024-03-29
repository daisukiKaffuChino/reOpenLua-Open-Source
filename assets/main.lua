require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "java.io.*"

import "android.net.Uri"
import "android.content.Intent"
import "android.content.pm.PackageManager"
import "android.content.ComponentName"
import "android.animation.LayoutTransition"
import "android.graphics.drawable.ColorDrawable"
import "android.graphics.drawable.GradientDrawable"
import "android.graphics.drawable.GradientDrawable$Orientation"
import "android.view.inputmethod.EditorInfo"
import "android.text.TextUtils"
import "android.util.TypedValue"
import "android.Manifest"

import "androidx.appcompat.app.AlertDialog"
import "androidx.appcompat.widget.SwitchCompat"
import "androidx.core.app.ActivityCompat"
import "androidx.core.content.ContextCompat"

import "com.google.android.material.bottomsheet.BottomSheetDialog"
import "com.google.android.material.bottomsheet.BottomSheetBehavior"
import "com.google.android.material.textfield.TextInputEditText"
import "com.google.android.material.textfield.TextInputLayout"
import "com.google.android.material.tabs.TabLayout"
import "com.google.android.material.dialog.MaterialAlertDialogBuilder"
import "com.google.android.material.button.MaterialButton"

import "bin"
import "console"

import "rawio"

--2023 12 07

--[[ALL RIGHTS RESERVED
AndroLua+ 5.0.19/OpenLua+ 0.6.8/reOpenLua+ 0.7.8
酷安@得想办法娶了智乃 Github@daisukiKaffuChino]]

--[[reOpenLua+支持并鼓励基于本编辑器的二次开发，或帮助本
编辑器继续完善功能。同时也欢迎使用此开源代码，并保留出处。]]


----------------------初始化参数-----------------------------------
pcall(dofile,activity.getLuaDir().."/config/default.lua")

pcall(dofile,activity.getLuaDir().."/config/lua_project.lua")

pcall(dofile,activity.getLuaDir().."/config/lua_theme.lua")

pcall(dofile,activity.getLuaDir().."/config/last_history.lua")

pcall(dofile,activity.getLuaDir().."/config/editor_config.lua")

pcall(dofile,activity.getLuaDir().."/config/run_host.lua")


--主题
last_theme = last_theme or "AppLightTheme"

--最后打开的文件的路径
last_file_path = last_file_path or app_root_lua

--最后打开的文件的光标位置
last_file_cursor = last_file_cursor or 0

--最后打开文件的目录
last_dir_path = last_file_path:match("^(.-)[^/]+$")

--最后打开的工程目录
last_pro_path = last_pro_path

--历史记录表
last_history = last_history or {}

--是否在编辑工程/文件
isEdittingProject = false

isEdittingFile = false

--宿主
runningBySelf = runningBySelf

hostPackage = hostPackage

hostActivity = hostActivity

-----------------------------------------------------------------


--设置主题

APP_THEME = import("themes."..last_theme)

activity.getWindow().setStatusBarColor(colorPrimaryBackground)

activity.getWindow().setNavigationBarColor(colorPrimaryBackground)

activity.getSupportActionBar().hide()

--ripple
circleRippleRes = TypedValue()
activity.getTheme().resolveAttribute(android.R.attr.selectableItemBackgroundBorderless, circleRippleRes, true)

rippleRes = TypedValue()
activity.getTheme().resolveAttribute(android.R.attr.selectableItemBackground, rippleRes, true)

MDC_R=luajava.bindClass"com.google.android.material.R"

--显示界面布局

import "alys.main_layout"

import "alys.list_item"

activity.setContentView(loadlayout(main_layout))



--配置编辑器主题

mLuaEditor.setBasewordColor(BasewordColor)

mLuaEditor.setKeywordColor(KeywordColor)

mLuaEditor.setCommentColor(CommentColor)

mLuaEditor.setUserwordColor(UserwordColor)

mLuaEditor.setStringColor(StringColor)

mLuaEditor.setBackground(ColorDrawable(colorBackground))

mLuaEditor.enableNonPointing(nonPoint)

mLuaEditor.enableDrawingErrMsg(errMsg)

--初始化文件选择器

mLuaAdapter = LuaAdapter(activity,list_item)

mList.setAdapter(mLuaAdapter)

--初始化文件标签栏

if not showFileLabel then

  _mFileTab.Visibility = View.GONE

end

--文件切换标签

local FileLabelUtil={} --create in 0.7.8

FileLabelUtil.bin=function(self)

  self.view=mFileTab

  self.view.adapter=LuaAdapter(activity,import "alys/file_label_list")

  --self:addLabel("/storage/emulated/0/AndroLua/project/openluadev/main.lua","main.lua")

end


FileLabelUtil.chooseLabel=function(self,l)

  for k,v in ipairs(self.view.adapter.data) do

    v.__title.backgroundColor=0

    v.title.textColor=subTextColor

  end

  self.view.adapter.data[l].__title.backgroundColor=colorPrimary

  self.view.adapter.data[l].title.textColor=textColor

  self.view.adapter.notifyDataSetChanged()

  self.view.setVerticalScrollbarPosition(l)

  mSubTitle.setText(self.view.adapter.data[l].__title.text)

end

FileLabelUtil.addLabel=function(self,path,name)

  if File(path).exists() then

    for k,v in ipairs(self.view.adapter.data) do

      if tostring(v.__title.text)==path then

        return FileLabelUtil:chooseLabel(k)

      end

    end

    self.view.adapter.add{
      title={
        text=name,
        textColor=textColor,
      },
      __title={
        text=path,
        backgroundColor=colorPrimary,
      }
    }

    FileLabelUtil:chooseLabel(#self.view.adapter.data)

   else

    print("标签文件不存在")

  end

end

FileLabelUtil:bin()


--写入文件内容并保存

function write(path, str)

  if path == app_root_lua then

    return

  end

  local ok = rawio.iowrite(path,str,"wb")

  if not ok then

    Toast.makeText(activity, "保存失败." .. path, Toast.LENGTH_SHORT ).show()

  end

  return str

end

--读取文件内容显示到编辑器

function read(path)

  local str = nil

  local function _read()

    str = rawio.iotsread(path, "r")

  end

  if pcall(_read) then

    isEdittingProject = true

    isEdittingFile = true

    mLuaEditor.setText(str)

    FileLabelUtil:addLabel(path,path:match(".*/(.*)"))

    last_file_path = path

    if last_history[last_file_path] then

      mLuaEditor.setSelection(last_history[last_file_path])

    end

    --记录历史记录,最大记录为50条

    table.insert(last_history, 1, last_file_path)

    for n = 2, #last_history do

      if n > 50 then

        last_history[n] = nil

       elseif last_history[n] == last_file_path then

        table.remove(last_history, n)

      end

    end

   else

    error()

    return

  end

  --记录当前打开的文件为最后打开的文件到文件

  write(activity.getLuaDir().."/config/lua_project.lua", string.format("last_file_path=%q", path))

end


--保存文件和记录的信息

function save()

  if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED and

    ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) then

    last_history[last_file_path] = mLuaEditor.getSelectionEnd()

    write(activity.getLuaDir().."/config/lua_history.lua", string.format("last_history=%q", dump(last_history)))

    local str = nil

    str = rawio.iotsread(last_file_path, "r")

    if str==nil and isEdittingProject then print("读取最近编辑的文件内容失败") end

    local src = mLuaEditor.getText().toString()

    if src ~= str then

      if TextUtils.isEmpty(src) and isEdittingProject==true then

        MaterialAlertDialogBuilder(this)

        .setTitle("写入保护")

        .setMessage("编辑器正尝试将当前已打开的文件置空。如果这是编辑器的错误而不是您主动删除了所有文本，请拒绝或尝试重新载入。")

        .setPositiveButton("重新载入",function()

          xpcall(function()read(last_file_path)end,function(err)print("载入失败:"..err)end)

        end)

        .setNegativeButton("拒绝",nil)

        .setNeutralButton("允许",function()write(last_file_path, src)end)

        .show()

       else

        write(last_file_path, src)

      end

    end

  end

end


mFileTab.setOnItemClickListener(AdapterView.OnItemClickListener{

  onItemClick=function(parent,view,pos,i)

    local name=parent.adapter.data[i].title.text

    local path=parent.adapter.data[i].__title.text

    if path==last_file_path then

      mLuaEditor.setSelection(0)

     else

      save()

      FileLabelUtil:addLabel(path,name)

      read(path)

    end

  end

})

mFileTab.setOnItemLongClickListener(AdapterView.OnItemLongClickListener{

  onItemLongClick=function(parent,view,pos,i)

    local name=parent.adapter.data[i].title.text

    local path=parent.adapter.data[i].__title.text

    local tabpop = PopupMenu(activity,view)

    tabpop.Menu.add("文件详情").onMenuItemClick=function()

      local file=File(path)

      local size=LuaUtil.formatFileSize(tointeger(file.length()))

      local cal = Calendar.getInstance()

      cal.setTimeInMillis(file.lastModified())

      local edittime=cal.getTime().toLocaleString()

      MaterialAlertDialogBuilder(this)

      .setTitle("文件详情")

      .setMessage("路径:\n"..path.."\n大小:"..size.."\n修改日期:\n"..edittime)

      .setPositiveButton("确认",nil)

      .show()

    end

    tabpop.Menu.add("关闭其它").onMenuItemClick=function()

      if #parent.adapter.data==1 then

        print("已经是最后一个标签了")

       else

        table.clear(parent.adapter.data)

        parent.adapter.notifyDataSetChanged()

        FileLabelUtil:addLabel(path,name)

        read(path)

      end

    end

    tabpop.Menu.add("关闭").onMenuItemClick=function()

      if #parent.adapter.data==1 then

        print("已经是最后一个标签了")

       else

        save()

        parent.adapter.remove(pos)

        parent.adapter.notifyDataSetChanged()

        for k,v in ipairs(parent.adapter.data) do

          if v.title.textColor==textColor then

            _pos=k-1

          end

        end

        if _pos==nil then

          FileLabelUtil:chooseLabel(#parent.adapter.data)

          read(parent.adapter.data[#parent.adapter.data].__title.text)

          return

        end

        if _pos>pos then

          FileLabelUtil:chooseLabel(_pos+1)

          read(parent.adapter.data[_pos+1].__title.text)

         elseif _pos==pos then

          FileLabelUtil:chooseLabel(#parent.adapter.data)

          read(parent.adapter.data[#parent.adapter.data].__title.text)

        end

      end

    end

    tabpop.show()

  end

})


--软件更新回调

function onVersionChanged(n,o)

  local dlg = MaterialAlertDialogBuilder(activity)

  local title = "更新" .. o .. ">" .. n

  local msg = rawio.iotsread(activity.getLuaDir().."/res/docs/update_log.txt","r")

  if o == "" then

    title = "欢迎使用reOpenLua+ " .. n

    msg = [[       基于AndroLua+ 5.0.19修改，且合并了原OpenLua+ 0.6.8版本之前的绝大部分改动。此项目已迁移到AndroidX和AppCompat，支持新的标准库。
       用户使用协议：请勿编写恶意软件损害他人，本软件作者不对使用本软件造成的任何直接或间接损失负责。继续使用表示您同意上述协议。
       
]].. msg

  end

  dlg.setTitle(title)

  dlg.setMessage(msg)

  dlg.setPositiveButton("确定", nil)

  dlg.setNeutralButton("反馈问题", function()

    if pcall(function() activity.getPackageManager().getPackageInfo("com.tencent.mobileqq",0) end) then

      print("添加好友请注明来意")

      local url="mqqapi://card/show_pslcard?src_type=internal&source=sharecard&version=1&uin=483004683"

      activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))

     else

      print("请先安装QQ")

    end

  end)

  dlg.show()

end


function showPmPanel(t)

if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED and
  ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) then

  mMain.setVisibility(0)

  mPm.setVisibility(8)

 else

  mMain.setVisibility(8)

  mPm.setVisibility(0)

  when t print("授权失败")

  end

end

--权限申请回调

function onRequestPermissionsResult(reqCode,permissions,grantResults)

  if reqCode == 114514 then

    showPmPanel(true)

  end

end

showPmPanel()


--侧滑栏按钮点击事件

mMenu.onClick=function()

  mDraw.openDrawer(3)

end



--运行按钮点击事件

mPlay.onClick=function()

  if not isEdittingProject then

    print("没有打开工程")

   else

    save()

    local main = app_root_pro_dir.."/"..mTitle.Text.."/".."main.lua"

    if runningBySelf then

      activity.newProject(main)

     else

      local success,err=pcall(function()

        local intent=Intent(Intent.ACTION_VIEW,Uri.parse(main))

        local componentName=ComponentName(hostPackage,hostActivity)

        intent.setComponent(componentName)

        activity.startActivity(intent)

      end)

      if not(success) then

        print("打开失败")

      end

    end

  end

end



mUndo.onClick=function()

  mLuaEditor.undo()

end



mRedo.onClick=function()

  mLuaEditor.redo()

end



mMore.onClick=function()

  local pop =PopupMenu(activity,mMores)

  local menu=pop.Menu

  menu1 = menu.addSubMenu("文件")

  menu2 = menu.addSubMenu("工程")

  menu3 = menu.addSubMenu("代码")

  menu4 = menu.addSubMenu("设置")

  menu5 = menu.addSubMenu("查看")

  menu1.add("保存").onMenuItemClick=function(a)

    if not isEdittingFile then

      print("未打开文件,不能保存")

      return

    end

    save()

    print("文件已保存")

  end

  menu1.add("编译").onMenuItemClick=function(a)

    if not isEdittingFile then

      print("未打开文件,不能编译")

      return

    end

    save()

    local path,str = console.build(mSubTitle.Text)

    if path then

      print("编译完成 : " .. path)

     else

      print("编译出错 : " .. str)

    end

  end

  menu2.add("打包").onMenuItemClick=function(a)

    if not isEdittingProject then

      print("未打开工程,不能打包")

      return

    end

    save()

    local prodir=app_root_pro_dir .."/".. mTitle.Text .. "/"

    local app={}

    loadfile(prodir.."init.lua","bt",app)()

    if app.reOpenLuaTheme==nil then

      MaterialAlertDialogBuilder(this)

      .setTitle("打包出错")

      .setMessage("未配置reOpenLuaTheme，将仅应用默认主题。确定要继续吗？")

      .setPositiveButton("打开工程属性",function()

        activity.newActivity("activitys/pro_activity", { prodir , last_theme })

      end)

      .setNegativeButton("继续打包",function()bin(prodir)end)

      .show()

     else

      bin(prodir)

    end

  end

  menu2.add("导出").onMenuItemClick=function(a)

    if not isEdittingProject then

      print("未打开工程,不能导出")

      return

    end

    save()

    p = export(app_root_pro_dir .."/".. mTitle.Text)

    print("工程已导出")

  end


  menu2.add("关闭工程").onMenuItemClick=function(a)

    if not isEdittingProject then

      print("未打开工程")

      return

    end

    save()

    write(activity.getLuaDir().."/config/lua_project.lua",[[last_file_path=nil
last_file_cursor=nil
last_dir_path=nil
last_pro_path=nil]])

    write(activity.getLuaDir().."/config/lua_history.lua","last_history=nil")

    activity.newActivity("main")

    activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out)

    activity.finish()

  end

  --menu2.add("示例工程").onMenuItemClick=function(a)

  --activity.newActivity("activitys/example_activity",{ last_theme })

  --end

  menu2.add("属性").onMenuItemClick=function(a)

    if not isEdittingProject then

      print("未打开工程,不能设置属性")

      return

    end

    save()

    activity.newActivity("activitys/pro_activity", { app_root_pro_dir .."/".. mTitle.Text , last_theme })

  end

  menu3.add("代码对齐").onMenuItemClick=function(a)

    mLuaEditor.format()

  end

  menu3.add("导入分析").onMenuItemClick=function(a)

    if not isEdittingProject then

      print("未打开文件,不能导入分析")

      return

    end

    save()

    local luaproject = app_root_pro_dir.."/"..mTitle.Text

    local luapath = mSubTitle.Text

    activity.newActivity("activitys/fix_activity", { luaproject, luapath , last_theme })

  end

  menu3.add("代码搜索").onMenuItemClick=function(a)

    --mSearch
    mSearch.setVisibility(View.VISIBLE)

  end

  menu3.add("去除注释").onMenuItemClick=function(a)

    --感谢alua官2群群友true

    MaterialAlertDialogBuilder(this)

    .setTitle("去除注释")

    .setMessage("这会去除该文件所有注释，确认要继续吗？此次操作可以被撤销。")

    .setPositiveButton("确认",function()

      if mLuaEditor.clearComment() then

        print("清理成功")

       else

        print("清理失败")

      end

    end)

    .setNegativeButton("取消",nil)

    .show()

  end

  menu3.add("代码查错").onMenuItemClick=function(a)

    local src = mLuaEditor.getText().toString()

    local path = mSubTitle.getText()

    if ends(path,".aly") then

      src = "return " .. src

    end

    local _, data = loadstring(src)

    if data then

      local _, _, line, data = data:find(".(%d+).(.+)")

      mLuaEditor.gotoLine(tonumber(line))

      print(line .. ":" .. data)

      return true

     elseif b then

     else

      print("没有语法错误")

    end

  end

  menu3.add("布局助手").onMenuItemClick=function(a)

    save()

    local luaproject = app_root_pro_dir.."/"..mTitle.Text

    local luapath = mSubTitle.Text

    activity.newActivity("activitys/layouthelper/main", { luaproject, luapath ,last_theme })

  end

  menu4.add("主题切换").onMenuItemClick=function(a)

    MaterialAlertDialogBuilder(activity)

    .setTitle("主题列表")

    .setItems({"浅色主题","深色主题"},function(d,i)

      local function editInitTheme(theme)
        str=rawio.iotsread(activity.getLuaDir().."/init.lua", "r")
        if last_theme=="AppLightTheme" then
          oldtheme="Theme.MaterialComponents.Light"
         else
          oldtheme="Theme.MaterialComponents.Dark"
        end
        rawio.iowrite(activity.getLuaDir().."/init.lua",tostring(str:gsub(oldtheme,theme)),"w+")
      end

      switch i

       case 0

        save()

        write(activity.getLuaDir().."/config/lua_theme.lua", string.format("last_theme=%q","AppLightTheme"))

        editInitTheme("Theme.MaterialComponents.Light")

        activity.newActivity("main")

        activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out)

        activity.finish()

       case 1

        save()

        write(activity.getLuaDir().."/config/lua_theme.lua", string.format("last_theme=%q","AppDarkTheme"))

        editInitTheme("Theme.MaterialComponents.Dark")

        activity.newActivity("main")

        activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out)

        activity.finish()

      end

    end)

    .show()

  end

  menu4.add("编辑器设置").onMenuItemClick=function(a)

    MaterialAlertDialogBuilder(this)

    .setTitle("编辑器设置")

    .setView(loadlayout("alys.editor_setting"))

    .show()

    sw1.setChecked(errMsg)

    sw2.setChecked(nonPoint)

    sw3.setChecked(showFileLabel)

    setbtn1.onClick=function()

      MaterialAlertDialogBuilder(this)

      .setTitle("设置运行环境")

      .setView(loadlayout("alys.editor_setting_env"))

      .setPositiveButton("保存",function()

        runningBySelf=env_sw.isChecked()
        
        hostPackage=env_edt_packagename.Text
        
        hostActivity=env_edt_activity.Text

        write(activity.getLuaDir().."/config/run_host.lua", string.format("runningBySelf=%q", env_sw.isChecked()).."\n"..string.format("hostPackage=%q", env_edt_packagename.Text).."\n"..string.format("hostActivity=%q", env_edt_activity.Text))

      end)

      .setNegativeButton("取消",nil)

      .show()

      env_sw.setChecked(runningBySelf)

      env_edt_packagename.setText(hostPackage)

      env_edt_activity.setText(hostActivity)

      local function toggleEdtVisibility(x)

        if x then

          env_edt_packagename.setVisibility(8)

          env_edt_activity.setVisibility(8)

         else

          env_edt_packagename.setVisibility(0)

          env_edt_activity.setVisibility(0)

        end

      end

      toggleEdtVisibility(runningBySelf)

      env_sw.onClick=function(v)

        toggleEdtVisibility(env_sw.isChecked())

      end

    end

    sw1.onClick=function(v)

      errMsg=v.isChecked()

      write(activity.getLuaDir().."/config/editor_config.lua", string.format("errMsg=%q", errMsg).."\n"..string.format("nonPoint=%q", nonPoint).."\n"..string.format("showFileLabel=%q", showFileLabel))

      mLuaEditor.enableDrawingErrMsg(errMsg)

      mLuaEditor.invalidate()

    end

    sw2.onClick=function(v)

      nonPoint=v.isChecked()

      write(activity.getLuaDir().."/config/editor_config.lua", string.format("errMsg=%q", errMsg).."\n"..string.format("nonPoint=%q", nonPoint).."\n"..string.format("showFileLabel=%q", showFileLabel))

      mLuaEditor.enableNonPointing(nonPoint)

      mLuaEditor.invalidate()

    end

    sw3.onClick=function(v)

      showFileLabel=v.isChecked()

      write(activity.getLuaDir().."/config/editor_config.lua", string.format("errMsg=%q", errMsg).."\n"..string.format("nonPoint=%q", nonPoint).."\n"..string.format("showFileLabel=%q", showFileLabel))

      if showFileLabel then

        _mFileTab.Visibility = View.VISIBLE

       else

        _mFileTab.Visibility = View.GONE

      end

    end

  end

  menu5.add("Lua调试日志").onMenuItemClick=function(a)

    activity.newActivity("activitys/log_activity",{ last_theme })

  end

  menu5.add("崩溃日志").onMenuItemClick=function(a)

    activity.newActivity("activitys/crash_activity",{ last_theme })

  end

  menu5.add("Java方法浏览器").onMenuItemClick=function(a)

    activity.newActivity("activitys/api_activity",{ last_theme })

  end

  menu5.add("reOpenLua+帮助").onMenuItemClick=function(a)

    activity.newActivity("activitys/help_activity",{ last_theme })

  end

  menu.add("权限").onMenuItemClick=function(a)

    activity.newActivity("activitys/permission_activity",{ last_theme })

  end

  menu.add("关于").onMenuItemClick=function(a)

    onVersionChanged("","")

  end

  pop.show()

end







local 搜索关键字 = ""

local 搜索关键字结果 = {}

local 搜索关键字位置 = 1

local 搜索关键字长度 = 0

mArrow_x.onClick=function()

  if mSearchEdit.Text==nil or mSearchEdit.Text=="" then

    print("请输入关键字")

    return

  end

  --判断是否是上次的搜索的关键字
  if mSearchEdit.Text == 搜索关键字 then

    --判断搜索有没有内容
    if (#搜索关键字结果) == 0 then

      print("结果为空")

      return

     else

      --定位关键字下一个位置
      搜索关键字位置 = 搜索关键字位置 + 1

    end

    if 搜索关键字位置 < (#搜索关键字结果) then

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

     elseif 搜索关键字位置 == (#搜索关键字结果) then

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

      搜索关键字位置 = 0

     elseif 搜索关键字位置 > (#搜索关键字结果) then

      搜索关键字位置 = 1

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

    end

   else

    --重新搜索并定位第一个关键字
    搜索关键字 = mSearchEdit.Text

    搜索关键字位置 = 1

    搜索关键字长度 = utf8.len(搜索关键字)

    搜索关键字结果 = luajava.astable(LuaString.gfind(mLuaEditor.Text,搜索关键字))

    if (#搜索关键字结果)==0 then

      print("什么都没有")

     else

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

    end

  end


end



mArrow_s.onClick=function()

  if mSearchEdit.Text==nil or mSearchEdit.Text=="" then

    print("请输入关键字")

    return

  end

  --判断是否是上次的搜索的关键字
  if mSearchEdit.Text == 搜索关键字 then

    --判断搜索有没有内容
    if (#搜索关键字结果) == 0 then

      print("结果为空")

      return

     else

      --定位关键字下一个位置
      搜索关键字位置 = 搜索关键字位置 - 1

      if 搜索关键字位置 == -1 then

        if (#搜索关键字结果) == 1 then

          搜索关键字位置 = 1

         elseif (#搜索关键字结果) > 1 then

          搜索关键字位置 = #搜索关键字结果 - 1

        end

      end

    end

    if 搜索关键字位置 > 0 then

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

     elseif 搜索关键字位置 == 0 then

      搜索关键字位置 = #搜索关键字结果

      local first = 搜索关键字结果[搜索关键字位置][0]

      mLuaEditor.setSelection(first,搜索关键字长度)

    end

   else

    print("瞎按上键？")

  end


end














function onResume()

  --打开init.lua时候,调整工程属性,回来的时候重新读取文件
  if ends(mSubTitle.Text,"init.lua") then

    read(mSubTitle.Text)

  end

  save()

end





function onCreate()

  if last_file_path==app_root_lua then

    return

   else

    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED and

      ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) then

      open(last_file_path)

     else

      mMain.setVisibility(8)

      mPm.setVisibility(0)

    end

    isEdittingProject = true

    last_file_cursor = last_file_cursor or 0

    if last_file_cursor < mLuaEditor.getText().length() then

      mLuaEditor.setSelection(last_file_cursor)

    end

  end

end


function import_alp_dialog()--0.7.8

  MaterialAlertDialogBuilder(activity)

  .setTitle("导入工程")

  .setItems({"选择文件","自动搜索"},function(d,i)

    if i==0 then

      local lv=ListView(this).setFastScrollEnabled(true)

      local cp =TextView(this).setTextColor(subTextColor).setTextSize(14)

      MaterialAlertDialogBuilder(this)

      .setTitle("选择工程(*.alp)")

      .setView(LinearLayout(this).setOrientation(1).addView(cp).addView(lv))

      .setPositiveButton("取消",nil)

      .show()

      local adp=ArrayAdapter(this,android.R.layout.simple_list_item_1)

      lv.setAdapter(adp)

      local rootpath=Environment.getExternalStorageDirectory().toString()

      local function setItem(path)

        path=tostring(path)

        adp.clear()

        cp.setText(path)

        if path~=rootpath then

          adp.add("../")

        end

        ls=File(path).listFiles()

        if ls~=nil then

          ls=luajava.astable(File(path).listFiles())

          table.sort(ls,function(a,b)

            return (a.isDirectory()~=b.isDirectory() and a.isDirectory()) or ((a.isDirectory()==b.isDirectory()) and a.Name<b.Name)

          end)

         else

          ls={}

        end

        for index,c in ipairs(ls) do

          if c.isDirectory() then

            adp.add(c.Name.."/")

           elseif c.isFile() and ends(c.Name,".alp") then

            adp.add(c.Name)

          end

        end

      end
      setItem(rootpath)

      lv.onItemClick=function(l,v,p,s)

        local itemt=v.Text

        local mpath=nil

        if cp.Text==rootpath then

          mpath=ls[p+1]

         else

          mpath=ls[p]

        end

        if itemt=="../" then

          setItem(File(cp.Text).getParentFile())

         elseif mpath.isDirectory() then

          setItem(mpath)

         elseif mpath.isFile() then

          open(mpath.getPath())

        end

      end

     else

      alpFindDialog_show()

    end

  end)

  .show()

end


--查找alp工程的弹窗
function alpFindDialog_show()

  import "alys.alp_find"

  import "alys.alp_find_item"

  alpFindDialog = BottomSheetDialog(activity)

  alpFindDialogAly = loadlayout(alp_find)

  alpFindDialog.setContentView(alpFindDialogAly)

  alpFindDialog.getWindow().setBackgroundDrawable(ColorDrawable(0x00000000))

  local p = alpFindDialog.getWindow().getAttributes()

  p.width = activity.Width

  p.height = activity.Height * 0.8

  alpFindDialog.getWindow().setAttributes(p);

  local parent = alpFindDialogAly.getParent();

  --创建BottomSheetBehavior对象
  local mBehavior = BottomSheetBehavior.from(parent);

  --设置Dialog默认弹出高度为屏幕的0.5倍
  mBehavior.setPeekHeight(0.5 * activity.getHeight());

  alpFindDialog.show();

  local adp = LuaAdapter(activity,alp_find_item)

  list.setAdapter(adp)

  function setAdp(v)

    local n = string.sub(v,string.len(LuaFile.getParent(v))+2,-1)

    adp.add({

      malpImg = {

        src="res/imgs/project.png",

        colorFilter=colorSecondary,

      },
      malpTitle={

        text=n

      },
      malpSubTitle={

        text=v

      }

    })

  end


  function alpup()

    alp_pb.setVisibility(View.GONE)

  end

  function findFile()

    require "import"

    import "java.io.File"

    --判断文件以什么结尾
    function ends(s,End)

      return End=='' or string.sub(s,-string.len(End))== End

    end

    function find(path)

      if File(path).exists() then

        if File(path).isDirectory() then

          if(File(path).listFiles()) then

           else

            return

          end

          local path_list = luajava.astable(File(path).listFiles())

          --对文件进行排序
          table.sort(path_list,function(a,b)

            return (a.isDirectory()~=b.isDirectory() and b.isDirectory()) or ((a.isDirectory()==b.isDirectory()) and a.Name<b.Name)

          end)

          for k,v in pairs(path_list) do

            local path0 = v.toString()

            local path1 = "/storage/emulated/0/Androlua"

            local path2 = "/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent"

            local path3 = "/storage/emulated/0/Download"

            if path0==path1 or path0==path2 or path0==path3 then

              break

            end

            find(path0)

          end

         else

          if ends(path,".alp") then

            call("setAdp",path)

          end

        end

       else

        --print("文件夹不存在")

        return

      end

      --检查文件是否是文件夹
    end

    --优先查找常用文件夹下的alp
    --在查找sd卡下所有的alp(超级耗时)

    local path1 = "/storage/emulated/0/Androlua"

    find(path1)

    local path2 = "/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv"

    find(path2)

    local path3 = "/storage/emulated/0/Download"

    find(path3)

    local path4 = "/storage/emulated/0"

    find(path4)

    --print("alp工程文件全部查找完毕")

    call("alpup")

  end

  thread(findFile)

  list.setOnTouchListener(View.OnTouchListener{

    onTouch=function(v,event)

      if v.canScrollVertically(-1) then

        v.requestDisallowInterceptTouchEvent(true)

       else

        v.requestDisallowInterceptTouchEvent(false)

      end

      return false;

    end

  });

  list.onItemClick=function(l,v,p,i)

    local path = v.getChildAt(1).getChildAt(1).Text

    open(path)

  end

end



--新建文件对话框
function new_file_dialog()

  import "alys.new_file"

  local new_file_dlg = MaterialAlertDialogBuilder(activity)

  new_file_dlg.setTitle("新建文件")

  new_file_dlg.setView(loadlayout(new_file))

  new_file_dlg.setPositiveButton("新建",{

    onClick=function()

      --获取用户当前打开目录
      local path = mFileSubTitle.getText().."/"..file_name.Text

      if ends(path,".lua") then

        local lua = mFileSubTitle.getText() .."/"..file_name.Text

        LuaFile.write(lua, tcode)

        updataList()

       elseif ends(path,".aly") then

        local lua = mFileSubTitle.getText() .."/"..file_name.Text

        LuaFile.write(lua, lcode)

        updataList()

       else

        local other = mFileSubTitle.getText() .."/"..file_name.Text

        LuaFile.write(other,"")

        updataList()

      end

    end

  })

  new_file_dlg.setNegativeButton("取消", nil)

  new_file_dlg.show()

  --new_file_dlg.getButton(new_file_dlg.BUTTON_POSITIVE).setTextColor(标题文字颜色)

  --new_file_dlg.getButton(new_file_dlg.BUTTON_NEGATIVE).setTextColor(副标题文字颜色)

end



--新建文件夹
function new_folder_dialog()

  import "alys.new_folder"

  local new_folder_dlg = MaterialAlertDialogBuilder(activity)

  new_folder_dlg.setTitle("新建文件夹")

  new_folder_dlg.setView(loadlayout(new_folder))

  new_folder_dlg.setPositiveButton("新建",{

    onClick=function()

      local path = mFileSubTitle.getText().."/"..folder_name.Text

      if File(path).isDirectory()then

        print("文件夹已存在")

       else

        File(path).mkdir()

        updataList()

        print("文件夹创建成功")

      end

    end

  })

  new_folder_dlg.setNegativeButton("取消", nil)

  new_folder_dlg.show()

  --new_folder_dlg.getButton(new_folder_dlg.BUTTON_POSITIVE).setTextColor(标题文字颜色)

  --new_folder_dlg.getButton(new_folder_dlg.BUTTON_NEGATIVE).setTextColor(副标题文字颜色)

end


tcode = [[
require "import"
import "android.widget.*"
import "android.view.*"

]]
pcode = [[
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"

activity.setContentView(loadlayout(layout))
]]
lcode = [[
{
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  gravity="center",
  {
    Button,
    text="HELLOWORLD",
    id="btn",
  },
}
]]
upcode = [[
welcome_time="0"
debugmode=true
reOpenLuaTheme="Theme.Material3.Light"
theme="Theme_Material_Light"--Deprecated in reOpenLua+
enableLegacyTheme=false
enableExtendedOutputSupport=false
enableDialogLog=false
user_permission={
  "INTERNET",
  "WRITE_EXTERNAL_STORAGE"
}
]]




--判断文件以什么结尾
function ends(s,End)

  return End=='' or string.sub(s,-string.len(End))== End

end





--读取文件到LuaEditor

function open(path)

  if path == app_root_pro_dir or File(path).isDirectory() then

    return

  end

  if
    ends(path,".lua")

    or ends(path,".aly")

    or ends(path,".java")

    or ends(path,".kt")

    or ends(path,".txt")

    or ends(path,".json")

    or ends(path,".md")

    then

    mDraw.closeDrawer(3)

   elseif

    ends(path,".png")

    or ends(path,".jpg")

    or ends(path,".jpeg")

    or ends(path,".gif")

    then

    activity.newActivity("activitys/pic_activity",{path})

    return

   elseif ends(path,".alp") then

    imports(path)

    return

   else

    print("暂时不支持打开该类型的文件")

    return

  end

  read(path)

  local name = (path.."/"):match(app_root_pro_dir.."/(.-)/")

  local dir = File(path).getParent();

  mFileSubTitle.setText(dir)

  mTitle.setText(name)

  mSubTitle.setText(path)

end


--导出工程为alp文件
function export(pdir)

  require "import"

  import "java.util.zip.*"

  import "java.io.*"

  local function copy(input, output)

    local b = byte[2 ^ 16]

    local l = input.read(b)

    while l > 1 do

      output.write(b, 0, l)

      l = input.read(b)

    end

    input.close()

  end

  local f = File(pdir)

  local date = os.date("%y%m%d%H%M%S")

  local tmp = activity.getLuaExtDir("backup") .. "/" .. f.Name .. "_" .. date .. ".alp"

  local p = {}

  local e, s = pcall(loadfile(f.Path .. "/init.lua", "bt", p))

  if e then

    if p.mode then

      tmp = string.format("%s/%s_%s_%s_%s.%s", activity.getLuaExtDir("backup"), p.appname,p.mode, p.appver:gsub("%.", "_"), date,p.ext or "alp")

     else

      tmp = string.format("%s/%s_%s_%s.%s", activity.getLuaExtDir("backup"), p.appname, p.appver:gsub("%.", "_"), date,p.ext or "alp")

    end

  end

  local out = ZipOutputStream(FileOutputStream(tmp))

  local using={}

  local using_tmp={}

  function addDir(out, dir, f)

    local ls = f.listFiles()

    for n = 0, #ls - 1 do

      local name = ls[n].getName()

      if name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then

       elseif

        p.mode

        and name:find("%.lua$")

        and name ~= "init.lua"

        then

        local ff=io.open(ls[n].Path)

        local ss=ff:read("a")

        ff:close()

        for u in ss:gmatch([[require *%b""]]) do

          if using_tmp[u]==nil then

            table.insert(using,u)

            using_tmp[u]=true

          end

        end

        local path, err = console.build(ls[n].Path)

        if path then

          entry = ZipEntry(dir .. name)

          out.putNextEntry(entry)

          copy(FileInputStream(File(path)), out)

          os.remove(path)

         else

          error(err)

        end

       elseif

        p.mode

        and name:find("%.aly$")

        then

        name = name:gsub("aly$", "lua")

        local path, err = console.build_aly(ls[n].Path)

        if path then

          entry = ZipEntry(dir .. name)

          out.putNextEntry(entry)

          copy(FileInputStream(File(path)), out)

          os.remove(path)

         else

          error(err)

        end

       elseif ls[n].isDirectory() then

        addDir(out, dir .. name .. "/", ls[n])

       else

        entry = ZipEntry(dir .. name)

        out.putNextEntry(entry)

        copy(FileInputStream(ls[n]), out)

      end

    end

  end

  addDir(out, "", f)

  local ff=io.open(f.Path.."/.using","w")

  ff:write(table.concat(using,"\n"))

  ff:close()

  entry = ZipEntry(".using")

  out.putNextEntry(entry)

  copy(FileInputStream(f.Path.."/.using"), out)

  out.closeEntry()

  out.close()

  os.remove(f.Path.."/.using")

  return tmp

end





--新建工程对话框
function new_project_dialog()

  import "alys.new_pro"

  local project_dlg = MaterialAlertDialogBuilder(activity)

  project_dlg.setTitle("新建工程")

  project_dlg.setView(loadlayout(new_pro))

  for i=1,500 do

    local file = File(activity.getLuaExtPath("/project/demo"..i));

    if file.isDirectory()then

      continue

     else

      project_appName.setText("demo"..i)

      project_packageName.setText("com.openlua.demo"..i)

      break

    end

  end

  project_dlg.setPositiveButton("确定", { onClick = function()

      local appname = project_appName.getText().toString()

      local packagename = project_packageName.getText().toString()

      local f = File(app_root_pro_dir .."/".. appname)

      if f.exists() then

        print("工程已存在")

        return

      end

      save()

      luadir = app_root_pro_dir .."/".. appname .. "/"

      main = luadir .. "main.lua"

      alyp = luadir .. "layout.aly"

      init = luadir .. "init.lua"

      LuaFile.write(init, string.format("appname=\"%s\"\nappver=\"1.0\"\npackagename=\"%s\"\n%s", appname, packagename, upcode))

      LuaFile.write(main, pcode)

      LuaFile.write(alyp, lcode)

      open(main)

      updataList(app_root_pro_dir .."/".. appname)

    end
  })

  project_dlg.setNegativeButton("取消", nil)

  project_dlg.show()

  --project_dlg.getButton(project_dlg.BUTTON_POSITIVE).setTextColor(标题文字颜色)

  --project_dlg.getButton(project_dlg.BUTTON_NEGATIVE).setTextColor(副标题文字颜色)

end





mAdd.onClick=function()

  local pop =PopupMenu(activity,mAdds)

  local menu=pop.Menu

  if mFileSubTitle.getText()==app_root_pro_dir then

    menu.add("新建工程").onMenuItemClick=function(a)

      new_project_dialog()

    end

    menu.add("导入工程").onMenuItemClick=function(a)

      import_alp_dialog()

    end

   else

    menu.add("文件").onMenuItemClick=function(a)

      new_file_dialog()

    end
    menu.add("文件夹").onMenuItemClick=function(a)

      new_folder_dialog()

    end
    menu.add("新建工程").onMenuItemClick=function(a)

      new_project_dialog()

    end

    menu.add("导入工程").onMenuItemClick=function(a)

      import_alp_dialog()

    end

  end

  pop.show()

end



mAll.onClick=function()

  mLuaEditor.selectAll()

end

mCut.onClick=function()

  mLuaEditor.cut()

end

mCopy.onClick=function()

  mLuaEditor.copy()

end

mPaste.onClick=function()

  mLuaEditor.paste()

end


import "com.myopicmobile.textwarrior.android.OnSelectionChangedListener"

mLuaEditor.setOnSelectionChangedListener(OnSelectionChangedListener{

  a=function(active,s,e)

    if active then

      mSelect.setVisibility(View.VISIBLE)

     else

      mSelect.setVisibility(View.INVISIBLE)

    end

  end,

})


mDraw.setDrawerListener(DrawerLayout.DrawerListener{

  onDrawerOpened=function(drawerView)

    updataList()

  end

})






--符号栏
function Creat_Shortcut_Symbol_Bar(id)

  local t=

  {
    "FUN","(",")","[","]","{","}",

    "\"","=",":",".",",",";","_",

    "+","-","*","/","\\","%",

    "#","^","$","?","&","|",

    "<",">","~","'"

  }

  for k,v in ipairs(t) do

    Shortcut_Symbol_Item=loadlayout({

      LinearLayout,

      layout_width="40dp",

      layout_height="40dp",

      {

        TextView,

        layout_width="40dp",

        layout_height="40dp",

        gravity="center",

        textColor=0xFFFFFFFF,

        clickable="true",

        focusable="true",

        backgroundResource=rippleRes.resourceId,

        text=v,

        onClick=function()

          if v=="FUN" then v="function()" end

          mLuaEditor.paste(v)

        end,

      },

    })

    id.addView(Shortcut_Symbol_Item)

  end

end

activity.getWindow().setSoftInputMode(0x10)

task(1,Creat_Shortcut_Symbol_Bar(ps_bar))




--按两次退出
参数=0

function onKeyDown(code,event)

  if code==KeyEvent.KEYCODE_BACK then

    if 参数+2 > tonumber(os.time()) then

      activity.finish()

     else

      --退出之前判断选择框是否显示
      if mDraw.isDrawerOpen(Gravity.LEFT) then

        mDraw.closeDrawer(Gravity.LEFT)

       elseif mSelect.getVisibility()==0 then

        mSelect.setVisibility(View.INVISIBLE)

       elseif mSearch.getVisibility()==0 then

        mSearch.setVisibility(View.INVISIBLE)

       else

        print("再按一次返回键退出")

        参数=tonumber(os.time())

      end

    end

    return true

  end

end





--判断文件或者文件夹是否存在
function file_exists(path)

  local f=io.open(path,'r')

  if f~=nil then io.close(f) return true else return false end

end


--异步更新到当前目录或者更新到指定目录
function updataList(path)

  task(1,_updataList(path))

end

--更新到当前目录或者更新到指定目录
function _updataList(path)

  --save()

  --判断有没有指定的目录
  if path then

    当前文件路径 = path

    --filetab.Visibility = 0

    --filetab.setPath(path)

   else

    --filetab.Visibility = 8

    --没有指定的目录的话,默认刷新当前的目录
    当前文件路径 = tostring(mFileSubTitle.getText())

    --如果默认目录被删除了,就直接更新工程根目录
    if 当前文件路径=="未打开文件" then

      当前文件路径 = app_root_pro_dir

    end

  end

  --判断文件夹
  if File(当前文件路径).isDirectory() then

    --1.清除文件列表
    mLuaAdapter.clear()

    mLuaAdapter.notifyDataSetChanged();

    --获得当前目录文件列表


    当前工程列表 = luajava.astable(File(当前文件路径).listFiles())

    if (#当前工程列表) == 0 then

      mFileEnpty.setVisibility(View.VISIBLE)

     else

      mFileEnpty.setVisibility(View.INVISIBLE)

    end

    --如果为根目录
    if 当前文件路径 == app_root_pro_dir then

      mFileTitle.setText("未打开工程")

     else

      local name = (当前文件路径.."/"):match(app_root_pro_dir.."/(.-)/")

      mFileTitle.setText(name)

    end

    mFileSubTitle.setText(当前文件路径)

   else

    --先保存之前的代码,再读取当前文件
    save()

    --如果为文件格式,则读取文件,并刷新该文件所在的目录
    open(当前文件路径)

    return

  end

  if LuaFile.getParent(当前文件路径)==luajava.luaextdir then

   else

    mLuaAdapter.add({

      mItemImg = {

        src= "res/imgs/folder.png",

        colorFilter=colorSecondary,

      },
      mItemTitle ={

        text="...",

      },
      mItemSubTitle={

        tag=LuaFile.getParent(当前文件路径),

        text="返回上级目录",

      },

    })

  end

  --对文件进行排序
  table.sort(当前工程列表,function(a,b)

    return (a.isDirectory()~=b.isDirectory() and b.isDirectory()) or ((a.isDirectory()==b.isDirectory()) and a.Name<b.Name)

  end)


  if (#当前工程列表) == 0 then



  end

  for k,v in pairs(当前工程列表) do

    v = tostring(v)

    --n = string.sub(v,string.len(mFileSubTitle.Text)+2,-1)

    n = File(v).getName();

    if n == "" or n == nil or TextUtils.isEmpty(n) then

      print("工程名字异常,建议修改")

      n = "工程文件名字异常"

    end

    if File(v).isDirectory() then

      i = "res/imgs/folder.png"

     else

      i = "res/imgs/file.png"

    end

    if LuaFile.getParent(当前文件路径)==luajava.luaextdir then

      i = "res/imgs/project.png"

    end

    mLuaAdapter.add({

      mItemImg = {

        src=i,

        colorFilter=colorSecondary,

      },
      mItemTitle ={

        text=n,

      },
      mItemSubTitle={

        text=v,

        tag=v,

      },

    })

  end

end






onStop=function()

  save()


  local f = io.open(activity.getLuaDir().."/config/lua_project.lua", "wb")

  f:write(string.format("last_file_path=%q\nlast_file_cursor=%d", last_file_path, mLuaEditor.getSelectionEnd() ))

  f:close()



  local f = io.open(activity.getLuaDir().."/config/lua_history.lua", "wb")

  f:write(string.format("last_history=%s", dump(last_history)))

  f:close()

end







mList.onItemClick=function(l,view,p,i)

  --获得点击时路径
  local path = view.getChildAt(1).getChildAt(1).Tag

  --判断是打开目录还是打开文件
  updataList(path)

  return true

end



--复制文本
function CopyTheText(str)

  str=tostring(str)

  import "android.content.*"

  activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(str)

  print("已复制")

end




--文件重命名
function rename(path,name)

  import "alys.new_rename"

  local new_file_dlg = MaterialAlertDialogBuilder(activity)

  new_file_dlg.setTitle("重命名文件")

  new_file_dlg.setView(loadlayout(new_rename))

  file_name.Text = name

  new_file_dlg.setPositiveButton("重命名",{

    onClick=function()

      new_path = mFileSubTitle.getText().."/"..file_name.Text

      File(path).renameTo(File(new_path))

      updataList()

    end

  })

  new_file_dlg.setNegativeButton("取消", nil)

  new_file_dlg.show()

  --new_file_dlg.getButton(new_file_dlg.BUTTON_POSITIVE).setTextColor(标题文字颜色)

  --new_file_dlg.getButton(new_file_dlg.BUTTON_NEGATIVE).setTextColor(副标题文字颜色)

end


--项目被长按
mList.onItemLongClick=function(l,v,p,i)

  local pop =PopupMenu(activity,v)

  local menu=pop.Menu

  local path = v.getChildAt(1).getChildAt(1).Text

  local name = v.getChildAt(1).getChildAt(0).Text

  --判断工程目录
  if mFileSubTitle.Text == app_root_pro_dir then

    menu.add("删除").onMenuItemClick=function(a)

      if name==mTitle.Text then

        print("不能删除已打开的工程")

       else

        LuaFile.delete(path)

        updataList(app_root_pro_dir)

        print("工程已删除")

      end

    end

    pop.show()

    return true

  end

  if path=="返回上级目录" then

   else

    menu.add("复制文件路径").onMenuItemClick=function(a)

      CopyTheText(path)

    end

    menu.add("删除").onMenuItemClick=function(a)

      if path==mSubTitle.Text then

        print("不能删除已打开的文件")

       else

        if LuaFile.delete(path) then

          updataList()

          print("文件已删除")

        end

      end


    end

    menu.add("重命名").onMenuItemClick=function(a)

      if path==mSubTitle.Text then

        print("不能重命名当前打开文件")

       else

        rename(path,name)

      end

    end

    pop.show()

  end

  return true

end


local function adds()

  require "import"

  local classes = require "activitys.android"

  local ms = {

    "onCreate",

    "onStart",

    "onResume",

    "onPause",

    "onStop",

    "onDestroy",

    "onActivityResult",

    "onResult",

    "onCreateOptionsMenu",

    "onOptionsItemSelected",

    "onRequestPermissionsResult",

    "onClick",

    "onTouch",

    "onLongClick",

    "onItemClick",

    "onItemLongClick",

    "onVersionChanged",

    "this",

    "android",

    "dp2px",

    "table2json",

    "json2table",

    "L",

  }

  local buf = String[#ms + #classes]

  for k, v in ipairs(ms) do

    if v=="this" or v=="L" or v=="android" then

      buf[k - 1] = v

     else

      buf[k - 1] = v.."()"

    end

  end

  local l = #ms

  for k, v in ipairs(classes) do

    buf[l + k - 1] = string.match(v, "%w+$")

  end

  return buf

end

task(adds, function(buf)

  mLuaEditor.addNames(buf)

end)

local buf={}

local tmp={}

local curr_ms=luajava.astable(LuaActivity.getMethods())

for k,v in ipairs(curr_ms) do

  v=v.getName()

  if not tmp[v] then

    tmp[v]=true

    table.insert(buf,v.."()")

  end

end

mLuaEditor.addPackage("activity",buf)

local buf={}

local tmp={}

local curr_ms=luajava.astable(LuaActivity.getMethods())

for k,v in ipairs(curr_ms) do

  v=v.getName()

  if not tmp[v] then

    tmp[v]=true

    table.insert(buf,v.."()")

  end

end

mLuaEditor.addPackage("this",buf)



function fix(c)

  local classes = require "activitys.android"

  if c then

    local cls = {}

    c = "%." .. c .. "$"

    for k, v in ipairs(classes) do

      if v:find(c) then

        table.insert(cls, string.format("import %q", v))

      end

    end

    if #cls > 0 then

      create_import_dlg()

      import_dlg.setItems(cls)

      import_dlg.show()

    end

  end

end



function onNewIntent(intent)

  local uri = intent.getData()

  if uri and uri.getPath():find("%.alp$") then

    imports(uri.getPath():match("/storage.+") or uri.getPath())

  end

end


function getalpinfo(path,k)

  local app = {}

  loadstring(tostring(String(LuaUtil.readZip(path,"init.lua"))), "bt", "bt", app)()

  local str = string.format("名称: %s\
版本: %s\
包名: %s\
路径: %s",
  app.appname,
  app.appver,
  app.packagename,
  path
  )
  if k then
    return str
   else
    return app.mode
  end

end

function imports(path)

  local message = getalpinfo(path,true)

  local mode = getalpinfo(path,false)

  create_imports_dlg(path,"导入")

  imports_dlg.setMessage(message)

  if mode == "plugin" or path:match("^([^%._]+)_plugin") then

    create_imports_dlg(path,"导入插件")

    imports_dlg.setTitle("导入插件")

   elseif mode == "build" or path:match("^([^%._]+)_build") then

    create_imports_dlg(path,"打包安装")

    imports_dlg.setTitle("打包安装")

  end

  imports_dlg.show()

end


function create_imports_dlg(path,title)

  if imports_dlg then

    return

  end

  imports_dlg = MaterialAlertDialogBuilder(activity)

  imports_dlg.setTitle("导入")

  imports_dlg.setPositiveButton("确定", {

    onClick = function()

      if alpFindDialog then

        alpFindDialog.dismiss()

      end

      --local path = imports_dlg.Message:match("路径: (.+)$")

      if title == "打包安装" then

        importx(path, "build")

        imports_dlg.setTitle("导入")

       elseif title == "导入插件" then

        importx(path, "plugin")

        imports_dlg.setTitle("导入")

       else

        importx(path)

      end

  end })

  imports_dlg.setNegativeButton("取消", nil)

end


function importx(path, tp)

  require "import"

  import "java.util.zip.*"

  import "java.io.*"

  local function copy(input, output)

    local b = byte[2 ^ 16]

    local l = input.read(b)

    while l > 1 do

      output.write(b, 0, l)

      l = input.read(b)

    end

    output.close()

  end

  local f = File(path)

  local app = {}

  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()

  local s = app.appname or f.Name:match("^([^%._]+)")

  local out = activity.getLuaExtDir("project") .. "/" .. s

  if tp == "build" then

    out = activity.getLuaExtDir("bin/.temp") .. "/" .. s

   elseif tp == "plugin" then

    out = activity.getLuaExtDir("plugin") .. "/" .. s

  end

  local d = File(out)

  if autorm then

    local n = 1

    while d.exists() do

      n = n + 1

      d = File(out .. "-" .. n)

    end

  end

  if not d.exists() then

    d.mkdirs()

  end

  out = out .. "/"

  local zip = ZipFile(f)

  local entries = zip.entries()

  for entry in enum(entries) do

    local name = entry.Name

    local tmp = File(out .. name)

    local pf = tmp.ParentFile

    if not pf.exists() then

      pf.mkdirs()

    end

    if entry.isDirectory() then

      if not tmp.exists() then

        tmp.mkdirs()

      end

     else

      copy(zip.getInputStream(entry), FileOutputStream(out .. name))

    end

  end

  zip.close()

  function callback2(s)

    LuaUtil.rmDir(File(activity.getLuaExtDir("bin/.temp")))

    bin_dlg.hide()

    bin_dlg.Message = ""

    if s==nil or not s:find("成功") then

      create_error_dlg()

      error_dlg.Message = s

      error_dlg.show()

    end

  end

  if tp == "build" then

    bin(out)

    return out

   elseif tp == "plugin" then

    print("导入插件 : " .. s)

    return out

  end

  luadir = out

  luapath = luadir .. "main.lua"

  open(luapath)

  print("导入工程 : " .. luadir)

  return out

end



function create_import_dlg()

  if import_dlg then

    return

  end

  import_dlg = MaterialAlertDialogBuilder(activity)

  import_dlg.Title = "可能需要导入的类"

  import_dlg.setPositiveButton("确定", nil)

  import_dlg.ListView.onItemClick = function(l, v)

    CopyTheText(v.Text)

    import_dlg.hide()

    return true

  end

end


function onActivityResult(req, res, intent)

  if res == 10000 then

    local alypath = intent.getStringExtra("alypath")

    open(alypath)

    mLuaEditor.format()

    return

  end

  if res ~= 0 then

    local data = intent.getStringExtra("data")

    local _, _, path, line = data:find("\n[	 ]*([^\n]-):(%d+):")

    if path == luapath then

      editor.gotoLine(tonumber(line))

    end

    local classes = require "activitys.android"

    local c = data:match("a nil value %(global '(%w+)'%)")

    if c then

      local cls = {}

      c = "%." .. c .. "$"

      for k, v in ipairs(classes) do

        if v:find(c) then

          table.insert(cls, string.format("import %q", v))

        end

      end

      if #cls > 0 then

        create_import_dlg()

        import_dlg.setItems(cls)

        import_dlg.show()

      end

    end

  end

end