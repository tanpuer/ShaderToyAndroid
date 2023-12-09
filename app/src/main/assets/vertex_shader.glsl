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

in vec4 aPosition;
in vec4 aTextureCoord;
out vec2 vTextureCoord;

void main() {
    vTextureCoord = aTextureCoord.xy;
    gl_Position = iViewMatrix * aPosition;
}