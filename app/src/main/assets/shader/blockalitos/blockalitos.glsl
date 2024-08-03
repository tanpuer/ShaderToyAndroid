#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

//#iChannel0 "assets://shader/blockalitos/iChannel0.png"
uniform sampler2D iChannel0;

// Blockalitos
// Leon Denise 2024-08-03

#define R iResolution.xy
float[] hello = float[] (184., 181., 188., 188., 191., 209.);
float[] cookie = float[] (179., 191., 191., 187., 185., 181.);

// Dave Hoskins https://www.shadertoy.com/view/4djSRW
vec3 hash33(vec3 p3)
{
    p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);
}

void main()
{
    // coordinates
    vec2 uv = gl_FragCoord.xy/R;
    vec2 p = (2.* gl_FragCoord.xy-R)/R.y;
    vec2 q = p;

    // layers
    float pattern = 0.;
    const float count = 4.;
    for (float i = 0.; i < count; ++i) {
        float factor = i/count;
        float scale = 20./pow(2., i);
        vec2 cell = floor(p*scale);
        float seed = i+floor(iTime*.5-length(cell)/scale/2.)*196.;
        vec3 rng = hash33(vec3(cell, seed));
        float mask = step(factor*1.5, rng.y);
        pattern = mix(pattern, rng.x, mask);
        q = mix(q, p*scale, mask);
    }

    // background
    vec2 cell = floor(q);
    vec2 atlas = fract(q);
    vec3 rng = hash33(vec3(cell,floor(pattern*100.)));

    // random symbol within range
    float char = 224.+floor(rng.z*32.);

    // pick in word
    char = rng.y > .4 ? char : cookie[int(rng.z*6.)];

    atlas += vec2(mod(char,16.),floor(char/16.));

    // title
    q = abs(p)-vec2(1.,.2);
    float box = max(q.x,q.y);
    if (box < 0.) {
        p = (p+vec2(0.,.333/2.))*3.;
        char = hello[int(floor(p.x+3.))];
        atlas = fract(p)+vec2(mod(char,16.),floor(char/16.));
        rng.x = floor(p.x);
        pattern = 1.;
    }

    // font sample
    float letter = texture(iChannel0, atlas/16.).r;

    // color palette https://iquilezles.org/articles/palettes/
    vec3 tint = .5+.5*cos(vec3(1,2,3)*4.5+rng.x*5.);

    // style
    bool bw = pattern > .6;
    vec3 color = (pattern > .7 ? tint * (1.-letter) : vec3(bw ? 1.-letter : letter));
    //vec3 color = tint * (pattern > .6 ? 1.-letter : letter);
    fragColor = vec4(color, 1);
}