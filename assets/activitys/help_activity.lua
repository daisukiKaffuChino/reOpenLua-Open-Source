require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
import "android.graphics.drawable.ColorDrawable"
import "android.net.Uri"
import "android.content.Intent"
import "rawio"

theme = ...
import ("themes."..theme)
activity.setTitle('帮助')
activity.setTheme(android.R.style.Theme_Material)

activity.getSupportActionBar().setElevation(0)
activity.getSupportActionBar().setBackgroundDrawable(ColorDrawable(状态栏背景色))
activity.getSupportActionBar().setDisplayShowHomeEnabled(false)
activity.getWindow().setStatusBarColor(状态栏背景色)
activity.getWindow().setNavigationBarColor(状态栏背景色)
activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(m)
switch m.getItemId() do
   case android.R.id.home
    activity.finish()
  end
end

import "org.markdown4j.Markdown4jProcessor"
local content = rawio.iotsread(activity.getLuaDir().."/help.md","r")

activity.setContentView(loadlayout({
  LinearLayout;
  layout_width="-1";
  layout_height="-1";
  orientation="vertical";
  {
    LuaWebView;
    id="WebView";
    layout_width="-1";
    layout_height="-1";
  };
}))

WebView.loadDataWithBaseURL("",Markdown4jProcessor().process(content),"text/html","utf-8",nil)

--好蠢的逻辑 别学
local currentTheme = nil
if theme == "AppAutoTheme" then
  local h = tonumber(os.date("%H"))
  if h<=7 or h>=19 then
    currentTheme = "AppDarkTheme"
   else
    currentTheme = "AppBlueTheme"
  end
 else
  currentTheme = theme
end

WebView.setWebViewClient({
  onPageFinished = function(view,url)
    if currentTheme == "AppDarkTheme" then
      WebView.evaluateJavascript([[javascript:(function(){var styleElem=null,doc=document,ie=doc.all,fontColor=50,sel="body,body *";styleElem=createCSS(sel,setStyle(fontColor),styleElem);function setStyle(fontColor){var colorArr=[fontColor,fontColor,fontColor];return"background-color:#212121 !important;color:RGB("+colorArr.join("%,")+"%) !important;"}function createCSS(sel,decl,styleElem){var doc=document,h=doc.getElementsByTagName("head")[0],styleElem=styleElem;if(!styleElem){s=doc.createElement("style");s.setAttribute("type","text/css");styleElem=ie?doc.styleSheets[doc.styleSheets.length-1]:h.appendChild(s)}if(ie){styleElem.addRule(sel,decl)}else{styleElem.innerHTML="";styleElem.appendChild(doc.createTextNode(sel+" {"+decl+"}"))}return styleElem}})();]],nil)
    end
  end,
  shouldOverrideUrlLoading=function(view,url)
    local intent = Intent()
    intent.setAction("android.intent.action.VIEW")
    local content_url = Uri.parse(url)
    intent.setData(content_url)
    activity.startActivity(intent)
    return true
  end
})

WebView.onLongClick = function()
  return true
end