// LÖVE Shader Kit — Radial Wipe
// SPDX-License-Identifier: MIT

extern float progress;
extern float softness;
extern float edgeWidth;
extern vec2 center;
extern vec4 edgeColor;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 pixel = Texel(tex, textureCoords) * color;
    float maxDistance = max(max(length(center), length(vec2(1.0, 0.0) - center)),
                            max(length(vec2(0.0, 1.0) - center), length(vec2(1.0) - center)));
    float radialDistance = length(textureCoords - center) / max(maxDistance, 0.0001);
    float boundary = clamp(progress, 0.0, 1.0);
    float visible = 1.0 - smoothstep(boundary, boundary + max(softness, 0.0001), radialDistance);
    float edge = 1.0 - smoothstep(edgeWidth, edgeWidth + max(softness, 0.0001), abs(radialDistance - boundary));
    edge *= visible * edgeColor.a;

    pixel.rgb = mix(pixel.rgb, edgeColor.rgb, edge);
    pixel.a *= visible;
    return pixel;
}
