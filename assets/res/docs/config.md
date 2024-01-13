### init.lua新增配置
LuaActivity在初始化时会从这里读取一些数据。本编辑器的部分功能依赖此配置，错误的配置可能导致问题。请仅使用reOpenLua+自带的工程属性来编辑init.lua。

以下是可选的配置项：

- welcome_time (启动页展示时长) 参数类型String 保留自OpenLua的配置项，要关闭启动页则设置为"0"并使用透明图替换默认Logo。启动页Logo默认为应用图标，在工程根目录放置logo.png可以在打包时进行替换。

- enableExtendedOutputSupport（扩展的Lua控制台输出）默认参数false

- enableDialogLog (对话框式调试信息输出) 默认参数false

- reOpenLuaTheme (质感设计主题) 用以替代原版的Theme配置项，配置后无需再在代码中设置主题且全局生效。

- useLegacyTheme (启用遗留的旧版主题) 一般无需配置 默认参数false 

此外，由于移除了百度统计和精简了一些逻辑，例如key、channel等配置已被废弃，在本编辑器上不再生效。