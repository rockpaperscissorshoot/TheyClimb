local world = {}
world.physicsWorld = nil
world.dynamicObjects = {}
local ground

function world.load()

    love.physics.setMeter(64)
    world.physicsWorld = love.physics.newWorld(0, 9.81 * 64, true)

    ground = {}
    ground.body = love.physics.newBody(world.physicsWorld, 600, 800)
    ground.shape = love.physics.newRectangleShape(800, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)

    return world.physicsWorld
end

function world.update(dt)
    world.physicsWorld:update(dt)
end

function world.draw()

    --ground
    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- cube
    love.graphics.setColor(0.76, 0.18, 0.05)
    for _, obj in ipairs(world.dynamicObjects) do
        love.graphics.polygon("fill", obj.body:getWorldPoints(obj.shape:getPoints()))
    end
end

function world.spawnCube(x, y)
    local body = love.physics.newBody(world.physicsWorld, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(30,30)
    local fixture = love.physics.newFixture(body, shape, 1)
    table.insert(world.dynamicObjects, {body = body, shape =shape, fixture = fixture})

end


return world