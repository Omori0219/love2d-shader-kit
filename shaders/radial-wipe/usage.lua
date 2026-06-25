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
