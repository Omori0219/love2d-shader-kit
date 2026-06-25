// LÖVE Shader Kit — Silhouette
// SPDX-License-Identifier: MIT

extern vec4 silhouetteColor;
extern float amount;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float blendAmount = clamp(amount, 0.0, 1.0) * silhouetteColor.a;
    pixel.rgb = mix(pixel.rgb, silhouetteColor.rgb * color.rgb, blendAmount);
    return pixel;
}
