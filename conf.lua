function love.conf(t)
    t.identity = "love2d-shader-kit-demo"
    t.version = "11.5"
    t.console = false

    t.window.title = "LÖVE Shader Kit"
    t.window.width = 1280
    t.window.height = 720
    t.window.minwidth = 840
    t.window.minheight = 520
    t.window.resizable = true
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.highdpi = true

    t.modules.audio = false
    t.modules.physics = false
end
