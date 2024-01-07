![image](https://github.com/tanpuer/ShaderToyAndroid/blob/master/show.gif)

### background
ShaderToy plugin for Android

### steps
1. using the same vertex_shader.glsl in Android assets folder.
2. copy fragment_shader.glsl from https://www.shadertoy.com/.
3. make some modifications:
    out, texture
   gl_FragCoord / iResolution.xy => gl_FragCoord.xy / iResolution.xy
   uniform shader iChannel0 => #iChannel0 "assets://shader/raining/raining.png"
4. fix other shader compile errors.