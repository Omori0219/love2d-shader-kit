# Scanlines

![Scanlines preview](preview.png)

Modulates brightness with a screen-space sine wave and a subtle moving phase. It can be used alone or layered with other post-processing for retro display effects.

- **Category:** `screen`
- **Target:** `screen`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `time` | `float` | `0.0` | Animation time in seconds. |
| `spacing` | `float` | `3.0` | Distance between scanline peaks in screen pixels. |
| `strength` | `float` | `0.28` | Maximum brightness reduction. |
| `speed` | `float` | `1.3` | Vertical phase animation speed. |

## Minimal usage

```lua
-- Draw your scene to a Canvas first.
local canvas = love.graphics.newCanvas()

local function drawScene()
    -- Draw the game world here.
end

local shader = love.graphics.newShader("shaders/scanlines/shader.glsl")

local function updateShader()
    shader:send("time", love.timer.getTime())
    shader:send("spacing", 3.0)
    shader:send("strength", 0.28)
    shader:send("speed", 1.3)
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
