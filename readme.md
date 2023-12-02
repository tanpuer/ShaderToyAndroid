![image](https://github.com/tanpuer/ShaderToyAndroid/blob/master/show.gif)

### 背景
最近组里升级Skia，接入的Skia116可以很轻松地将shadertoy的特效移植过来。
想了下，如果想要简单使用，完全没必要引入Skia，因此参考vscode中的shadertoy插件实现ShaderToy for Android。

### 步骤
vertext.glsl使用同一个文件，参考Assets目录，将fragment.glsl文件放入对应目录，运行，点击NEXT。

从shadertoy上拷贝来的代码需要修改下，常见的修改点：
1. 确认有没有main函数。
2. 声明out vec4 fragColor，如果是es2.0使用gl_FragColor。
3. gl_FragCoord / iResolution.xy 修改为gl_FragCoord.xy / iResolution.xy。
4. 贴图修改//uniform shader iChannel0;为//#iChannel0 "assets://shader/raining/raining.png"。
5. 其余的可以看日志修改。