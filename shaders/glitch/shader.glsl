// LÖVE Shader Kit — Glitch
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float time;
extern float amount;
extern float blockCount;
extern float speed;
extern float rgbOffset;

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    float frame = floor(time * max(speed, 0.001));
    float band = floor(textureCoords.y * max(blockCount, 1.0));
    float randomValue = hash21(vec2(band, frame));
    float glitchBandMask = step(1.0 - clamp(amount, 0.0, 1.0), randomValue);
    float shift = (hash21(vec2(band + 17.0, frame + 9.0)) - 0.5) * 0.16 * amount * glitchBandMask;
    vec2 shiftedUv = clamp(textureCoords + vec2(shift, 0.0), vec2(0.0), vec2(1.0));
    vec2 channelOffset = vec2(texelSize.x * rgbOffset * (0.35 + glitchBandMask), 0.0);

    float red = Texel(tex, clamp(shiftedUv + channelOffset, vec2(0.0), vec2(1.0))).r;
    vec4 center = Texel(tex, shiftedUv);
    float blue = Texel(tex, clamp(shiftedUv - channelOffset, vec2(0.0), vec2(1.0))).b;
    return vec4(red, center.g, blue, center.a) * color;
}
