
--该文件为默认配置文件
--目的是为了初始化应用(第一次安装软件打开后的配置)


--应用根目录
app_root_dir = luajava.luaextdir

--应用工程根目录
app_root_pro_dir = app_root_dir.."/project"

--默认第一次打开的lua文件或者软件出现异常时打开的文件
app_root_lua = app_root_dir .."/".. "new.lua"

