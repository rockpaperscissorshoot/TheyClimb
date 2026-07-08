love.window.setMode(800, 800, {resizable=true, vsync=true, minwidth=400, minheight=400})

local world = require("gameScripts.world")
local player = require("gameScripts.player")
local camera = require("gameScripts.camera")
local ui = require("gameScripts.ui")

function love.load()
    local physicsworld = world.load()
    player.load(physicsworld)
    camera.load()
    ui.load(camera)
    
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
    ui.draw()
end

function love.mousemoved(x,y)
    ui.mousemoved(x,y)
end

function love.mousepressed(x,y, button)
    ui.mousepressed(x,y, button)
end

function love.mousereleased(x,y, button)
    ui.mousereleased(x,y, button)
end

function love.keypressed(key)
    if key == "space" then
        local screenX, screenY = love.mouse.getPosition()
        local worldX, worldY = camera.screenToWorld(screenX, screenY)
        world.spawnCube(worldX, worldY)
    end
end