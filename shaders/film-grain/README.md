# Film Grain

![Film Grain preview](preview.png)

Generates deterministic screen-space noise at a configurable frame rate and applies it as luminance variation. The effect requires no noise texture.

- **Category:** `screen`
- **Target:** `screen`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `time` | `float` | `0.0` | Animation time in seconds. |
| `amount` | `float` | `0.1` | Maximum grain amplitude. |
| `fps` | `float` | `18.0` | Rate at which the noise pattern changes. |

## Minimal usage

```lua
-- Draw your scene to a Canvas first.
local canvas = love.graphics.newCanvas()

local function drawScene()
    -- Draw the game world here.
end

local shader = love.graphics.newShader("shaders/film-grain/shader.glsl")

local function updateShader()
    shader:send("time", love.timer.getTime())
    shader:send("amount", 0.1)
    shader:send("fps", 18.0)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    drawScene()
    love.graphics.setCanvas()

    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end
```

The shader source is in [`shader.glsl`](shader.glsl).
