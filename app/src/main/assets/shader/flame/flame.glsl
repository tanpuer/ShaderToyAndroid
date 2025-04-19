#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
in vec2 vTextureCoord;
out vec4 fragColor;

//#iChannel0 "assets://shader/flame/iChannel0.png"
uniform sampler2D iChannel0;

#define R iResolution.xy
#define S smoothstep
#define T texture

vec3 flame (vec2 u, float s, vec3 c1, vec3 c2) {
    float y = S(-.4,.4,u.y);
    u += T(iChannel0, u*.02 + vec2(s - iTime*.03, s - iTime*.1)).r * y * vec2(0.7, 0.2);
    float f = S(.2, 0., length(u) - .4);
    f *= S(0., 1., length(u + vec2(0., .35)));
    return f*mix(c1,c2,y);
}

void main()
{
    vec2 u = (gl_FragCoord.xy-.5*R)/R.y*vec2(10.,1.3);

    vec3 f1 = flame(u+vec2( 3.,0.),.1,vec3(.9,.4,.6),vec3(.9,.7,.3));
    vec3 f2 = flame(u+vec2( 1.,0.),.2,vec3(.2,.6,.7),vec3(.6,.8,.9));
    vec3 f3 = flame(u+vec2(-1.,0.),.3,vec3(.9,.4,.3),vec3(1.,.8,.5));
    vec3 f4 = flame(u+vec2(-3.,0.),.4,vec3(.2,.3,.8),vec3(.9,.6,.9));

    vec3 C = f1+f2+f3+f4;
    fragColor = vec4(C+C,1.0);
}