#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
//#iChannel0 "assets://shader/solar/sun.png"
uniform sampler2D iChannel0;
in vec2 vTextureCoord;
out vec4 fragColor;

#define EPS 0.001
#define MAX_DIST 50.
#define PI 3.141592

struct SdfCtx {
    float k;
    vec3 col;
    float d;
};

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdTorus(vec3 p, float bR) {
    return length(vec2(length(p.xz) - bR, p.y)) - 0.0015;
}

float stripe(float dist, float o) {
    return abs(dist) - o;
}

SdfCtx addPrimitive(SdfCtx p1, SdfCtx p2) {
    if (p1.d < p2.d) {
        return p1;
    }
    return p2;
}

mat2 rotMat(float k) {
    float c = cos(k);
    float s = sin(k);
    return mat2(c, -s, s,  c);
}

mat3 rotateY(float k) {
    float c = cos(k);
    float s = sin(k);
    return mat3(c,  0, -s,
                0,  1,  0,
                s,  0,  c);
}

SdfCtx calcDist(vec3 p) {
    float t = iTime;

    float dStripedSphere = stripe(stripe(stripe(stripe(sdSphere(p * rotateY(t * 0.05) + vec3(2.05, 0., 2.05), 0.264 + 0.08), 0.08), 0.06), 0.02), 0.01);
    float dStripes = max(max(dStripedSphere, p.y), -(p.y + 0.001));

    vec3 moonP = 0.1 + (p * rotateY(t * 0.3) - vec3(0.1) * rotateY(t * 3.5));

    //PLANETS
    SdfCtx d = 			SdfCtx(0.,  vec3(0.,   0.,   0.),   sdSphere(p * rotateY(t * 0.)    + vec3(0., 0., 0.),     0.42));   // SUN
    d = addPrimitive(d, SdfCtx(0.,  vec3(0.1,  0.1,  0.1), 	sdSphere(moonP 				    + vec3(0.75, 0., 0.75), 0.02)));  // MOO
    d = addPrimitive(d, SdfCtx(0., 	vec3(0.3,  0.3,  0.3),  sdSphere(p * rotateY(t * 2.)    + vec3(0.45, 0., 0.45), 0.03)));  // MER
    d = addPrimitive(d, SdfCtx(0., 	vec3(0.57, 0.57, 0.57), sdSphere(p * rotateY(t * 1.)    + vec3(0.65, 0., 0.65), 0.072))); // VEN
    d = addPrimitive(d, SdfCtx(0., 	vec3(0.1,  0.3,  0.4),  sdSphere(p * rotateY(t * 0.3)   + vec3(0.85, 0., 0.85), 0.078))); // EAR
    d = addPrimitive(d, SdfCtx(1., 	vec3(0.53, 0.24, 0.15), sdSphere(p * rotateY(t * 0.2)   + vec3(1.1,  0., 1.1),  0.06)));  // MAR
    d = addPrimitive(d, SdfCtx(35., vec3(0.4,  0.2,  0.07), sdSphere(p * rotateY(t * 0.1)   + vec3(1.45, 0., 1.45), 0.33)));  // JUP
    d = addPrimitive(d, SdfCtx(30., vec3(0.3,  0.2,  0.1),  sdSphere(p * rotateY(t * 0.05)  + vec3(2.05, 0., 2.05), 0.264))); // SAT
    d = addPrimitive(d, SdfCtx(2., 	vec3(0.45, 0.59, 0.71), sdSphere(p * rotateY(t * 0.01)  + vec3(2.55, 0., 2.55), 0.15)));  // URA
    d = addPrimitive(d, SdfCtx(40., vec3(0.2,  0.29, 0.47), sdSphere(p * rotateY(t * 0.005) + vec3(2.8,  0., 2.8),  0.1)));   // NEP

    vec3 orbitCol = vec3(0.15);

    //ORBITS
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 0.63))); // MER
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 0.92))); // VEN
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 1.20))); // EAR
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 1.55))); // MAR
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 2.05))); // JUP
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 2.90))); // SAT
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 3.60))); // URA
    d = addPrimitive(d, SdfCtx(0., orbitCol, sdTorus(p, 3.95))); // NEP

    //RINGS
    d = addPrimitive(d, SdfCtx(0.,  vec3(0.3,  0.2,  0.1),  dStripes)); // SAT

    return d;
}

vec3 calcNormal(vec3 pos) {
    float d = calcDist(pos).d;
    return normalize(vec3(d - calcDist(pos - vec3(EPS, 0,  0 )).d,
                          d - calcDist(pos - vec3( 0, EPS, 0 )).d,
                          d - calcDist(pos - vec3( 0,  0, EPS)).d));
}

vec3 calcLight(vec3 fragPos, vec3 lightPos, vec3 lightCol, vec3 camDir) {
    vec3 normal = calcNormal(fragPos);
    vec3 lightDir = normalize(lightPos - fragPos);

    vec3 ambient = vec3(0.1);
    vec3 diffuse = vec3(max(dot(normal, lightDir), 0.));

    return lightCol * (ambient + diffuse);
}

mat3 calcLookAtMatrix(vec3 camPos, vec3 at) {
    vec3 zAxis = normalize(at - camPos);
    vec3 xAxis = normalize(cross(zAxis, vec3(0., 1., 0.)));
    vec3 yAxis = normalize(cross(xAxis, zAxis));
    return mat3(xAxis, yAxis, zAxis);
}

SdfCtx rayMarch(vec3 rayO, vec3 rayD) {
    SdfCtx res = SdfCtx(0., vec3(0), 0.);
    for( int i = 0 ; i < 100; i++ ) {
        SdfCtx dS = calcDist(rayO + rayD * res.d);
        if (dS.d < EPS || res.d > MAX_DIST) break;
        res.col = dS.col;
        res.k = dS.k;
        res.d += dS.d;
    }
    return res;
}

vec3 calcPlanetTexture(vec2 p, vec3 col, float k) {
    return vec3(sin(p.y * k) * 0.1 + 0.4) * col;
}

float fallingStar(vec2 p, vec2 a, vec2 b) {
    p -= a;
    b -= a;
    float h = clamp(dot(p, b) / dot(b, b), 0., 1.);
    p -= b * h;
    return h * smoothstep(2. * h / iResolution.y, 0., length(p));
}

float hash(vec3 p) {
    p = fract(p * vec3(.1031, .11369, .13787));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

float calcStarLayer(vec3 d, float intensity) {
    return smoothstep(intensity, 0., length(fract(d) - 0.5)) * smoothstep(0.98, 1., hash(floor(d)));
}

vec3 calcBgColor(vec2 xy, vec3 rayDir) {
    return fallingStar(xy * rotMat(PI), vec2(-0.04) + tan(iTime / 4.), vec2(0.04) + tan(iTime / 4.)) * vec3(0.3, 0.4, 0.7) +
    vec3(calcStarLayer(rayDir * 550., abs(sin(iTime / 2.)) / 2.)) * vec3(0.5, 0.28, 0.73) +
    vec3(calcStarLayer(rayDir * 500., abs(cos(iTime / 2.)) / 2.)) * vec3(0.3, 0.6,  0.73) +
    vec3(calcStarLayer(rayDir * 400., abs(cos(iTime)) / 2.)) * vec3(0.5, 0.58, 0.43) +
    vec3(calcStarLayer(rayDir * 500., abs(sin(iTime)) / 2.)) * vec3(0.2, 0.2, 0.8);
}

vec2 calcUV(vec3 p) {
    vec3 n = calcNormal(p);
    return vec2(atan(n.x, n.z) / (2. * PI) + 0.5, n.y * 0.5 + 0.5);
}

void main() {
    vec2 xy = (gl_FragCoord.xy - iResolution.xy / 2.) / min(iResolution.x, iResolution.y);

    vec3 camPos = vec3(-7., 6. * max(abs(cos(iTime / 30.)), 0.4), -8. * sin(iTime / 30.));
    mat3 cam = calcLookAtMatrix(camPos, vec3(0, -0.5, 0));

    vec3 rayDir = cam * normalize(vec3(xy, 2.));
    SdfCtx rayRes = rayMarch(camPos, rayDir);

    vec3 col = vec3(0);

    if(rayRes.d < MAX_DIST){
        vec3 p = camPos + rayRes.d * rayDir;
        if (rayRes.col.x == 0.) {
            col = (texture(iChannel0, calcUV(p * rotateY(iTime / 5.))).xyz / 1.1 + 0.5) * 1.5 * vec3(0.96, 0.55, 0);
        } else {
            col = vec3(calcPlanetTexture(vec2(p), rayRes.col, rayRes.k)) + calcLight(p, vec3(0), vec3(0.4), rayDir);
        }
    } else {
        col = calcBgColor(xy, rayDir) + vec3(0.09 / length(xy - vec2(0, 0.07))) * vec3(0.7, 0.5, 0.);
    }

    fragColor = vec4(col, 1);
}