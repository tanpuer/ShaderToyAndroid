#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
uniform vec4 iMouse;
in vec2 vTextureCoord;
out vec4 fragColor;

/*
    "Singularity" by @XorDev

    A whirling blackhole.
    Feel free to code golf!

    FabriceNeyret2: -19
    dean_the_coder: -12
    iq: -4
*/
void main()
{
    //Iterator and attenuation (distance-squared)
    float i = .2, a;
    //Resolution for scaling and centering
    vec2 r = iResolution.xy,
    //Centered ratio-corrected coordinates
    p = (gl_FragCoord.xy + gl_FragCoord.xy - r) / r.y / .7,
    //Diagonal vector for skewing
    d = vec2(-1, 1),
    //Blackhole center
    b = p - i * d,
    //Rotate and apply perspective
    c = p * mat2(1, 1, d / (.1 + i / dot(b, b))),
    //Rotate into spiraling coordinates
    v = c *  mat2(cos(.5 * log(a = dot(c, c)) + iTime *i + vec4(0, 33, 11,0))) / i,
//Waves cumulative total for coloring
w;

//Loop through waves
for(; i++< 9.; w += 1.+ sin(v))
//Distort coordinates
v += .7 * sin(v.yx * i + iTime) / i + .5;
//Acretion disk radius
i = length(sin(v / .3) * .4 + c *(3. + d));
//Red/blue gradient
fragColor = 1. - exp(- exp(c.x * vec4(.6, - .4, - 1,0))
//Wave coloring
/ w.xyyx
//Acretion disk brightness
/ (2. + i * i / 4. - i)
//Center darkness
/ (.5 + 1. / a)
//Rim highlight
/ (.03 + abs(length(p) - .7))
);
}
