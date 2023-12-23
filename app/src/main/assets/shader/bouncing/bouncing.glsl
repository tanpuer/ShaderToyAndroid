#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
in vec2 vTextureCoord;
out vec4 fragColor;

vec3 rng;
float bodySize = 0.2;

// shape eyes
vec2 size = vec2(.07, .05);
float divergence = 0.06;

// easing curves are below
float jump(float);
float walk(float);
float stretch(float);
float bounce(float);
float swing(float);

// Inigo Quilez
float sdArc( in vec2 p, in float ta, in float tb, in float ra, float rb )
{
    vec2 sca = vec2(sin(ta),cos(ta));
    vec2 scb = vec2(sin(tb),cos(tb));
    p *= mat2(sca.x,sca.y,-sca.y,sca.x);
    p.x = abs(p.x);
    float k = (scb.y*p.x>scb.x*p.y) ? dot(p,scb) : length(p);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

// snippets
#define fill(sdf) (smoothstep(.001, 0., sdf))
mat2 rot (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float circle (vec2 p, float size)
{
    return length(p)-size;
}

// list of transformation (fun to tweak)
vec2 animation(vec2 p, float t)
{
    t = fract(t);

    p.y -= bodySize-0.5;
    p.y -= jump(t)*0.5;
    //p.x += walk(t)*0.1;
    p.x *= stretch(t)*-0.2+1.;

    // bounce stretch with collision
    float b = bounce(t)*.2;
    p.y *= b+1.;
    p.y += abs(b)*bodySize;

    return p;
}

void main()
{
    vec4 color = vec4(0.,0.,0.,1.);

    // number of friends
    const float buddies = 3.;
    for (float i = 0.; i < buddies; ++i)
    {
        // usefull to dissociate instances
        float ii = i/(buddies-1.);
        float iii = 1.-ii;

        // translate instances
        vec2 pp = (gl_FragCoord.xy-0.5*iResolution.xy)/iResolution.y;
        pp.x += (ii*2.-1.)*.4;
        pp.y -= 0.1;

        // time
        float t = fract(iTime*.5 + ii * .5);

        // there will be sdf shapes
        float shape = 1000.;
        vec2 p;

        // there will be layers
        vec3 col = vec3(0);

        // color palette
        // Inigo Quilez (https://iquilezles.org/articles/palettes)
        vec3 tint = .5+.5*cos(vec3(0.,.3,.6)*6.28+i-length(animation(pp-vec2(0,.1),t))*3.);

        // body shape
        float body = circle(animation(pp, t), bodySize);
        col += tint*fill(body);
        shape = min(shape, body);

        // eyes positions
        p = animation(pp, t+0.02);
        p *= rot(swing(t)*-.5);
        p -= vec2(.03, bodySize+size.x*.2);
        p.x = abs(p.x)-divergence;

        // globe shape
        float eyes = circle(p, size.x);
        shape = min(shape, eyes);
        col = mix(col, tint, fill(eyes));

        // white eye shape
        eyes = circle(p, size.y);
        col = mix(col, vec3(1), fill(eyes));
        shape = min(shape, eyes);

        // black dot shape
        eyes = circle(p, 0.02);
        col = mix(col, vec3(0), fill(eyes));

        // smile animation
        float anim = cos(pow(t, .5)*6.28)*.5+.5;

        // smile position
        p = animation(pp, t-0.02);
        p *= rot(swing(t)*.5);
        p -= bodySize*vec2(.4, 1.-1.5*anim);

        // arc (fun to tweak)
        float smile = mix(0., 1., anim);//+(.5+.5*sin(ii*12.+iTime*12.*ii));
        float thin = mix(0.1, 0.02, anim);//+0.04*(.5+.5*sin(ii*12.+iTime*22.*ii));
        float d = sdArc(p,-3.14/2., smile, 0.1, thin);

        // mouth shape
        d = d-mix(.01, .04, anim);
        shape = min(shape, d);
        col = mix(col, tint*(1.-p.x), fill(d));

        // black line
        col = mix(col, tint*.5, fill(d+.05));

        // add color to frame
        color.rgb = mix(color.rgb, col, step(shape, 0.));
    }
    fragColor = color;
}

// easing curves (not easy to tweak)
// affect timing of transformations;

float jump (float t)
{
    t = min(1., t*4.);
    t = abs(sin(t*3.1415));
    return pow(sin(t*3.14/2.), 1.9);
}

float walk (float t)
{
    t = mix(pow(t,.5), pow(t, 2.0), t);
    return (cos(t*3.1415*2.));
}

float swing (float t)
{
    t = pow(t, .5);
    //t = t*2.;
    //t = pow(t, .5);
    t = sin(t*3.14*2.);
    return t;
}

float stretch (float t)
{
    float tt = sin(pow(t, .2)*10.);
    return tt;
}

float bounce (float t)
{
    float tt = cos(pow(t, .2)*6.38);
    return tt;
}