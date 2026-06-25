// LÖVE Shader Kit — Outline
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern vec4 outlineColor;
extern float thickness;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 base = Texel(tex, textureCoords) * color;
    if (base.a > 0.001) {
        return base;
    }

    vec2 offset = texelSize * max(thickness, 0.0);
    float alpha = 0.0;
    alpha = max(alpha, Texel(tex, textureCoords + vec2( offset.x, 0.0)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2(-offset.x, 0.0)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2(0.0,  offset.y)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2(0.0, -offset.y)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2( offset.x,  offset.y)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2(-offset.x,  offset.y)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2( offset.x, -offset.y)).a);
    alpha = max(alpha, Texel(tex, textureCoords + vec2(-offset.x, -offset.y)).a);

    return vec4(outlineColor.rgb * color.rgb, alpha * outlineColor.a * color.a);
}
