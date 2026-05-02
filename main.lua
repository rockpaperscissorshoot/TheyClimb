local world
local ground
local box

local cameraX = 0
local cameraY = 0

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)
    ground = {}
    box = {}
    ground.body = love.physics.newBody(world, 400, 550, "static")
    ground.shape = love.physics.newRectangleShape(800, 100)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)


    box.body = love.physics.newBody(world, 400, 200, "dynamic")
    box.shape = love.physics.newRectangleShape(50, 50)
    box.fixture = love.physics.newFixture(box.body, box.shape, 1)
end

function love.update(dt)

    box.body:applyForce(80, 0)  
    world:update(dt)

    local cameraTargetX = box.body:getX() - love.graphics.getWidth() / 2
    local cameraTargetY = box.body:getY() - love.graphics.getHeight() / 2

    cameraX = cameraX + (cameraTargetX - cameraX) * 0.1
    cameraY = cameraY + (cameraTargetY - cameraY) * 0.1
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cameraX, -cameraY)

    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.polygon("fill", box.body:getWorldPoints(box.shape:getPoints()))

    love.graphics.pop()
end