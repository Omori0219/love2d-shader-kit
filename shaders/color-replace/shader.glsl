// LÖVE Shader Kit — Color Replace
// SPDX-License-Identifier: MIT

extern vec4 sourceColor;
extern vec4 replacementColor;
extern float tolerance;
extern float softness;
extern float amount;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float colorDistance = distance(pixel.rgb, sourceColor.rgb * color.rgb);
    float matchAmount = 1.0 - smoothstep(tolerance, tolerance + max(softness, 0.0001), colorDistance);
    matchAmount *= clamp(amount, 0.0, 1.0) * replacementColor.a;
    pixel.rgb = mix(pixel.rgb, replacementColor.rgb * color.rgb, matchAmount);
    return pixel;
}
