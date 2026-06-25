local Kit = require("love_shader_kit")

local App = {}
App.__index = App

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function roundToStep(value, step)
    if not step or step == 0 then
        return value
    end
    return math.floor(value / step + 0.5) * step
end

local function setColor(hex, alpha)
    local r = tonumber(hex:sub(2, 3), 16) / 255
    local g = tonumber(hex:sub(4, 5), 16) / 255
    local b = tonumber(hex:sub(6, 7), 16) / 255
    love.graphics.setColor(r, g, b, alpha or 1)
end

local function drawPanel(x, y, width, height, alpha)
    love.graphics.setColor(0.025, 0.027, 0.070, alpha or 0.9)
    love.graphics.rectangle("fill", x, y, width, height, 14, 14)
    love.graphics.setColor(1, 1, 1, 0.09)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, width - 1, height - 1, 14, 14)
end

function App.new()
    local self = setmetatable({}, App)
    love.graphics.setDefaultFilter("nearest", "nearest")

    self.catalog = Kit.list()
    self.index = 1
    self.controlIndex = 1
    self.elapsed = 0
    self.paused = false
    self.shaderCache = {}
    self.shaderErrors = {}
    self.values = {}

    self.titleFont = love.graphics.newFont(32)
    self.bodyFont = love.graphics.newFont(16)
    self.smallFont = love.graphics.newFont(13)
    self.monoFont = love.graphics.newFont(14)

    self.sprite = self:createSprite()
    self:resize(love.graphics.getDimensions())
    return self
end

function App:createSprite()
    local canvas = love.graphics.newCanvas(128, 128)
    canvas:setFilter("nearest", "nearest")

    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- Soft shadow inside the padded sprite canvas.
    love.graphics.setColor(0.08, 0.04, 0.18, 0.4)
    love.graphics.ellipse("fill", 64, 105, 35, 8)

    -- A small pixel-art robot built entirely from primitives.
    setColor("#1c1638")
    love.graphics.rectangle("fill", 36, 39, 56, 52, 8, 8)
    love.graphics.rectangle("fill", 43, 28, 42, 19, 5, 5)
    love.graphics.rectangle("fill", 31, 49, 8, 28, 3, 3)
    love.graphics.rectangle("fill", 89, 49, 8, 28, 3, 3)

    setColor("#3dd2e8")
    love.graphics.rectangle("fill", 40, 43, 48, 44, 6, 6)
    love.graphics.rectangle("fill", 47, 32, 34, 13, 3, 3)
    love.graphics.rectangle("fill", 34, 53, 7, 18, 2, 2)
    love.graphics.rectangle("fill", 87, 53, 7, 18, 2, 2)

    setColor("#7cf5e9")
    love.graphics.rectangle("fill", 45, 47, 38, 12, 3, 3)
    love.graphics.rectangle("fill", 49, 66, 30, 14, 3, 3)

    setColor("#ff5c93")
    love.graphics.rectangle("fill", 51, 50, 7, 6, 2, 2)
    love.graphics.rectangle("fill", 70, 50, 7, 6, 2, 2)
    love.graphics.rectangle("fill", 59, 70, 10, 6, 2, 2)

    setColor("#f8f2ff")
    love.graphics.rectangle("fill", 53, 51, 3, 3)
    love.graphics.rectangle("fill", 72, 51, 3, 3)

    setColor("#1c1638")
    love.graphics.rectangle("fill", 47, 88, 13, 12, 3, 3)
    love.graphics.rectangle("fill", 68, 88, 13, 12, 3, 3)
    love.graphics.rectangle("fill", 61, 22, 6, 10, 2, 2)

    setColor("#ffd166")
    love.graphics.circle("fill", 64, 21, 4)

    love.graphics.setCanvas()
    love.graphics.pop()
    return canvas
end

function App:resize(width, height)
    self.width = math.max(1, width)
    self.height = math.max(1, height)
    if self.scene then
        self.scene:release()
    end
    self.scene = love.graphics.newCanvas(self.width, self.height)
    self.scene:setFilter("linear", "linear")
end

function App:currentSpec()
    return self.catalog[self.index]
end

function App:currentControls()
    local controls = {}
    for _, uniform in ipairs(self:currentSpec().uniforms) do
        if uniform.control then
            controls[#controls + 1] = uniform
        end
    end
    return controls
end

function App:currentValues()
    local id = self:currentSpec().id
    self.values[id] = self.values[id] or {}
    return self.values[id]
end

function App:valueFor(uniform)
    local value = self:currentValues()[uniform.name]
    if value == nil then
        return uniform.default
    end
    return value
end

function App:shaderFor(spec)
    if self.shaderCache[spec.id] then
        return self.shaderCache[spec.id]
    end
    if self.shaderErrors[spec.id] then
        return nil
    end

    local ok, shaderOrError = pcall(love.graphics.newShader, spec.path)
    if not ok then
        self.shaderErrors[spec.id] = tostring(shaderOrError)
        return nil
    end

    self.shaderCache[spec.id] = shaderOrError
    return shaderOrError
end

function App:update(dt)
    if not self.paused then
        self.elapsed = self.elapsed + dt
    end
end

function App:drawScene()
    local width, height = self.width, self.height

    -- Sky gradient.
    local bands = 28
    for index = 0, bands - 1 do
        local t = index / (bands - 1)
        local r = 0.035 + 0.055 * t
        local g = 0.028 + 0.035 * t
        local b = 0.105 + 0.18 * t
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, height * index / bands, width, height / bands + 1)
    end

    -- Stars.
    for index = 1, 44 do
        local x = (index * 83 % 997) / 997 * width
        local y = (index * 47 % 389) / 389 * height * 0.58
        local pulse = 0.45 + 0.35 * math.sin(self.elapsed * 1.2 + index)
        love.graphics.setColor(0.68, 0.92, 1.0, pulse)
        love.graphics.circle("fill", x, y, index % 3 == 0 and 2 or 1)
    end

    -- Sun and glow.
    local sunX, sunY = width * 0.76, height * 0.28
    love.graphics.setColor(1.0, 0.34, 0.58, 0.08)
    love.graphics.circle("fill", sunX, sunY, height * 0.14)
    love.graphics.setColor(1.0, 0.38, 0.61, 0.95)
    love.graphics.circle("fill", sunX, sunY, height * 0.075)
    love.graphics.setColor(1.0, 0.74, 0.45, 0.85)
    love.graphics.circle("fill", sunX, sunY - height * 0.012, height * 0.057)

    -- Mountains.
    love.graphics.setColor(0.075, 0.055, 0.18, 1)
    love.graphics.polygon("fill", 0, height * 0.70, width * 0.18, height * 0.42, width * 0.34, height * 0.70)
    love.graphics.polygon("fill", width * 0.18, height * 0.70, width * 0.45, height * 0.34, width * 0.68, height * 0.70)
    love.graphics.polygon("fill", width * 0.52, height * 0.70, width * 0.78, height * 0.44, width, height * 0.70)

    love.graphics.setColor(0.10, 0.075, 0.24, 1)
    love.graphics.polygon("fill", 0, height * 0.76, width * 0.24, height * 0.52, width * 0.44, height * 0.76)
    love.graphics.polygon("fill", width * 0.35, height * 0.76, width * 0.63, height * 0.48, width * 0.90, height * 0.76)

    -- Perspective grid.
    love.graphics.setColor(0.24, 0.81, 0.91, 0.18)
    local horizon = height * 0.68
    for index = 0, 14 do
        local t = index / 14
        local y = horizon + (height - horizon) * t * t
        love.graphics.line(0, y, width, y)
    end
    for index = -12, 12 do
        local xBottom = width * 0.5 + index * width * 0.08
        love.graphics.line(width * 0.5, horizon, xBottom, height)
    end

    -- Moving light orbs make temporal effects easy to see.
    for index = 1, 5 do
        local phase = self.elapsed * (0.35 + index * 0.03) + index * 1.7
        local x = width * (0.5 + 0.36 * math.sin(phase))
        local y = height * (0.52 + 0.10 * math.cos(phase * 1.4))
        local radius = 12 + index * 3
        love.graphics.setColor(0.24, 0.83, 0.91, 0.08)
        love.graphics.circle("fill", x, y, radius * 2.4)
        love.graphics.setColor(0.45, 0.98, 0.91, 0.80)
        love.graphics.circle("fill", x, y, radius)
    end
end

function App:renderScene()
    love.graphics.push("all")
    love.graphics.setCanvas(self.scene)
    love.graphics.clear(0.02, 0.02, 0.06, 1)
    self:drawScene()
    love.graphics.setCanvas()
    love.graphics.pop()
end

function App:drawSpritePreview(shader, spec)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.scene, 0, 0)

    local scale = clamp(math.min(self.width, self.height) / 210, 2.6, 4.8)
    local size = 128 * scale
    local x = (self.width - size) / 2
    local y = (self.height - size) / 2 + 10

    love.graphics.setColor(0.02, 0.02, 0.06, 0.62)
    love.graphics.rectangle("fill", x - 24, y - 22, size + 48, size + 46, 22, 22)
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("line", x - 24, y - 22, size + 48, size + 46, 22, 22)

    if shader then
        Kit.send(shader, spec, self:currentValues(), {source = self.sprite, time = self.elapsed})
        love.graphics.setShader(shader)
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprite, x, y, 0, scale, scale)
    love.graphics.setShader()
end

function App:drawScreenPreview(shader, spec)
    if shader then
        Kit.send(shader, spec, self:currentValues(), {source = self.scene, time = self.elapsed})
        love.graphics.setShader(shader)
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.scene, 0, 0)
    love.graphics.setShader()
end

function App:drawError(message)
    local margin = 70
    drawPanel(margin, self.height * 0.28, self.width - margin * 2, self.height * 0.38, 0.96)
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1.0, 0.38, 0.48, 1)
    love.graphics.print("Shader compilation failed", margin + 28, self.height * 0.28 + 24)
    love.graphics.setFont(self.monoFont)
    love.graphics.setColor(1, 1, 1, 0.78)
    love.graphics.printf(message, margin + 28, self.height * 0.28 + 76, self.width - margin * 2 - 56)
end

function App:drawInterface()
    local spec = self:currentSpec()
    local controls = self:currentControls()
    local topX, topY = 30, 28
    local topWidth = math.min(self.width - 60, 760)
    drawPanel(topX, topY, topWidth, 124, 0.88)

    love.graphics.setFont(self.smallFont)
    setColor("#7cf5e9")
    love.graphics.print(string.upper(spec.category), topX + 24, topY + 18)
    love.graphics.setColor(1, 1, 1, 0.45)
    love.graphics.printf(string.format("%02d / %02d", self.index, #self.catalog), topX + topWidth - 110, topY + 18, 86, "right")

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 1, 1, 0.96)
    love.graphics.print(spec.name, topX + 24, topY + 38)

    love.graphics.setFont(self.bodyFont)
    love.graphics.setColor(1, 1, 1, 0.66)
    love.graphics.printf(spec.summary, topX + 24, topY + 82, topWidth - 48)

    local bottomHeight = 116
    local bottomY = self.height - bottomHeight - 26
    drawPanel(30, bottomY, self.width - 60, bottomHeight, 0.90)

    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(1, 1, 1, 0.48)
    love.graphics.print("LEFT / RIGHT  shader     UP / DOWN  parameter     A / D or wheel  adjust     R  reset     SPACE  pause", 54, bottomY + 20)

    if #controls > 0 then
        self.controlIndex = clamp(self.controlIndex, 1, #controls)
        local uniform = controls[self.controlIndex]
        local control = uniform.control
        local value = self:valueFor(uniform)
        local normalized = (value - control.min) / math.max(control.max - control.min, 0.0001)

        love.graphics.setFont(self.bodyFont)
        love.graphics.setColor(1, 1, 1, 0.92)
        love.graphics.print(uniform.name, 54, bottomY + 53)
        love.graphics.setFont(self.monoFont)
        setColor("#ffd166")
        love.graphics.printf(string.format("%.3g", value), 218, bottomY + 54, 90, "right")

        local barX, barY, barWidth = 332, bottomY + 61, math.max(120, self.width - 440)
        love.graphics.setColor(1, 1, 1, 0.12)
        love.graphics.rectangle("fill", barX, barY, barWidth, 7, 4, 4)
        setColor("#3dd2e8")
        love.graphics.rectangle("fill", barX, barY, barWidth * clamp(normalized, 0, 1), 7, 4, 4)
        love.graphics.circle("fill", barX + barWidth * clamp(normalized, 0, 1), barY + 3.5, 6)

        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(1, 1, 1, 0.42)
        love.graphics.printf(string.format("parameter %d / %d", self.controlIndex, #controls), 54, bottomY + 83, self.width - 108, "right")
    end

    if self.paused then
        love.graphics.setFont(self.smallFont)
        setColor("#ffd166")
        love.graphics.print("PAUSED", self.width - 100, 36)
    end
end

function App:draw()
    self:renderScene()
    local spec = self:currentSpec()
    local shader = self:shaderFor(spec)

    love.graphics.push("all")
    if spec.target == "sprite" then
        self:drawSpritePreview(shader, spec)
    else
        self:drawScreenPreview(shader, spec)
    end
    love.graphics.pop()

    if self.shaderErrors[spec.id] then
        self:drawError(self.shaderErrors[spec.id])
    end
    self:drawInterface()
end

function App:cycle(delta)
    self.index = ((self.index - 1 + delta) % #self.catalog) + 1
    self.controlIndex = 1
end

function App:selectControl(delta)
    local controls = self:currentControls()
    if #controls == 0 then
        return
    end
    self.controlIndex = ((self.controlIndex - 1 + delta) % #controls) + 1
end

function App:adjust(delta)
    local controls = self:currentControls()
    if #controls == 0 then
        return
    end

    local uniform = controls[self.controlIndex]
    local control = uniform.control
    local value = self:valueFor(uniform)
    value = value + delta * control.step
    value = roundToStep(value, control.step)
    self:currentValues()[uniform.name] = clamp(value, control.min, control.max)
end

function App:keypressed(key, scancode, isRepeat)
    if isRepeat and key ~= "a" and key ~= "d" and key ~= "[" and key ~= "]" then
        return
    end

    if key == "right" then
        self:cycle(1)
    elseif key == "left" then
        self:cycle(-1)
    elseif key == "down" then
        self:selectControl(1)
    elseif key == "up" then
        self:selectControl(-1)
    elseif key == "d" or key == "]" or key == "=" then
        self:adjust(1)
    elseif key == "a" or key == "[" or key == "-" then
        self:adjust(-1)
    elseif key == "r" then
        self.values[self:currentSpec().id] = {}
    elseif key == "space" then
        self.paused = not self.paused
    elseif key == "escape" then
        love.event.quit()
    end
end

function App:wheelmoved(x, y)
    if y ~= 0 then
        self:adjust(y > 0 and 1 or -1)
    end
end

return App
