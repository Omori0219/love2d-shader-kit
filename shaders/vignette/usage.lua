-- Draw your scene to a Canvas first.
local canvas = love.graphics.newCanvas()

local function drawScene()
    -- Draw the game world here.
end

local shader = love.graphics.newShader("shaders/vignette/shader.glsl")

local function updateShader()
    shader:send("aspect", canvas:getWidth() / canvas:getHeight())
    shader:send("radius", 0.68)
    shader:send("softness", 0.38)
    shader:send("intensity", 0.72)
    shader:send("vignetteColor", {0.0353, 0.0196, 0.0902, 1.0})
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
