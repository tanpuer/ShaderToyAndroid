#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
//#iChannel0 "assets://shader/raining/raining.png"
uniform sampler2D iChannel0;
in vec2 vTextureCoord;
out vec4 fragColor;

void main()
{
    fragColor = texture(iChannel0, (gl_FragCoord.xy * .98 + iResolution.xy * .01 + (gl_FragCoord.xy - iResolution.xy / 2.).yx * vec2(-.03, .03)) / iResolution.xy);

    float t = iTime * .5;

    vec4 col = vec4(sin(t * vec3(13, 11, 17)) * .5 + .5, 1);
    float idx = .0 + 1.0 * smoothstep(6., 20., length(gl_FragCoord.xy - sin(vec2(11, 13) * t) * 60. - iResolution.xy / 2.));
    fragColor = mix(col, fragColor, idx);
}
