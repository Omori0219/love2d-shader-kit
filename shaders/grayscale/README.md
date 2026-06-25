# Grayscale

![Grayscale preview](preview.png)

Uses Rec. 709 luminance weights and an adjustable blend amount. It is useful for pause states, disabled UI, flashbacks, and selective mood changes.

- **Category:** `color`
- **Target:** `screen`
- **Passes:** `1`
- **LÖVE:** `11.5`
- **License:** `MIT`

## Uniforms

| Name | Type | Default | Description |
|---|---|---|---|
| `amount` | `float` | `1.0` | Blend amount from full color to grayscale. |

## Minimal usage

```lua
-- Draw your scene to a Canvas first.
local canvas = love.graphics.newCanvas()

local function drawScene()
    -- Draw the game world here.
end

local shader = love.graphics.newShader("shaders/grayscale/shader.glsl")

local function updateShader()
    shader:send("amount", 1.0)
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
