local world
local ground
local box

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
end

function love.draw()
    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.polygon("fill", box.body:getWorldPoints(box.shape:getPoints()))
end