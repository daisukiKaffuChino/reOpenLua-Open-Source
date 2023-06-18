require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
--[[
import "androidx.recyclerview.widget.RecyclerView"
import "androidx.recyclerview.widget.LinearLayoutManager"
import "github.daisukiKaffuChino.LuaCustRecyclerHolder"
import "github.daisukiKaffuChino.LuaGroupRecyclerHolder"
import "github.daisukiKaffuChino.LuaExpandableRecyclerAdapter"
import "github.daisukiKaffuChino.ExpandableAdapterCreator"
import "github.daisukiKaffuChino.expandableRecyclerAdapter.BaseGroupBean"
import "github.daisukiKaffuChino.expandableRecyclerAdapter.BaseChildBean"]]
import "github.daisukiKaffuChino.CustomViewPager"
import "github.daisukiKaffuChino.LuaSimpleMarkdownView"
import "rawio"

theme = ...
import ("themes."..theme)
activity.setTitle("帮助")
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)
activity.getWindow().setNavigationBarColor(0)

function onOptionsItemSelected(m)
  activity.finish()
end
--[[--废案
activity.setContentView(loadlayout({
  LinearLayout,
  layout_width="-1",
  layout_height="-1",
  orientation="vertical",
  {
    RecyclerView,
    id="rv",
    layout_width="-1",
    layout_height="-1",
  },
}))

group_item={
  LinearLayout,
  layout_width="-1",
  layout_height="-2",
  orientation="vertical",
  {
    TextView,
    id="a",
    layout_width="-1",
    layout_height="-2",
  },
}

child_item={
  LinearLayout,
  layout_width="-1",
  layout_height="-2",
  orientation="vertical",
  {
    TextView,
    id="b",
    layout_width="-1",
    layout_height="-2",
  },
}

data={BaseGroupBean({
    BaseChildBean({"aaa","111"})
  }),
  BaseGroupBean({
    BaseChildBean({"bbb","222"}),
    BaseChildBean({text="ccc"}),
  })
}

adp=LuaExpandableRecyclerAdapter(ExpandableAdapterCreator({
  getGroupCount=function()
    return #data
  end,
  getGroupItem=function(i)
    return data[i+1]
  end,

  onCreateGroupViewHolder=function(parent,viewType)
    local views={}
    groupHolder=LuaGroupRecyclerHolder(loadlayout(group_item,views),ExpandableAdapterCreator({
      onExpandStatusChanged=function(adp,isExpanding)

      end
    }))
    groupHolder.view.setTag(views)
    return groupHolder
  end,
  onBindGroupViewHolder=function(holder,bean,isExpand)
    --view=holder.view.getTag()

  end,
  onCreateChildViewHolder=function(parent,viewType)
    local views={}
    childHolder=LuaCustRecyclerHolder(loadlayout(child_item,views))
    childHolder.view.setTag(views)
    return childHolder
  end,
  onBindChildViewHolder=function(holder,groupBean,childBean)

  end
}))

rv.setAdapter(adp)
rv.setLayoutManager(LinearLayoutManager(this))
--adp.expandGroup(data[1])
--]]
activity.setContentView(loadlayout({
  LinearLayout,
  layout_width="-1",
  layout_height="-1",
  orientation="vertical",
  {
    CustomViewPager,
    layout_width="-1",
    layout_height="-1",
    id="vpg",
    pages={
      -----
      {
        ListView,
        id="lv",
        layout_width="-1",
        layout_height="-1",
      },
      -----    
      {
        LinearLayout,
        layout_width="-1",
        layout_height="-1",
        padding="12dp",
        {
          LuaSimpleMarkdownView,
          id="webView",
          layout_width="-1",
          layout_height="-1",
        },
      },
      -----
    },
  },
}))


item={
  LinearLayout,
  layout_height="-2",
  layout_width="-1",
  paddingLeft="16dp",
  paddingRight="16dp",
  paddingTop="12dp",
  paddingBottom="12dp",
  {
    TextView,
    id="text",
    layout_height="-2",
    layout_width="-1",
    textColor=textColor,
    textSize="16dp",
  },
}

data={
  {text="reOpenLua+概述",file="overview.md"},
  {text="迁移到新标准库",file="lib.md"},
  {text="init.lua新增配置",file="config.md"},
  {text="LuaActivity部分新增方法",file="LuaActivity.md"},
  {text="LuaKeyboardObserver",file="LuaKeyboardObserver.md"},
  {text="LuaNetStateChangeObserver",file="LuaNetStateChangeObserver.md"},
  {text="LuaAppDefender",file="LuaAppDefender.md"},
  {text="LuaCustRecyclerAdapter",file="LuaCustRecyclerAdapter.md"},
  --{text="示例工程:Material Design",file="",demo=true},
  --{text="示例工程:LuaCustRecyclerAdapter",file="",demo=true},
}

adp=LuaAdapter(activity,data,item)
lv.setAdapter(adp)

lv.onItemClick=function(l,v,p,i)
  activity.setTitle(data[i].text)
  vpg.setCurrentItem(1)
  local md=rawio.iotsread(activity.getLuaDir().."/res/docs/"..data[i].file,"r")
  --webView.loadDataWithBaseURL("",Markdown4jProcessor().process(md),"text/html","utf-8",nil)
  webView.loadFromText(md)
end

function onKeyDown(code,event)
  if code==KeyEvent.KEYCODE_BACK then
    if vpg.getCurrentItem()~=0 then
      vpg.setCurrentItem(0)
      activity.setTitle("帮助")
      return true
    end
  end
end
