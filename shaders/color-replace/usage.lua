-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/color-replace/shader.glsl")

local function updateShader()
    shader:send("sourceColor", {0.2392, 0.8235, 0.9098, 1.0})
    shader:send("replacementColor", {1.0, 0.35, 0.6, 1.0})
    shader:send("tolerance", 0.22)
    shader:send("softness", 0.08)
    shader:send("amount", 1.0)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
