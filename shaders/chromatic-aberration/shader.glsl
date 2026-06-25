// LÖVE Shader Kit — Chromatic Aberration
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float amount;
extern vec2 direction;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec2 offset = direction * texelSize * amount;
    vec4 center = Texel(tex, textureCoords);
    float red = Texel(tex, textureCoords + offset).r;
    float blue = Texel(tex, textureCoords - offset).b;
    return vec4(red, center.g, blue, center.a) * color;
}
