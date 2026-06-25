# Outline

![Outline preview](preview.png)

Samples neighboring alpha values and fills transparent pixels that touch the sprite. It is useful for selection highlights, readable pixel art, and interactable objects.

- **Category:** `sprite`
- **Target:** `sprite`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `texelSize` | `vec2` | `[0.0078125, 0.0078125]` | Reciprocal width and height of the source texture. |
| `outlineColor` | `vec4` | `[0.1059, 0.0863, 0.1804, 1.0]` | RGBA color of the outline. |
| `thickness` | `float` | `1.5` | Outline sampling distance in source pixels. |

## Notes

- Keep transparent padding around the sprite so the outline has room to render.
- Nearest filtering produces the crispest result for pixel art.

## Minimal usage

```lua
-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/outline/shader.glsl")

local function updateShader()
    shader:send("texelSize", {1 / image:getWidth(), 1 / image:getHeight()})
    shader:send("outlineColor", {0.1059, 0.0863, 0.1804, 1.0})
    shader:send("thickness", 1.5)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
```

The shader source is in [`shader.glsl`](shader.glsl).
