-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/dissolve/shader.glsl")

local function updateShader()
    shader:send("time", love.timer.getTime())
    shader:send("progress", 0.48)
    shader:send("noiseScale", 9.0)
    shader:send("softness", 0.035)
    shader:send("edgeWidth", 0.1)
    shader:send("edgeColor", {0.35, 0.95, 1.0, 1.0})
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
