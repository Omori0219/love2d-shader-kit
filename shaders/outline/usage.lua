-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/outline/shader.glsl")

local function updateShader()
    shader:send("texelSize", {1 / image:getWidth(), 1 / image:getHeight()})
    shader:send("outlineColor", {0.1059, 0.0863, 0.1804, 1.0})
    shader:send("thickness", 1.5)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
