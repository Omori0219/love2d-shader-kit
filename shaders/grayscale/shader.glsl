// LÖVE Shader Kit — Grayscale
// SPDX-License-Identifier: MIT

extern float amount;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float luminance = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
    pixel.rgb = mix(pixel.rgb, vec3(luminance), clamp(amount, 0.0, 1.0));
    return pixel;
}
