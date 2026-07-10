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

    if world.grabbed then
        world.grabbed.body:setPosition(world.grabbedTargetX, world.grabbedTargetY)
        world.grabbed.body:setLinearVelocity(0, 0)
    end

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
    local object = {body = body, shape = shape, fixture = fixture}
    table.insert(world.dynamicObjects, object)
    return object
end

function world.setGrabbed(object)
    world.grabbed = object
    object.body:setType("kinematic")
    object.body:setPosition(world.grabbedTargetX, world.grabbedTargetY)
    object.body:setLinearVelocity(0, 0)
end

function world.releaseGrabbed()
    if world.grabbed then
        world.grabbed.body:setType("dynamic")
        world.grabbed.body:setLinearVelocity(0, 0)
        world.grabbed = nil
    end
end

return world