### 介绍
封装了软键盘监听，在软键盘弹出或隐藏时触发回调。

### 示例
LuaActivity已实现相关接口，无需导包，可以直接使用以下方法。

```lua
function onObservedKeyboardHide()
--当键盘隐藏时
end

function onObservedKeyboardShow(keyBoradHeight)
--当键盘弹出时，返回键盘高度(int)
end
```

### 近期修改
修正了方法名`onObservedKeyboardShow`的拼写。

