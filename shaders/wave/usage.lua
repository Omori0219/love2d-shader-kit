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
