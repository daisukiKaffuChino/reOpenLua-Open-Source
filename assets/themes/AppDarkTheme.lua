
----------------------------------------------
--AppDarkTheme/黑色主题
----------------------------------------------

local LuaThemeUtil=luajava.bindClass("github.daisukiKaffuChino.utils.LuaThemeUtil")

local themeUtil=LuaThemeUtil(this)

colorPrimary=themeUtil.getColorPrimary()

colorPrimaryVariant=themeUtil.getColorPrimaryVariant()

colorOnPrimary=themeUtil.getColorOnPrimary()

colorSecondary=themeUtil.getColorSecondary()

textColor=themeUtil.getAnyColor(R.attr.custom_text_color)

subTextColor=themeUtil.getAnyColor(R.attr.custom_sub_text_color)

colorBackground=themeUtil.getAnyColor(R.attr.custom_bg_color)

colorPrimaryBackground=colorPrimaryVariant

BasewordColor=0xFF81C784
--关键字
KeywordColor=0xFFFFB74D
--注释
CommentColor=0x5FFFFFFF
--变量
UserwordColor=0xFF536DFE
--字符串
StringColor=0xFFE57373


--return R.style.Theme_ReOpenLua_Material3_Dark
