require "import"
import "android.widget.*"
import "android.view.*"

path = ...

activity.getSupportActionBar().hide()

pcall(function()
  local window=activity.getWindow()
  window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
  pcall(function()
    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
    window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
    window.setStatusBarColor(Color.TRANSPARENT)
    window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE)
  end)
end)

import "com.open.lua.widget.PhotoView"
import "com.google.android.material.floatingactionbutton.FloatingActionButton"
import "com.bumptech.glide.*"

layout={
  FrameLayout,
  id="bg",
  background="#FF000000",
  layout_width="-1",
  layout_height="-1",
  {
    PhotoView,
    layout_width = "-1",
    layout_height = "-1",
    id = "mPhotoView",
  },
  {
    FloatingActionButton,
    layout_width="-2",
    layout_height="-2",
    src="imgs/sync",
    layout_gravity="bottom|end",
    layout_marginEnd="16dp",
    layout_marginBottom="36dp",
    onClick="switchBg",
  },
}

activity.setContentView(loadlayout(layout))

mPhotoView.enable()
mPhotoView.enableRotate()
mPhotoView.setAnimaDuring(500)
mPhotoView.setAdjustViewBounds(true)

Glide.with(this)
.load(path)
.into(mPhotoView)

local i=1
function switchBg()
  switch i do
   case 1
    i=i+1
    bg.setBackgroundColor(0xff888888)
   case 2
    i=i+1
    bg.setBackgroundColor(0xffffffff)
   case 3
    i=1
    bg.setBackgroundColor(0xff000000)
  end
end
