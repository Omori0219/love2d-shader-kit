// LÖVE Shader Kit — Scanlines
// SPDX-License-Identifier: MIT

extern float time;
extern float spacing;
extern float strength;
extern float speed;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float phase = (screenCoords.y + time * speed * spacing) * 6.28318530718 / max(spacing, 0.001);
    float scan = 0.5 + 0.5 * sin(phase);
    pixel.rgb *= 1.0 - clamp(strength, 0.0, 1.0) * (1.0 - scan);
    return pixel;
}
