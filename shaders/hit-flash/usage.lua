-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/hit-flash/shader.glsl")

local function updateShader()
    shader:send("flashColor", {1.0, 0.94, 0.72, 1.0})
    shader:send("amount", 0.78)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
