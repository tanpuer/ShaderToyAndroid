#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
uniform vec4 iMouse;
in vec2 vTextureCoord;
out vec4 fragColor;

//#iChannel0 "assets://shader/raining/raining.png"
uniform sampler2D iChannel0;

#define R     iResolution.xy
#define PI    3.14159265
#define S     smoothstep
#define PX(a) a/R.y

mat2 Rot (float a) {
    return mat2(cos(a), sin(-a), sin(a), cos(a));
}

float Box (vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d,0.)) + min(max(d.x,d.y),0.);
}

float IconPhoto (vec2 uv) {
    float c = 0.;
    for (float i = 0.; i < 1.; i+=1./8.) {
        vec2 u = uv;
        u *= Rot(i * 2. * PI);
        u += vec2(0., PX(40.));
        float b = Box(u, vec2(PX(0.), PX(13.)));
        c += S(PX(1.5), 0., b - PX(15.)) * .2;
    }

    return c;
}

vec4 LiquidGlass (sampler2D tex, vec2 uv, float direction, float quality, float size) {

    vec2 radius = size/R;
    vec4 color = texture(tex, uv);

    for (float d = 0.; d < PI; d += PI/direction) {
        for (float i = 1./quality; i <= 1.; i += 1./quality) {
            color += texture(tex, uv + vec2(cos(d),sin(d)) * radius * i);
        }
    }

    color /= quality * direction;
    return color;
}

vec4 Icon (vec2 uv) {
    float box = Box(uv, vec2(PX(50.))),
    boxShape = S(PX(1.5), 0., box - PX(50.)),
    boxDisp = S(PX(35.), 0., box - PX(25.)),
    boxLight = boxShape * S(0., PX(30.), box - PX(40.)),
    icon = IconPhoto(uv);
    return vec4(boxShape, boxDisp, boxLight, icon);
}

void main() {
    vec2 uv = gl_FragCoord.xy/R,
    st = (gl_FragCoord.xy-.5*R)/R.y,
    M  = iMouse.xy == vec2(0.) ? vec2(0.) : (iMouse.xy-.5*R)/R.y;

    vec4 icon = Icon(st-M);

    vec2 uv2 = uv - iMouse.xy/R;
    uv2 *= .5 + .5 * S(.5, 1., icon.y);
    uv2 += iMouse.xy/R;

    vec3 col = mix(texture(iChannel0, uv).rgb * .8, .2 + LiquidGlass(iChannel0, uv2, 10., 10., 20.).rgb * .7, icon.x);
    col += icon.z * .9 + icon.w;

    col *= 1. - .2 * S(PX(80.), 0., Box(st-M+vec2(0.,PX(40.)), vec2(PX(50.))));

    fragColor = vec4(col,1.0);
}