local catalog = require("shader_catalog")

local Kit = {}
local byId = {}

for _, spec in ipairs(catalog) do
    byId[spec.id] = spec
end

local function copyValue(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = copyValue(item)
    end
    return result
end

local function dimensions(source)
    if source and source.getDimensions then
        return source:getDimensions()
    end
    return nil, nil
end

local function resolveValue(uniform, context)
    context = context or {}

    if uniform.source == "time" then
        return context.time or love.timer.getTime()
    end

    if uniform.source == "texture_texel_size" then
        local width, height = dimensions(context.source)
        if width and height and width > 0 and height > 0 then
            return {1 / width, 1 / height}
        end
    end

    if uniform.source == "texture_aspect" then
        local width, height = dimensions(context.source)
        if width and height and height > 0 then
            return width / height
        end
    end

    return copyValue(uniform.default)
end

function Kit.list()
    return catalog
end

function Kit.get(id)
    return byId[id]
end

function Kit.load(id)
    local spec = assert(byId[id], "Unknown shader: " .. tostring(id))
    return love.graphics.newShader(spec.path), spec
end

function Kit.defaults(id)
    local spec = assert(byId[id], "Unknown shader: " .. tostring(id))
    local values = {}
    for _, uniform in ipairs(spec.uniforms) do
        if not uniform.source then
            values[uniform.name] = copyValue(uniform.default)
        end
    end
    return values
end

function Kit.send(shader, specOrId, overrides, context)
    local spec = type(specOrId) == "table" and specOrId or byId[specOrId]
    assert(spec, "Unknown shader: " .. tostring(specOrId))
    overrides = overrides or {}

    for _, uniform in ipairs(spec.uniforms) do
        local value = overrides[uniform.name]
        if value == nil then
            value = resolveValue(uniform, context)
        end

        if value ~= nil and shader:hasUniform(uniform.name) then
            shader:send(uniform.name, value)
        end
    end
end

return Kit
