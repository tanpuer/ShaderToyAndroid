#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
//uniform shader iChannel0;
//#iChannel0 "assets://shader/rainstorm/channel0.png"
//#iChannel1 "assets://shader/rainstorm/channel1.png"
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
in vec2 vTextureCoord;
out vec4 fragColor;

void MakeViewRay(in vec2 fragCoord, out vec3 eye, out vec3 ray)
{
    vec2 ooR = 1. / iResolution.xy;
    vec2 q = fragCoord.xy * ooR;
    vec2 p = 2. * q - 1.;
    p.x *= iResolution.x * ooR.y;

    vec3 lookAt = vec3(0., 0., 0. + iTime * .1);
    eye = vec3(2.5, 3., -2.5) * 1.5 + lookAt;
    //	eye = RotY(eye,iTime*.4);

    // camera frame
    vec3 fo = normalize(lookAt - eye);
    vec3 ri = normalize(vec3(fo.z, 0., -fo.x));
    vec3 up = normalize(cross(fo, ri));

    float fov = .25;

    ray = normalize(fo + fov * p.x * ri + fov * p.y * up);

}

#if 1

#define CHEAPER_NOISES

float Noise(in vec3 x, float lod_bias)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    #ifndef CHEAPER_NOISES
    f = f * f * (3.0 - 2.0 * f);    //not terribly noticeable for higher freq noises anyway
    #endif

    vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;
    #ifdef CHEAPER_NOISES
//    vec2 rg = texture(iChannel1, uv * (1. / 256.0), lod_bias).yx;
    vec2 rg = texture(iChannel1, vTextureCoord).yx;
    #else
    vec2 rg = texture(iChannel1, (uv + 0.5) / 256.0, lod_bias).yx;
    #endif
    return mix(rg.x, rg.y, f.z);
}

#else

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c)
{
    float j = 4096.0 * sin(dot(c, vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0 * j);
    j *= .125;
    r.x = fract(512.0 * j);
    j *= .125;
    r.y = fract(512.0 * j);
    r = r - 0.5;

    return r;
}

/* skew constants for 3d simplex functions */
const float F3 = 0.3333333;
const float G3 = 0.1666667;

/* 3d simplex noise */
float Noise(vec3 p, float lod) {
    p *= 0.3;

/* 1. find current tetrahedron T and its four vertices */
/* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
/* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

/* calculate s and x */
    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));

/* calculate i1 and i2 */
    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e * (1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy * (1.0 - e);

/* x1, x2, x3 */
    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0 * G3;
    vec3 x3 = x - 1.0 + 3.0 * G3;

/* 2. find four surflets and store them in d */
    vec4 w, d;

/* calculate surflet weights */
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

/* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
    w = max(0.6 - w, 0.0);

/* calculate surflet components */
    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);

/* multiply d by w^4 */
    w *= w;
    w *= w;
    d *= w;

/* 3. return the sum of the four surflets */
    return dot(d, vec4(52.0)) * .65 + .45;
}

#endif

vec4 BlendUnder(vec4 accum, vec4 col)
{
    col = clamp(col, vec4(0), vec4(1));
    col.rgb *= col.a;
    accum += col * (1.0 - accum.a);
    return accum;
}

vec4 March(vec4 accum, vec3 viewP, vec3 viewD, vec2 mM)
{
    //exponential stepping
    #define SHQ
//#define MEDQ
    //#define YUCKQ
    #ifdef SHQ
    #define STEPS    128
    float slices = 512.;
    #endif
#ifdef MEDQ
    #define STEPS    64
    float slices = 256.;
    #endif
#ifdef YUCKQ
    #define STEPS    32
    float slices = 128.;
    #endif

    float Far = 10.;

    float sliceStart = log2(mM.x) * (slices / log2(Far));
    float sliceEnd = log2(mM.y) * (slices / log2(Far));

    float last_t = mM.x;

    for (int i = 0; i < STEPS; i++)
    {
        sliceStart += 1.;
        float sliceI = sliceStart;// + float(i);	//advance an exponential step
        float t = exp2(sliceI * (log2(Far) / slices));    //back to linear

        vec3 p = viewP + t * viewD;
        vec3 uvw = p;
        uvw.y /= 10.;
        uvw.y += iTime;
        uvw *= 30.;

        float h = (1. - ((p.y + 1.) * 0.5));
        float dens = Noise(uvw, -100.);// * h;
        dens *= dens;
        dens *= dens;
        dens -= 0.25;
        dens *= (t - last_t) * 1.5;

        accum = BlendUnder(accum, vec4(vec3(1.), dens));

        last_t = t;
    }

    vec3 p = viewP + mM.y * viewD;
    vec3 uvw = p;
    uvw *= 20.;
    uvw.y += iTime * 20.;
    float dens = Noise(uvw, -100.);
    dens = sin(dens);
    dens *= dens;
    dens *= dens;
    dens *= .4;
    accum = BlendUnder(accum, vec4(1., 1., 1., dens));

    return accum;
}

void main()
{
    vec3 viewP, viewD;
    MakeViewRay(gl_FragCoord.xy, viewP, viewD);

    //ground plane
    float floor_height = -1.;
    float floor_intersect_t = (-viewP.y + floor_height) / (viewD.y);
    vec3 p = viewP + viewD * floor_intersect_t;
//    vec3 c = texture(iChannel0, p.xz * 0.125, floor_intersect_t * 2. - 16.).xyz;
    vec2 flippedTexCoords = vec2(vTextureCoord.s, 1.0 - vTextureCoord.t);
    vec3 c = texture(iChannel0, flippedTexCoords).xyz;
    c = pow(c, vec3(2.2));
    c *= 0.8;
    float ceil_intersect_t = (-viewP.y + 1.) / (viewD.y);

    vec4 a = March(vec4(0), viewP, viewD, vec2(ceil_intersect_t, floor_intersect_t));
    c = BlendUnder(a, vec4(c, 1.)).xyz;
    //	c=pow(c,vec3(1./2.2));
    fragColor = vec4(c, 1.0);

}