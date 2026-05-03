local player = {}

function player.load(physicsworld)
    player.body = love.physics.newBody(physicsworld, 400, 400, "dynamic")
    player.shape = love.physics.newRectangleShape(107, 107)
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
end

function player.update(dt)
    player.body:applyForce(433, 0)
end

function player.draw()
    --player body
    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
end

function player.getbody()
    return player.body
end

return player