// LÖVE Shader Kit — Dissolve
// SPDX-License-Identifier: MIT

extern float time;
extern float progress;
extern float noiseScale;
extern float softness;
extern float edgeWidth;
extern vec4 edgeColor;

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float valueNoise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float noiseValue = valueNoise(textureCoords * noiseScale + vec2(time * 0.12, -time * 0.08));
    float threshold = mix(-softness, 1.0 + softness, clamp(progress, 0.0, 1.0));
    float visible = smoothstep(threshold - softness, threshold + softness, noiseValue);
    float edge = 1.0 - smoothstep(0.0, max(edgeWidth, 0.0001), abs(noiseValue - threshold));
    edge *= step(threshold, noiseValue) * edgeColor.a;

    pixel.rgb = mix(pixel.rgb, edgeColor.rgb * color.rgb, edge);
    pixel.a *= visible;
    return pixel;
}
