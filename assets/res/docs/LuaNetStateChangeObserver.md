### 介绍
实时监听网络连接状态。

### 示例
注册监听器

```lua
--导入包
import "github.daisukiKaffuChino.observer.LuaNetStateChangeObserver"

--传入Context和接口
LuaNetStateChangeObserver.registerReceiver(activity,LuaNetStateChangeObserver.NetStateChangeObserver{
  onConnect=function()
    --已连接
  end,
  onDisconnect=function()
    --断开连接
  end
})
```

注销监听器

```lua
--记得注销，比如在Activity销毁时调用
LuaNetStateChangeObserver.unRegisterReceiver(activity)
```
