// LÖVE Shader Kit — Pixelate
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float pixelSize;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec2 cell = texelSize * max(pixelSize, 1.0);
    vec2 uv = (floor(textureCoords / cell) + 0.5) * cell;
    return Texel(tex, uv) * color;
}
