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
