### 项目支持
本项目不设群组。

Github [https://github.com/daisukiKaffuChino/reOpenLua-Open-Source](https://github.com/daisukiKaffuChino/reOpenLua-Open-Source)

未来将在这里发布最新版本，也欢迎在这里提交建议和反馈。

### 前言
**建议有一定安卓开发基础的用户使用。**

如果你认为本编辑器不自带中文、模板，或从其它编辑器复制来的代码无法运行让你困惑，那么你不适合使用它。如果你仅从QQ群或小论坛里接触编程相关的内容，那你同样不适合使用它。

### 值得注意的小改动
由CrashHandler保存未被捕获的Java异常，现在不会存放在外部存储。请到Android/data/包名/files/crash下查看。

补全了LuaActivity继承AppCompatActivity的一些方法，增加了更多新特性，修改了LuaActivity的包路径。

由于welcome.java**不再自动申请**全部权限，为符合Android设计运行时权限的初衷，请开发者自行实现权限申请和申请回调逻辑。

对AndroLua+的常用类可能略有改动，实际开发时请**留意Java方法浏览器**。

### 苦于找不到示例？
虽然现在可能还比较少，但请相信它们对你快速熟悉reOpenLua+非常有用。

在这里下载 [蓝奏云](https://chino.lanzouv.com/b0dgh7o5i) 密码7c92

示例工程将不定期以合集方式上传，如果你感兴趣的话可以多多留意。

### 对抗Hook干扰
从0.7.5开始本编辑器内置了基于Native的针对各Hook框架的检查及反制。检查节点设置在加载Lua脚本之前，可保护你的App运行免受干扰。

并非传统的一刀切式的检查，该检查**鼓励用户开启框架作用域**，旨在遏制框架的滥用对运行环境的破坏。无法检测对System的hook。