require "import"
local h=tonumber(os.date("%H"))
if h<=7 or h>=19 then
  return import "themes.AppDarkTheme"
 else
  return import "themes.AppBlueTheme"
end