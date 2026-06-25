// LÖVE Shader Kit — Posterize
// SPDX-License-Identifier: MIT

extern float levels;
extern float amount;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float safeLevels = max(floor(levels + 0.5), 2.0);
    vec3 quantized = floor(pixel.rgb * (safeLevels - 1.0) + 0.5) / (safeLevels - 1.0);
    pixel.rgb = mix(pixel.rgb, quantized, clamp(amount, 0.0, 1.0));
    return pixel;
}
