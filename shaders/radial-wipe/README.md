# Radial Wipe

![Radial Wipe preview](preview.png)

Masks the source by normalized radial distance and optionally colors the moving edge. It is a compact scene transition that requires only one Canvas.

- **Category:** `transition`
- **Target:** `screen`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `progress` | `float` | `0.62` | Reveal progress from 0 to 1. |
| `softness` | `float` | `0.025` | Softness of the reveal boundary. |
| `edgeWidth` | `float` | `0.06` | Width of the colored transition edge. |
| `center` | `vec2` | `[0.5, 0.5]` | Normalized center of the radial reveal. |
| `edgeColor` | `vec4` | `[0.4, 0.96, 1.0, 1.0]` | RGBA color of the moving edge. |

## Minimal usage

```lua
-- Draw your scene to a Canvas first.
local canvas = love.graphics.newCanvas()

local function drawScene()
    -- Draw the game world here.
end

local shader = love.graphics.newShader("shaders/radial-wipe/shader.glsl")

local function updateShader()
    shader:send("progress", 0.62)
    shader:send("softness", 0.025)
    shader:send("edgeWidth", 0.06)
    shader:send("center", {0.5, 0.5})
    shader:send("edgeColor", {0.4, 0.96, 1.0, 1.0})
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
