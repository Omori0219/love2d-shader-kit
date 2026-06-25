// LÖVE Shader Kit — Wave
// SPDX-License-Identifier: MIT

extern vec2 texelSize;
extern float time;
extern float amplitude;
extern float frequency;
extern float speed;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec2 displacement;
    displacement.x = sin(textureCoords.y * frequency + time * speed);
    displacement.y = cos(textureCoords.x * frequency * 0.73 + time * speed * 0.81);
    vec2 uv = textureCoords + displacement * texelSize * amplitude;

    if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
        return vec4(0.0);
    }
    return Texel(tex, uv) * color;
}
