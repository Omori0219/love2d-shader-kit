// LÖVE Shader Kit — Directional Blur
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern vec2 direction;
extern float radius;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec2 safeDirection = direction;
    float directionLength = length(safeDirection);
    if (directionLength > 0.0001) {
        safeDirection /= directionLength;
    }
    vec2 stepOffset = safeDirection * texelSize * radius;

    vec4 sum = Texel(tex, textureCoords) * 0.2270270270;
    sum += Texel(tex, textureCoords + stepOffset * 0.25) * 0.1945945946;
    sum += Texel(tex, textureCoords - stepOffset * 0.25) * 0.1945945946;
    sum += Texel(tex, textureCoords + stepOffset * 0.50) * 0.1216216216;
    sum += Texel(tex, textureCoords - stepOffset * 0.50) * 0.1216216216;
    sum += Texel(tex, textureCoords + stepOffset * 0.75) * 0.0540540541;
    sum += Texel(tex, textureCoords - stepOffset * 0.75) * 0.0540540541;
    sum += Texel(tex, textureCoords + stepOffset) * 0.0162162162;
    sum += Texel(tex, textureCoords - stepOffset) * 0.0162162162;
    return sum * color;
}
