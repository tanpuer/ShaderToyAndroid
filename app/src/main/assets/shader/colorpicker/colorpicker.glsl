#version 300 es

precision highp float;
precision highp int;

uniform vec2 iResolution;
uniform float iTime;
uniform int iFrame;
uniform vec4 iMouse;
in vec2 vTextureCoord;
out vec4 fragColor;
//#iChannel0 "assets://shader/colorpicker/iChannel0.png"
uniform sampler2D iChannel0;

const struct Picker
{
    vec2  cen; // center
    float wid; // width
    float mar; // markers
}kPicker = Picker(vec2(-1.4,-0.65),0.25,0.03);

float c2d_to_h( vec2 p ) { return clamp(0.5+0.5*p.y/kPicker.wid,0.0,1.0); }
vec2  c2d_to_sv(vec2 p ) { return clamp(0.5+0.5*p/kPicker.wid,0.0,1.0); }
float sdBox( vec2 p, vec2 b ) { vec2 q = abs(p)-b; return min(max(q.x,q.y),0.0) + length(max(q,0.0)); }
vec3  hsv2rgb(  vec3 c ) { vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 ); return c.z * mix( vec3(1.0), rgb, c.y); }

vec4 picker_do( bool isFirstFrame, sampler2D sam, in vec4 mouse, in vec2 fragCoord, in vec2 resolution )
{
    vec2 p = (2.0*mouse.xy-resolution)/resolution.y - kPicker.cen;

    vec4 data = texelFetch(sam,ivec2(0,0),0);
    if( isFirstFrame ) data = vec4(0.15,0.7,0.9,0.0); // initial color

    if( mouse.w>0.0  ) // on mouse click
    {
        if( sdBox(p-vec2(kPicker.wid+kPicker.mar*2.0,0.0), vec2(kPicker.mar,kPicker.wid) )<0.0 ) data.w = 1.0;
        else if( sdBox(p, vec2(kPicker.wid) )<0.0 ) data.w = 2.0;
    }
    if( mouse.z>0.0 ) // on mouse down
    {
             if( abs(data.w-1.0)<0.5 ) data.x = c2d_to_h(p);
        else if( abs(data.w-2.0)<0.5 ) data.yz = c2d_to_sv(p);
    }
    else
    {
        data.w = 0.0;
    }

    return (ivec2(fragCoord)==ivec2(0,0)) ? data : vec4(0.0);
}

vec3 piker_draw( sampler2D sam, vec3 col, in vec2 fragCoord, in vec2 resolution )
{
    vec2 p = (2.0*fragCoord-resolution)/resolution.y - kPicker.cen;
    float px = 2.0/resolution.y;

    vec3 hsv = texelFetch(sam,ivec2(0,0),0).xyz;

    // color
    {
    const float kShadow = 256.0;
    float d1 = sdBox( p-vec2(kPicker.wid+kPicker.mar*2.0,0.0), vec2(kPicker.mar,kPicker.wid) );
    float d2 = sdBox( p, vec2(kPicker.wid) );
    float d = min(d1,d2);
    if( d>0.0) col *= 1.0-0.75/(1.0+kShadow*d);
    col = mix( col, hsv2rgb(vec3(c2d_to_h(p),1.0,1.0)), smoothstep(1.5*px,0.0,d1) );
    col = mix( col, hsv2rgb(vec3(hsv.x,c2d_to_sv(p))),  smoothstep(1.5*px,0.0,d2) );
    }
    // marks
    {
    //vec2 ce1 = kPicker.rad*vec2(cos(6.283185*hsv.x),sin(6.283185*hsv.x));
    vec2 ce1 = vec2(kPicker.wid+kPicker.mar*2.0,2.0*kPicker.wid*hsv.x-kPicker.wid);
    vec2 ce2 = 2.0*kPicker.wid*hsv.yz-kPicker.wid;
    float d = abs( min(length(p-ce1),length(p-ce2))-kPicker.mar)-kPicker.mar*0.3;
    col = mix( col, vec3(0.0), smoothstep(0.0,-1.5*px,d) );
    col = mix( col, vec3(1.0), smoothstep(-1.5*px,-3.0*px,d) );
    }

    return col;
}

vec3 picker_getRGB( sampler2D sam )
{
    return hsv2rgb( texelFetch(sam,ivec2(0,0),0).xyz );
}

void main()
{
    // get color form piker
	vec3 color = pow( picker_getRGB(iChannel0), vec3(2.2) );

    // camera
    vec2 p = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.y;
    const float flen = 2.0;
	vec3 ro = vec3(0.0, 0.0, 4.0 );
	vec3 rd = normalize( vec3(p,-flen) );

    // render background
    vec3 col = vec3(1.0);

    // render plane
    float t = (-1.0-ro.y)/rd.y;
    if( t>0.0 )
    {
        vec3  pos = ro + t*rd;
        float l2 = dot(pos,pos);
        float occ = 1.0+pos.y/(l2*sqrt(l2)); // https://iquilezles.org/articles/sphereao/
        col = occ*(occ+(1.0-occ)*color);
    }

    // render sphere
	float b = dot( ro, rd );
	float c = dot( ro, ro ) - 1.0;
	float h = b*b - c;
	if( h>0.0 )
    {
	    t = -b-sqrt(h);
        vec3  pos = ro + t*rd;
        vec3  nor = normalize(pos);
        float occ = 0.5+0.5*nor.y; // plane occlusion
        float d = 1.0-sqrt(max(0.0,1.0-h)); // https://iquilezles.org/articles/spherefunctions
        float al = clamp( 0.5*iResolution.y*flen*d/t, 0.0, 1.0 );
        col = mix(col,occ*mix(color,2.0*color*color,max(-nor.y,0.0)),al);
    }

    // gamma
    col = pow( col, vec3(0.4545) );

    // render color picker
    col = piker_draw( iChannel0, col, gl_FragCoord.xy, iResolution.xy );

    //vec4 fragColor1 = picker_do(iFrame==0, iChannel0, iMouse, gl_FragCoord.xy, iResolution.xy);
    fragColor = vec4( col, 1.0 );
}
