// LÖVE Shader Kit — Film Grain
// SPDX-License-Identifier: MIT

extern float time;
extern float amount;
extern float fps;

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float frame = floor(time * max(fps, 1.0));
    float noiseValue = hash21(screenCoords + vec2(frame * 17.0, frame * 31.0)) - 0.5;
    pixel.rgb = clamp(pixel.rgb + noiseValue * amount, 0.0, 1.0);
    return pixel;
}
