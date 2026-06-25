// LÖVE Shader Kit — Hit Flash
// SPDX-License-Identifier: MIT

extern vec4 flashColor;
extern float amount;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float blendAmount = clamp(amount, 0.0, 1.0) * flashColor.a;
    pixel.rgb = mix(pixel.rgb, flashColor.rgb * color.rgb, blendAmount);
    return pixel;
}
