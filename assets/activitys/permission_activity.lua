require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.content.res.ColorStateList"
import "androidx.recyclerview.widget.RecyclerView"
import "androidx.recyclerview.widget.LinearLayoutManager"
import "github.daisukiKaffuChino.AdapterCreator"
import "github.daisukiKaffuChino.LuaCustRecyclerAdapter"
import "github.daisukiKaffuChino.LuaCustRecyclerHolder"
import "android.Manifest"
import "android.content.pm.PackageManager"
import "androidx.core.widget.NestedScrollView"
import "androidx.core.app.ActivityCompat"
import "com.google.android.material.button.MaterialButton"

theme=...
import ("themes."..theme)
activity.Title="管理权限"
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)
activity.getWindow().setNavigationBarColor(0)

function onOptionsItemSelected(m)
  activity.finish()
end

activity.setContentView(loadlayout(
{
  NestedScrollView,
  layout_width="fill",
  layout_height="fill",
  {
    LinearLayout,
    orientation="vertical",
    layout_width="fill",
    layout_height="fill",
    backgroundColor=colorBackground,
    {
      TextView,
      textColor=textColor,
      textSize="16sp",
      text="在开发时若编辑器没有相应权限，运行代码将会报错。点击以下列表项进行授权。",
      padding="16dp",
    },
    {
      RecyclerView,
      id="rv",
      layout_width="fill",
      layout_height="fill",
    },
    {
      MaterialButton,
      text="一键授权",
      layout_gravity="end",
      layout_marginStart="16dp",
      layout_marginEnd="16dp",
      onClick=function()
        local mAppPermissions = ArrayList()
        local mAppPermissionsTable = luajava.astable(activity.getPackageManager().getPackageInfo(activity.getPackageName(),PackageManager.GET_PERMISSIONS).requestedPermissions)
        for k,v in pairs(mAppPermissionsTable) do
          mAppPermissions.add(v)
        end
        local size = mAppPermissions.size()
        local mArray = mAppPermissions.toArray(String[size])
        ActivityCompat.requestPermissions(this,mArray,1)
      end,
    },
  },
}))

pm={
  Manifest.permission.SEND_SMS,
  Manifest.permission.READ_SMS,
  Manifest.permission.WRITE_CONTACTS,
  Manifest.permission.READ_CONTACTS,
  Manifest.permission.READ_PHONE_STATE,
  Manifest.permission.BLUETOOTH,
  Manifest.permission.ACCESS_COARSE_LOCATION,
  Manifest.permission.ACCESS_FINE_LOCATION,
  Manifest.permission.CAMERA,
  Manifest.permission.RECORD_AUDIO,
  Manifest.permission.READ_CALENDAR,
  Manifest.permission.BLUETOOTH,
  Manifest.permission.ANSWER_PHONE_CALLS,
}

data={
  {name="SEND_SMS",isAuth=ActivityCompat.checkSelfPermission(this, pm[1])},
  {name="READ_SMS",isAuth=ActivityCompat.checkSelfPermission(this, pm[2])},  
  {name="WRITE_CONTACTS",isAuth=ActivityCompat.checkSelfPermission(this, pm[3])},
  {name="READ_CONTACTS",isAuth=ActivityCompat.checkSelfPermission(this, pm[4])},
  {name="READ_PHONE_STATE",isAuth=ActivityCompat.checkSelfPermission(this, pm[5])},
  {name="BLUETOOTH",isAuth=ActivityCompat.checkSelfPermission(this, pm[6])},
  {name="ACCESS_COARSE_LOCATION",isAuth=ActivityCompat.checkSelfPermission(this, pm[7])},
  {name="ACCESS_FINE_LOCATION",isAuth=ActivityCompat.checkSelfPermission(this, pm[8])},
  {name="CAMERA",isAuth=ActivityCompat.checkSelfPermission(this, pm[9])},
  {name="RECORD_AUDIO",isAuth=ActivityCompat.checkSelfPermission(this, pm[10])},
  {name="READ_CALENDAR",isAuth=ActivityCompat.checkSelfPermission(this, pm[11])},
  {name="BLUETOOTH",isAuth=ActivityCompat.checkSelfPermission(this, pm[12])},
  {name="ANSWER_PHONE_CALLS",isAuth=ActivityCompat.checkSelfPermission(this, pm[13])},
}

local ripples = activity.obtainStyledAttributes({android.R.attr.selectableItemBackground}).getResourceId(0,0)

adp=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return #data
  end,
  getItemViewType=function(position)
    return 0
  end,
  onCreateViewHolder=function(parent,viewType)
    local views={}
    holder=LuaCustRecyclerHolder(loadlayout({
      LinearLayout,
      id="content",
      layout_width="fill",
      layout_height="wrap",
      paddingStart="16dp",
      paddingEnd="16dp",
      paddingTop="8dp",
      paddingBottom="8dp",
      {
        TextView,
        textColor=textColor,
        textSize="14sp",
        id="title",
      },
      {
        Space,
        layout_weight="1",
      },
      {
        TextView,
        textSize="14sp",
        id="status",
      },
    },views))
    holder.view.setTag(views)
    return holder
  end,
  onBindViewHolder=function(holder,pos)
    view=holder.view.getTag()
    view.title.Text=data[pos+1].name
    if data[pos+1].isAuth==0 then
      view.status.Text="√"
     view.status.textColor=colorPrimary
     elseif data[pos+1].isAuth==-1 then
      view.status.Text="×"
     view.status.textColor=colorSecondary
    end
    view.content.BackgroundDrawable=activity.Resources.getDrawable(ripples).setColor(ColorStateList(int[0].class{int{}},int{0x30404040}))
    view.content.onClick=function()
      ActivityCompat.requestPermissions(this, {pm[pos+1]}, 1)
    end
  end
}))

rv.setAdapter(adp)
rv.setLayoutManager(LinearLayoutManager(this))

function onRequestPermissionsResult(reqCode,permissions,grantResults)
  if reqCode == 1 then
    for i=1,#data do
      data[i].isAuth=ActivityCompat.checkSelfPermission(this, pm[i])
    end
    adp.notifyDataSetChanged()
  end
end
