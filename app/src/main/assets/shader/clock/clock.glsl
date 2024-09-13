#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
in vec2 vTextureCoord;
out vec4 fragColor;
uniform vec4 iDate;

// this is my first try to actually use glsl almost from scratch
// so far all i've done is learning by doing / reading glsl docs.
// this is inspired by my non glsl â€žtimeâ€œ projects
// especially this one: https://www.gottz.de/analoguhr.htm

// i will most likely use a buffer in future to calculate the time
// aswell as to draw the background of the clock only once.
// tell me if thats a bad idea.

// update:
// screenshot: http://i.imgur.com/dF0nHDk.png
// as soon as i think its in a usefull state i'll release the source
// of that particular c++ application on github.
// i hope sommeone might find it usefull :D

#define PI 3.141592653589793238462643383

// from https://www.shadertoy.com/view/4s3XDn <3
float ln(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// i think i should spend some time reading docs in order to minimize this.
// hints apreciated
// (Rotated LiNe)
float rln(vec2 uv, float start, float end, float perc) {
    float inp = perc * PI * 2.0;
	vec2 coord = vec2(sin(inp), cos(inp));
    return ln(uv, coord * start, coord * end);
}

// i need this to have an alphachannel in the output
// i intend to use an optimized version of this shader for a transparent desktop widget experiment
vec4 mixer(vec4 c1, vec4 c2) {
    // please tell me if you think this would boost performance.
    // the time i implemented mix myself it sure did reduce
    // the amount of operations but i'm not sure now
    // if (c2.a <= 0.0) return c1;
    // if (c2.a >= 1.0) return c2;
    return vec4(mix(c1.rgb, c2.rgb, c2.a), c1.a + c2.a);
    // in case you are curious how you could implement mix yourself:
    // return vec4(c2.rgb * c2.a + c1.rgb * (1.0-c2.a), c1.a+c2.a);
}

vec4 styleHandle(vec4 color, float px, float dist, vec3 handleColor, float width, float shadow) {
    if (dist <= width + shadow) {
        // lets draw the shadow
        color = mixer(color, vec4(0.0, 0.0, 0.0,
                                (1.0-pow(smoothstep(width, width + shadow, dist),0.2))*0.2));
        // now lets draw the antialiased handle
        color = mixer(color, vec4(handleColor, smoothstep(width, max(width - 3.0 * px, 0.0), dist)));
    }
    return color;
}

void main()
{
    vec2 R = iResolution.xy;
    // calculate the size of a pixel
    float px = 1.0 / R.y;
    // create percentages of the coordinate system
    vec2 p = gl_FragCoord.xy / R;
    // center the scene and add perspective
    vec2 uv = (2.0 * gl_FragCoord.xy - R) / min(R.x, R.y);

    /*vec2 uv = -1.0 + 2.0 * p.xy;
    // lets add perspective for mobile device support
    if (iResolution.x > iResolution.y)
    	uv.x *= iResolution.x / iResolution.y;
    else
        uv.y *= iResolution.y / iResolution.x;*/

    // lets scale the scene a bit down:
    uv *= 1.1;
    px *= 0.9;

    float width = 0.015;
    float dist = 1.0;
    float centerdist = length(uv);

    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

    // background of the clock
    if (centerdist < 1.0 - width) color = mixer(color, vec4(vec3(0.5), 0.4*(1.8-length(uv))));

    float isRed = 1.0;

    if (centerdist > 1.0 - 12.0 * width && centerdist <= 1.1) {
        // minute bars
        for (float i = 0.0; i <= 15.0; i += 1.0) {
            if (mod(i, 5.0) == 0.0) {
                dist = min(dist, rln(abs(uv), 1.0 - 10.0 * width, 1.0 - 2.0 * width, i / 60.0));
                // draw first bar red
                if (i == 0.0 && uv.y > 0.0) {
                    isRed = dist;
                    dist = smoothstep(width, max(width - 3.0 * px, 0.0), dist);
                    color = mixer(color, vec4(1.0, 0.0, 0.0, dist));
                    dist = 1.0;
                }
            }
            else {
                dist = min(dist, rln(abs(uv), 1.0 - 10.0 * width, 1.0 - 7.0 * width, i / 60.0));
            }
        }

        // outline circle
        dist = min(dist, abs(1.0-width-length(uv)));
        // draw clock shadow
        if (centerdist > 1.0)
            color = mixer(color, vec4(0.0,0.0,0.0, 0.3*smoothstep(1.0 + width*2.0, 1.0, centerdist)));

        // draw outline + minute bars in white
		color = mixer(color, vec4(0.0, 0.0, 0.0,
			(1.0 - pow(smoothstep(width, width + 0.02, min(isRed, dist)), 0.4))*0.2));
		color = mixer(color, vec4(vec3(1.0), smoothstep(width, max(width - 3.0 * px, 0.0), dist)));
    }

    if (centerdist < 1.0) {
        float time = (floor(iDate.w)+pow(fract(iDate.w),16.0));

        // hour
        color = styleHandle(color, px,
                            rln(uv, -0.05, 0.5, time / 3600.0 / 12.0),
                            vec3(1.0), 0.03, 0.02);

        // minute
        color = styleHandle(color, px,
                            rln(uv, -0.075, 0.7, time / 3600.0),
                            vec3(1.0), 0.02, 0.02);

        // second
        color = styleHandle(color, px,
                            min(rln(uv, -0.1, 0.9, time / 60.0), length(uv)-0.01),
                            vec3(1.0, 0.0, 0.0), 0.01, 0.02);
    }


    fragColor = color;
}