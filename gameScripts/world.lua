local world = {}
local phyisicsWorld
local ground

function world.load()

    love.physics.setMeter(64)
    phyisicsWorld = love.physics.newWorld(0, 9.81 * 64, true)

    ground = {}
    ground.body = love.physics.newBody(phyisicsWorld, 400, 800 - 50 / 2)
    ground.shape = love.physics.newRectangleShape(800, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)

    return phyisicsWorld
end

function world.update(dt)
    phyisicsWorld:update(dt)
end

function world.draw()

    --ground
    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
end

return world