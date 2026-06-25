# Wave

![Wave preview](preview.png)

Offsets texture coordinates with sine and cosine waves. The amplitude is expressed in source pixels, so the effect remains predictable across texture sizes.

- **Category:** `sprite`
- **Target:** `sprite`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `texelSize` | `vec2` | `[0.0078125, 0.0078125]` | Reciprocal width and height of the source texture. |
| `time` | `float` | `0.0` | Animation time in seconds. |
| `amplitude` | `float` | `3.0` | Maximum displacement in source pixels. |
| `frequency` | `float` | `18.0` | Number of wave oscillations across the texture. |
| `speed` | `float` | `2.2` | Animation speed. |

## Minimal usage

```lua
-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/wave/shader.glsl")

local function updateShader()
    shader:send("texelSize", {1 / image:getWidth(), 1 / image:getHeight()})
    shader:send("time", love.timer.getTime())
    shader:send("amplitude", 3.0)
    shader:send("frequency", 18.0)
    shader:send("speed", 2.2)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
```

The shader source is in [`shader.glsl`](shader.glsl).
