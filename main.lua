love.window.setMode(800, 800, {resizable=true, vsync=true, minwidth=400, minheight=400})

local world = require("gameScripts.world")
local player = require("gameScripts.player")
local camera = require("gameScripts.camera")


function love.load()
    local physicsworld = world.load()
    player.load(physicsworld)
    camera.load()
    
end

function love.update(dt)
    player.update(dt)
    world.update(dt)
    camera.update(dt, player.getbody())
end

function love.draw()
    camera.begin() 
    world.draw()
    player.draw()
    camera.off()
    
end

