### 介绍
非PackageManager直接获取签名，简单而不失强度。

### 示例

```lua
--导包
import "github.daisukiKaffuChino.utils.LuaAppDefender"
--实例化
defender=LuaAppDefender(this)
--再传入一次Context，返回值为String
print(defender.get(this))
```

### 注意！
reOpenLua+的类名未经混淆，攻击者极易知晓逻辑。此外，无法保证不被一键过签。
