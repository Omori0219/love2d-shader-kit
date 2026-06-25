// LÖVE Shader Kit — CRT
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float curvature;
extern float scanlineStrength;
extern float rgbOffset;
extern float vignetteStrength;

vec2 curveUv(vec2 uv)
{
    vec2 centered = uv * 2.0 - 1.0;
    float distortion = dot(centered, centered) * curvature;
    centered *= 1.0 + distortion;
    return centered * 0.5 + 0.5;
}

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec2 uv = curveUv(textureCoords);
    if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
        return vec4(0.015, 0.008, 0.025, 1.0) * color;
    }

    vec2 channelOffset = vec2(texelSize.x * rgbOffset, 0.0);
    vec4 center = Texel(tex, uv);
    float red = Texel(tex, uv + channelOffset).r;
    float blue = Texel(tex, uv - channelOffset).b;
    vec4 pixel = vec4(red, center.g, blue, center.a) * color;

    float scan = 0.5 + 0.5 * sin(screenCoords.y * 3.14159265359);
    pixel.rgb *= 1.0 - scanlineStrength * (1.0 - scan);

    vec2 edge = uv * (1.0 - uv);
    float vignette = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), 0.22);
    pixel.rgb *= mix(1.0, vignette, clamp(vignetteStrength, 0.0, 1.0));
    return pixel;
}
