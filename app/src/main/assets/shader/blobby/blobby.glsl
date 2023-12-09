#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
in vec2 vTextureCoord;
out vec4 fragColor;

const float PI = 3.14159;

#ifndef saturate
#define saturate(x) (clamp(x, 0., 1.))
#endif

vec2 rotate(vec2 p, float t)
{
    return mat2(cos(t), -sin(t), sin(t), cos(t)) * p;
}

float blob(vec2 pos, vec2 center, float power)
{
    vec2 d = saturate(pow(pos - center, vec2(power)));
    return 1. / abs(d.x + d.y);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = (uv - .5) * 2.0;
    vec2 aspect_uv = uv * vec2(iResolution.x / iResolution.y, 1.0);

    float blobs = 0.8 * blob(aspect_uv, vec2(0.), 2.);

    float phi = 0.;

    const int N = 7;

    for (int i = 0; i < N; ++i)
    {
        blobs += 0.0001 * blob(rotate(aspect_uv, phi),
                               vec2(sin(iTime + phi) * 0.64, 0.),
                               4.);

        blobs += 0.001 * blob(rotate(aspect_uv, phi),
                              vec2(-sin(iTime + phi + 5. * PI / 6.) * 0.50, 0.),
                              2.);
        phi += PI / float(N);
    }

    float x = smoothstep(3., 6., blobs);
    float y = smoothstep(3., 5., blobs);
    float z = smoothstep(3., 8., blobs);

    fragColor = vec4(20.1, 2., 2.1, 5.) - vec4(x * vec3(1., 0.5, 0.5) +
    y * vec3(2.5, 1., 0.5) +
    z * vec3(.5, 0.5, 1.), 1.);


    fragColor = vec4((1. - vec3(pow(length(uv * 0.4), 1.5))) * vec3(0.9, 1.0, 0.9),
                     1.) * saturate(pow(fragColor, vec4(2.7)));
}