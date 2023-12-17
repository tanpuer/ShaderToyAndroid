#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
in vec2 vTextureCoord;
out vec4 fragColor;
#define iMouse vec3(0.0, 0.0, 0.0)

#define A(v) mat2(cos(m.v+radians(vec4(0, -90, 90, 0))))  // rotate
#define W(v) length(vec3(p.xy-v(p.z+vec2(pi_2, 0)+t), 0))-lt  // wave
#define P(v) length(p-vec3(v(t+pi_2), v(t), 0))-pt  // point
void main()
{
    float lt = .1, // line thickness
    pt = .3, // point thickness
    pi = 3.1416,
    pi2 = pi*2.,
    pi_2 = pi/2.,
    t = iTime *pi,
    s = 1., d = 0., i = d;
    vec2 R = iResolution.xy,
    m = (iMouse.xy-.5*R)/R.y*4.;
    vec3 o = vec3(0, 0, -7), // cam
    u = normalize(vec3((gl_FragCoord.xy-.5*R)/R.y, 1)),
    c = vec3(0), k = c, p;
    if (iMouse.z < 1.) m = -vec2(t/20., 0);
    mat2 v = A(y), h = A(x); // pitch & yaw
    for (; i++<50.;) // raymarch
    {
        p = o+u*d;
        p.yz *= v;
        p.xz *= h;
        p.z -= 3.;
        if (p.y < -1.5) p.y = 1.8/p.y;
        k.x = min( max(p.z, W(sin)), P(sin) );
        k.y = min( max(p.z, W(cos)), P(cos) );
        s = min(s, min(k.x, k.y));
        if (s < .001 || d > 100.) break;
        d += s*.5;
    }
    c = max(cos(d*pi2) - s*sqrt(d) - k, 0.);
    c.gb += .1;
    fragColor = vec4(c*.4 + c.brg*.6 + c*c, 1);
}