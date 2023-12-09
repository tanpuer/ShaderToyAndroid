#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTimeDelta;
uniform float iTime;
uniform int iFrame;
uniform mat4 iViewMatrix;
uniform vec2 resolution;
uniform float time;
in vec2 vTextureCoord;
out vec4 fragColor;
#define iGlobalTime iTime

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
 
    for (float i = 1.0; i < 10.0; i++) {
        float v = 0.1 * sin((uv.r + uv.g) * 0.5 * i + iTime) / i;
        float u = 0.1 * cos((uv.r - uv.g) * 0.5 * i + iTime) / i;

        uv += vec2(u, v);
    }

    uv = fract(uv);

    fragColor = vec4(uv, 1.0, 1.0);
}