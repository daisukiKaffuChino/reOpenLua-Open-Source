### 介绍
LuaActivity新增了一些方法，但大多用不到。

### 示例

```lua
--接收String。重载目录下init.lua中的主题配置。编辑器打开新项目时或许能用上。
function newProject(path)

--返回String。获取应用名。
function getAppName()

--返回int。继承自AppCompatActivity。
function onNightModeChanged(mode)

--转换浅色/深色模式。
function switchDayNight()

--返回ViewGroup。顾名思义。
function getRootView()

--返回boolean。是否为鸿蒙。
function isHarmonyOS()
```