precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTimeDelta;
uniform float iTime;
uniform int iFrame;
uniform mat4 iViewMatrix;
uniform vec2 resolution;
uniform float time;

attribute vec4 aPosition;
attribute vec4 aTextureCoord;
varying vec2 vTextureCoord;

void main() {
    vTextureCoord = aTextureCoord.xy;
    gl_Position = iViewMatrix * aPosition;
}