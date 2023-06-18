### init.lua新增配置
LuaActivity在初始化时会从这里读取一些数据。本编辑器的部分功能依赖此配置，错误的配置可能导致问题。请仅使用reOpenLua+自带的工程属性来编辑init.lua。

除了原有的相对原版Lua+新增的配置项welcome_time(启动页延时)外，从0.7.5开始，陆续新增了其它可配置项。它们是：

enableExtendedOutputSupport（扩展的Lua控制台输出）默认参数false

enableDialogLog (对话框式调试信息输出) 默认参数false

reOpenLuaTheme (质感设计主题) 用以替代原版的Theme配置项，配置后无需再在代码中设置主题且全局生效。详细参数详见另一篇主题帮助。

useLegacyTheme (启用遗留的旧版主题) 一般无需配置 默认参数false 

此外，例如key、channel等配置已被废弃，在本编辑器上不再生效。