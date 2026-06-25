-- Assume `image` is a loaded love.graphics.Image.

local shader = love.graphics.newShader("shaders/silhouette/shader.glsl")

local function updateShader()
    shader:send("silhouetteColor", {0.15, 0.07, 0.3, 0.88})
    shader:send("amount", 1.0)
end

function love.draw()
    updateShader()
    love.graphics.setShader(shader)
    love.graphics.draw(image, 100, 100)
    love.graphics.setShader()
end
