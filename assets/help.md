### 值得注意的小改动
由CrashHandler保存未被捕获的Java异常，现在不会存放在外部存储。请到Android/data/包名/files/crash下查看。

补全了LuaActivity继承AppCompatActivity的一些方法，修改了LuaActivity的包路径。

由于welcome.java**不再自动申请**全部权限，为符合Android设计运行时权限的初衷，请开发者自行实现权限申请和申请回调逻辑。

小改了底层(例如抽象类LuaContext等)，实际开发时需要的改动请**留意Java方法浏览器**。

### 苦于找不到示例？
虽然现在可能还比较少，但请相信它们对你快速熟悉reOpenLua+非常有用。

在这里下载 [蓝奏云](https://chino.lanzouv.com/b0dgh7o5i) 密码7c92

示例工程将不定期以合集方式上传，如果你感兴趣的话可以多多留意。

### 迁移到新标准库
例如PageView、CircleImageView等类已被移除，未来reOpenLua+会进一步移除AndroLua+自带的非标准库。

这些被移除的类都有效果更好的替代方案，例如ViewPager和ShapeableImageView，你可以在androidx和material库中找到。

题外话，由于AndroLua+自带的LuaBitmap性能比较拉跨，在加载大图时建议使用Glide(4.0+)、picasso等框架；处理繁重联网请求时，可以考虑使用OkHttp等框架。

### init.lua新增配置
LuaActivity在初始化时会从这里读取一些数据。除了原有的相对原版AndroLua+新增的配置项welcome_time外，从0.7.5开始，继续新增了两个可配置项。分别是enableExtendedOutputSupport（扩展的Lua控制台输出）和enableDialogLog(对话框式调试信息输出)，默认参数为false。

此外，例如key、channel等配置已被废弃，推荐使用reOpenLua+自带的工程属性来编辑init.lua。

### 对抗Hook
从0.7.5开始内置了基于Native的针对各Hook框架的检查以及反制。检查节点设置在加载Lua脚本之前，可保护你的App运行免受干扰。

并非传统的一刀切式的检查，该检查**鼓励用户开启框架作用域**，旨在遏制框架的滥用对运行环境的破坏。无法检测对System的hook。

### 对质感设计的支持
reOpenLua+内置完整的最新Material Components(MDC)运行库。

质感设计是为了让我们开发的程序有一个统一的样式、品牌效应、互动效果以及操作界面产生的动作，是在Android原生组件的基础上添加了更加丰富的功能和显示效果，遵循Android界面设计的规范，能够更方便的设计产品，缩短开发设计时间。

可以使用activity.setTheme(R.style.Theme_ReOpenLua_Material3)切换到Material3主题。此外，内置的两种主题已适配**深色模式**，使用activity.switchDayNight()方法进行切换。

### 优化你的Apk
若你使用的dex较多，可以在打包完毕后将你的dex合并后命名为classes2.dex并移动到apk根目录（与axml同级），避免因动态读取dex而产生的性能损耗。

受限于AndroLua+自带打包的局限性，你可以手动删除打包后axml内多余的UNKNOW权限，无用的Service组件以及无障碍功能(如果实际开发中没有遇到的话)等。

应用签名也至关重要，作为检验正版与否的手段，请避免在应用发布时使用默认签名。如果TargetSDK高于30，你至少需要一个**V2及以上**签名。

### 代码安全
非常遗憾，由于目前LuaVM存在漏洞，现在无需使用电脑即可轻易对官方加密进行解密。

但是，Lua字节码有损编译依旧是你程序的最后防线，在得到完全可读的源代码之前需要对反编译结果进行手动修复，大多数情况下会让破解者得不偿失。

要保护你的源代码，请**注意备份**。勿使用任何最终调用dofile、loadstring等函数的加固/混淆服务；勿使用任何Lua算法加密自己；勿寄希望任何dex加固。

运行来路不明的文件时（尤其是加密的文件），请置于虚拟机运行，**谨防工程被盗或被删除**。

### 静下心来...
我们用简洁优美的Lua语言书写Android程序，因此原生Android开发的知识也是基础之一。reOpenLua+会尽可能使Lua调用原生特性更容易；同时在高版本系统上，鼓励开发者们使用现代api实现功能。

兴趣是最好的老师，如果你感兴趣，请务必多思考、少伸手，否则当热情退去浪费的只有时间。

不要参与购买或倒卖任何源码，不要以赚钱作为码字的动力，不要将你的项目功能实现寄希望于任何现成可抄的源代码。

我们**鼓励开源，反对抄袭**。虽然离目标依旧遥远，但还是希望AndroLua可以拥有自己的健康的开源社区和开源生态。

### 最后

reOpenLua+不设群组；一般不会频繁更新，仅发布于酷安。

最后，致谢OpenLua+开源项目。