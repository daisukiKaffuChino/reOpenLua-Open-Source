local function autotheme()
  local h=tonumber(os.date("%H"))
  local R=luajava.bindClass("github.daisukiKaffuChino.reopenlua.R")
    if h<=6 or h>=22 then
      return (R.style.Theme_ReOpenLua_MaterialComponent_Dark)
    else
      return (R.style.Theme_ReOpenLua_MaterialComponent_Light)
    end
end

return autotheme
