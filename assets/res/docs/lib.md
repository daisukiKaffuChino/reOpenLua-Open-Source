### 迁移到新标准库
本编辑器可以帮助你轻松地使用现代Jetpack组件。随着Support库被废弃，迁移到AndroidX**更利于**开发和项目维护。

原版AndroLua+并未依赖Support或AndroidX库，要使用一些常用但是安卓SDK中不自带控件额外造了很多轮子。这些陈旧的类例如PageView、CircleImageView已被移除。如今，这些被移除的类都有更好的替代，例如ViewPager和ShapeableImageView，你可以在androidx和material库中找到。

导入其它第三方库时，得益于本编辑器自带未混淆的AndroidX和Kotlin语言库，**你无需再担心大部分依赖问题**。例如，在加载大图时可以使用Glide、picasso等框架；处理联网请求时可以考虑使用OkHttp等框架。



