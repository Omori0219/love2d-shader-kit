// LÖVE Shader Kit — Bloom
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float threshold;
extern float intensity;
extern float radius;

vec3 brightPart(vec4 sampleColor)
{
    float luminance = dot(sampleColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    float contribution = smoothstep(threshold, 1.0, luminance);
    return sampleColor.rgb * contribution * sampleColor.a;
}

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 base = Texel(tex, textureCoords);
    vec2 offset = texelSize * radius;
    vec3 glow = vec3(0.0);

    glow += brightPart(Texel(tex, textureCoords + vec2( offset.x, 0.0))) * 0.16;
    glow += brightPart(Texel(tex, textureCoords + vec2(-offset.x, 0.0))) * 0.16;
    glow += brightPart(Texel(tex, textureCoords + vec2(0.0,  offset.y))) * 0.16;
    glow += brightPart(Texel(tex, textureCoords + vec2(0.0, -offset.y))) * 0.16;
    glow += brightPart(Texel(tex, textureCoords + vec2( offset.x,  offset.y))) * 0.09;
    glow += brightPart(Texel(tex, textureCoords + vec2(-offset.x,  offset.y))) * 0.09;
    glow += brightPart(Texel(tex, textureCoords + vec2( offset.x, -offset.y))) * 0.09;
    glow += brightPart(Texel(tex, textureCoords + vec2(-offset.x, -offset.y))) * 0.09;

    base.rgb += glow * intensity;
    return base * color;
}
