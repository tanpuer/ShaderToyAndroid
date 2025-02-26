#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

void main()
{
    //Resolution for scaling
    vec2 r = iResolution.xy,
    //Centered, ratio corrected, coordinates
    p = (gl_FragCoord.xy+gl_FragCoord.xy-r) / r.y,
    //Z depth
    z,
    //Iterator (x=0)
    i,
    //Fluid coordinates
    f = p*(z+=4.-4.*abs(.7-dot(p,p)));

    //Clear frag color and loop 8 times
    for(fragColor *= 0.; i.y++<8.;
    //Set color waves and line brightness
    fragColor += (sin(f)+1.).xyyx * abs(f.x-f.y))
    //Add fluid waves
    f += cos(f.yx*i.y+i+iTime)/i.y+.7;

    //Tonemap, fade edges and color gradient
    fragColor = tanh(7.*exp(z.x-4.-p.y*vec4(-1,1,2,0))/fragColor);
}