### 运行时权限
Android 6.0(API 级别 23)开始，Android引入了**运行时权限**，应用安装时不向其授予权限，应用运行时向其授予权限。如果在运行时该功能没有动态地申请相应的权限，就会抛出SecurityException异常。

##### 运行时权限的申请过程主要有两步：
1. 在需要申请权限的地方检查该权限是否被授权，如果已经授权就直接执行，如果未授权就动态申请权限。
2. 重写LuaActivity的`onRequestPermissionsResult`方法。如果用户未授权必须权限并选择了“拒绝并不再询问”，还要引导用户去系统设置界面打开权限。

相关内容可以参考reOpenLua+的开源代码。使用`ActivityCompat`和`ContextCompat`来保证不同API版本下的兼容性。