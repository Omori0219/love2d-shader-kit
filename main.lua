local validateOnly = os.getenv("LOVE_SHADER_KIT_VALIDATE") == "1"

if validateOnly then
    function love.load()
        local kit = require("love_shader_kit")
        local failures = {}

        for _, spec in ipairs(kit.list()) do
            local ok, result = pcall(love.graphics.newShader, spec.path)
            if ok then
                result:release()
                print("ok  " .. spec.id)
            else
                failures[#failures + 1] = spec.id .. ": " .. tostring(result)
            end
        end

        if #failures > 0 then
            io.stderr:write(table.concat(failures, "\n") .. "\n")
            os.exit(1)
        end

        local major, minor, revision = love.getVersion()
        print(string.format("Compiled %d shaders with LÖVE %d.%d.%d", #kit.list(), major, minor, revision))
        os.exit(0)
    end
else
    local Demo = require("demo.app")
    local app

    function love.load()
        app = Demo.new()
    end

    function love.update(dt)
        app:update(dt)
    end

    function love.draw()
        app:draw()
    end

    function love.resize(width, height)
        if app then
            app:resize(width, height)
        end
    end

    function love.keypressed(key, scancode, isRepeat)
        app:keypressed(key, scancode, isRepeat)
    end

    function love.wheelmoved(x, y)
        app:wheelmoved(x, y)
    end
end
