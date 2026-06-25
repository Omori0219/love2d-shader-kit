// LÖVE Shader Kit — Vignette
// SPDX-License-Identifier: MIT

extern float aspect;
extern float radius;
extern float softness;
extern float intensity;
extern vec4 vignetteColor;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    vec2 centered = textureCoords - vec2(0.5);
    centered.x *= aspect;
    float distanceFromCenter = length(centered);
    float mask = smoothstep(radius, radius + max(softness, 0.0001), distanceFromCenter);
    float blendAmount = mask * clamp(intensity, 0.0, 1.0) * vignetteColor.a;
    pixel.rgb = mix(pixel.rgb, vignetteColor.rgb, blendAmount);
    return pixel;
}
