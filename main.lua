love.window.setTitle("LÖVE They Climb Remake")
love.window.setMode(1280, 720, {resizable = true, vsync = true})
math.randomseed(os.time())


love.physics.setMeter(64)

local CONFIG = {
    moveSpeed = 4,
    gravity = 9.81,
    cubeSize = 30,
}

local FPS_SCALE = 60

local function NewAxisAlignedBoundingBox(x, y, width, height)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
    }
end

local function OverlappingAxisAlignedBoundingBoxes(location, size)
    return location.x < size.x + size.width and
           location.x + location.width > size.x and
           location.y < size.y + size.height and
           location.y + location.height > size.y
end

local Cube = {}
Cube.__index = Cube

function Cube:new(x, y, world)
    local c = setmetatable({}, Cube)

    c.body = love.physics.newBody(world, x + CONFIG.cubeSize / 2, y + CONFIG.cubeSize / 2, "dynamic")
    c.body:setFixedRotation(true)--Temporary, for testing
    c.shape = love.physics.newRectangleShape(CONFIG.cubeSize, CONFIG.cubeSize)
    c.fixture = love.physics.newFixture(c.body, c.shape,1) --Density of 1, for testing Change value around as needed
    c.fixture:setFriction(0) 
    c.fixture:setRestitution(0) 
    c.width = CONFIG.cubeSize
    c.height = CONFIG.cubeSize
    c.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}
    c.state = 'air'
    return c
end


function Cube:getX()
    return self.body:getX() - self.width / 2
end

function Cube:getY()
    return self.body:getY() - self.height / 2
end

function Cube:getVelocity()
    return self.body:getLinearVelocity()
end

function Cube:setVelocity(vx, vy)
    self.body:setLinearVelocity(vx, vy)
end

function Cube:checkSensors(obstacles)
    local margin = 4
    local sensors = {   floor = false,
                        left = false,
                        right = false,
                        ceiling = false }

    local xPosition = self:getX()
    local yPosition = self:getY()

    local bottomOfTheBox= NewAxisAlignedBoundingBox(xPosition, yPosition + self.height, self.width, margin)
    local topOfTheBox = NewAxisAlignedBoundingBox(xPosition, yPosition - margin, self.width, margin)
    local leftOfTheBox = NewAxisAlignedBoundingBox(xPosition - margin, yPosition, margin, self.height)
    local rightOfTheBox = NewAxisAlignedBoundingBox(xPosition + self.width, yPosition, margin, self.height)

    for _, obstacle in ipairs(obstacles) do
        local obstacleBox = NewAxisAlignedBoundingBox(obstacle.x, obstacle.y, obstacle.width, obstacle.height)

        if OverlappingAxisAlignedBoundingBoxes(bottomOfTheBox, obstacleBox) then
            sensors.floor = true
        end

        if OverlappingAxisAlignedBoundingBoxes(topOfTheBox, obstacleBox) then
            sensors.ceiling = true
        end

        if OverlappingAxisAlignedBoundingBoxes(leftOfTheBox, obstacleBox) then
            sensors.left = true
        end

        if OverlappingAxisAlignedBoundingBoxes(rightOfTheBox, obstacleBox) then
            sensors.right = true
        end
    end

    return sensors
end

function Cube:determineState(contact)

    local pixelNudge = 5 

    if self.state == 'air' then
        if contact.floor then
            self.state = 'floor'
        elseif contact.right then
            self.state = 'rightWall'
        elseif contact.ceiling then
            self.state = 'ceiling'
        elseif contact.left then
            self.state = 'leftWall'
        end


    elseif self.state == 'floor' then
        if contact.right then
            self.state = 'rightWall'
        elseif not contact.floor then
            self.state = 'air'
        end


    elseif self.state == 'rightWall' then
        if contact.ceiling then
            self.state = 'ceiling'
        elseif not contact.right then
            self.state = 'floor' -- right is this correct gang i'm bugguging
            local xPositin, yPosition = self.body:getPosition()
            self.body:setPosition(xPositin + pixelNudge, yPosition - pixelNudge)
        end


    elseif self.state == 'ceiling' then
        if contact.left then
            self.state = 'leftWall'
        elseif not contact.ceiling then
            self.state = 'rightWall' -- 

            local xPositin, yPosition = self.body:getPosition()
            self.body:setPosition(xPositin + pixelNudge, yPosition - pixelNudge)
        end


    elseif self.state == 'leftWall' then
        if contact.floor then
            self.state = 'floor'
        elseif not contact.left then
            self.state = 'ceiling'

            local xPositin, yPosition = self.body:getPosition()
            self.body:setPosition(xPositin - pixelNudge, yPosition - pixelNudge)
        end
    end
end

function Cube:applyMovement(deltaTime)
    local speed = CONFIG.moveSpeed * FPS_SCALE -- isnt speed velocity without direction? maybe i should change the name of this variable to moveVelocity or something
    local spiderForce = 2.0 * FPS_SCALE -- is a test value
    local velocityX = 0
    local velocityY = 0
    local airResistance = 0.998 -- yeah i know CPU_HARD isnt adding air resistance cringe. guess what... i dont care (^^)

    if self.state == 'air' then
        self.body:setGravityScale(1)
        freeFallVelocityX, freeFallVelocityY = self:getVelocity()
        velocityX = freeFallVelocityX * airResistance
        velocityY = freeFallVelocityY -- acceleration is still the same
        self.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}

        self.body:setLinearVelocity(velocityX, velocityY)

    else
        self.body:setGravityScale(0)

        if self.state == 'floor' then
            velocityX = speed
            velocityY = spiderForce
            self.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}

        elseif self.state == 'rightWall' then
            velocityX = spiderForce
            velocityY = -speed
            self.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}
        elseif self.state == 'ceiling' then
            velocityX = -speed
            velocityY = -spiderForce
            self.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}
        elseif self.state == 'leftWall' then
            velocityX = -spiderForce
            velocityY = speed
            self.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}
        end

        self:setVelocity(velocityX, velocityY)
    end
end

function Cube:update(deltaTime, obstacles, canvasHeight, canvasWidth)
    local contact = self:checkSensors(obstacles)
    self:determineState(contact)
    self:applyMovement(deltaTime)

    if self:getY() > canvasHeight + 200 then
        if resetCallback then
            resetCallback()
        end
    end
end

function Cube:draw()
    yPosition = self:getY()
    xPosition = self:getX()

    if self.state == 'air' then
        love.graphics.setColor((117/255), (255/255), (255/255), 0.18) 
    elseif self.state == 'floor' then
        love.graphics.setColor((255/255), (117/255), (255/255), 0.18)
    elseif self.state == 'rightWall' then
        love.graphics.setColor((255/255), (255/255), (117/255), 0.18)
    elseif self.state == 'ceiling' then
        love.graphics.setColor((117/255), (117/255), (255/255), 0.18)
    elseif self.state == 'leftWall' then
        love.graphics.setColor((117/255), (255/255), (117/255), 0.18)
    end
    --love.graphics.setColor(self.color.r, self.color.g, self.color.b, 0.18)
    love.graphics.rectangle("fill", xPosition - (CONFIG.cubeSize / 4), yPosition - (CONFIG.cubeSize / 4), self.width + (CONFIG.cubeSize / 2), self.height + (CONFIG.cubeSize / 2), (CONFIG.cubeSize / 4), (CONFIG.cubeSize / 4))
    if self.state == 'air' then
        love.graphics.setColor((117/255), (255/255), (255/255), 1) 
    elseif self.state == 'floor' then
        love.graphics.setColor((255/255), (117/255), (255/255), 1)
    elseif self.state == 'rightWall' then
        love.graphics.setColor((255/255), (255/255), (117/255), 1)
    elseif self.state == 'ceiling' then
        love.graphics.setColor((117/255), (117/255), (255/255), 1)
    elseif self.state == 'leftWall' then
        love.graphics.setColor((117/255), (255/255), (117/255), 1)
    end
    love.graphics.rectangle("fill", xPosition, yPosition, self.width, self.height, ((CONFIG.cubeSize / 4)-2), ((CONFIG.cubeSize / 4)-2))
    love.graphics.setColor(1, 1, 1, 1.0)

    local eyeXPosition1 = (CONFIG.cubeSize / 4)
    local eyeYPosition1 = (CONFIG.cubeSize / 4)
    local eyeXPosition2 = (CONFIG.cubeSize / 4) * 3
    local eyeYPosition2 = (CONFIG.cubeSize / 4)

    if self.state == 'floor' then

        eyeXPosition1 = (CONFIG.cubeSize / 4)
        eyeYPosition1 = (CONFIG.cubeSize / 4)
        eyeXPosition2 = (CONFIG.cubeSize / 4) * 3
        eyeYPosition2 = (CONFIG.cubeSize / 4)

    elseif self.state == 'rightWall' then

        eyeXPosition1 = (CONFIG.cubeSize / 4) 
        eyeYPosition1 = (CONFIG.cubeSize / 4)
        eyeXPosition2 = (CONFIG.cubeSize / 4)
        eyeYPosition2 = (CONFIG.cubeSize / 4) * 3
    
    elseif self.state == 'ceiling' then

        eyeXPosition1 = (CONFIG.cubeSize / 4) 
        eyeYPosition1 = (CONFIG.cubeSize / 4) * 3
        eyeXPosition2 = (CONFIG.cubeSize / 4) * 3
        eyeYPosition2 = (CONFIG.cubeSize / 4) * 3

    elseif self.state == 'leftWall' then

        eyeXPosition1 = (CONFIG.cubeSize / 4) *3
        eyeYPosition1 = (CONFIG.cubeSize / 4) 
        eyeXPosition2 = (CONFIG.cubeSize / 4) *3
        eyeYPosition2 = (CONFIG.cubeSize / 4) *3 

    elseif self.state == 'air' then

        eyeXPosition1 = (CONFIG.cubeSize / 4) 
        eyeYPosition1 = (CONFIG.cubeSize / 4)* 2
        eyeXPosition2 = (CONFIG.cubeSize / 4) * 3
        eyeYPosition2 = (CONFIG.cubeSize / 4) *2

    end

    love.graphics.setColor(0, 0, 0, 1.0)
    love.graphics.circle("fill", math.floor(xPosition + eyeXPosition1), math.floor(yPosition + eyeYPosition1), CONFIG.cubeSize / 6)
    love.graphics.setColor(0, 0, 0, 1.0)
    love.graphics.circle("fill", math.floor(xPosition + eyeXPosition2), math.floor(yPosition + eyeYPosition2), CONFIG.cubeSize / 6)

end

-- Break player file time for the world generation file --

local obstacles = {}
local physicsObastacles = {}
local loadedChuncks = 0
local windowWidth, windowHeight = love.graphics.getDimensions()
local groundBaseHeight = windowHeight - 100
local world = nil


local function createPhysicsObstacle(world, xPosition, yPosition, width, height)
    local body = love.physics.newBody(world, xPosition + width / 2, yPosition + height / 2, "static")
    local shape = love.physics.newRectangleShape(width, height)
    local fixture = love.physics.newFixture(body, shape)
    fixture:setFriction(0.3) -- also testing value
    fixture:setRestitution(0.1) -- this is my sigma testing value
    return {body = body, 
            shape = shape,
            fixture = fixture}

end

local function generateTerrain(startPositionX, world)
    local x = startPositionX
    local groundBaseHeight = love.graphics.getHeight() - 100

    for i = 1, 10 do

        local type = math.random()
        if type > 0.6 then

            local width = math.random(250, 350) -- i'll change this when imight need to add diffrent climbing
            local height = math.random(150, 250) -- same with this one

            table.insert(obstacles, NewAxisAlignedBoundingBox(x, groundBaseHeight, width, height))
            table.insert(physicsObastacles, createPhysicsObstacle(world, x, groundBaseHeight, width, height))

            wallXPosition = x +  (width/2)
            wallHeight = height
            table.insert(obstacles, NewAxisAlignedBoundingBox(wallXPosition, groundBaseHeight - wallHeight, 10, wallHeight))
            table.insert(physicsObastacles, createPhysicsObstacle(world, wallXPosition, groundBaseHeight - wallHeight, 10, wallHeight))

            table.insert(obstacles, NewAxisAlignedBoundingBox(wallXPosition - (height/2), groundBaseHeight - wallHeight, (height/2), 10))
            table.insert(physicsObastacles, createPhysicsObstacle(world, wallXPosition - (height/2), groundBaseHeight - wallHeight, (height/2), 10))

            table.insert(obstacles, NewAxisAlignedBoundingBox(wallXPosition - (height/2), groundBaseHeight - wallHeight, 10, (height/2)))
            table.insert(physicsObastacles, createPhysicsObstacle(world, wallXPosition - (height/2), groundBaseHeight - wallHeight, 10, (height/2)))

            x = x + width
        elseif type > 0.3 then

            local width = math.random(150, 250) --
            local height = math.random(150,250)

            table.insert(obstacles, NewAxisAlignedBoundingBox(x, groundBaseHeight, width, height))
            table.insert(physicsObastacles, createPhysicsObstacle(world, x, groundBaseHeight, width, height))

            table.insert(obstacles, NewAxisAlignedBoundingBox((x + width +10 ), groundBaseHeight - height, (width-10), height))
            table.insert(physicsObastacles, createPhysicsObstacle(world, (x + width +10 ), groundBaseHeight - height, (width-10), height))

            x = x + (width*2)

        else
            
            local width = math.random(250, 350) 
            local height = math.random(150, 250)

            table.insert(obstacles, NewAxisAlignedBoundingBox(x, groundBaseHeight, width, height))
            table.insert(physicsObastacles, createPhysicsObstacle(world, x, groundBaseHeight, width, height))

            x = x + width
        end
    end

    loadedChuncks = x
end

-- main.lua if i remeber how to make one--

local player 
local cameraX = 0
local distance = 0

local function resetGame()
    obstacles = {}
    physicsObastacles = {}
    loadedChuncks = 0
    world = love.physics.newWorld(0, CONFIG.gravity * FPS_SCALE, true)
    generateTerrain(0, world)
    player = Cube:new(100, 200, world)
    score = 0
    cameraX = 0
end

local function drawUI()
    local padding = 12
    local panelWidth = 200 --add a slight moving elastictiyty to moving later
    local panelHeight = 200

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 20, 20, panelWidth, panelHeight, 10, 10)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setLineWidth(2) -- I am adding this last but for right now noooooo fonts are needed they are lowkey sooo annowying to work with if i ever needed to work with fonts lowkey just use an image instead.
    love.graphics.rectangle('line', 20, 20, panelWidth, panelHeight, 10, 10)
    love.graphics.setColor(1, 1, 0, 1)
    -- this is for debugguing only might be useful for later tho --
    love.graphics.printf("Algorithm State: ", 30, 35, panelWidth - (padding*2), 'left')
    
    local function drawStat(yPosition, lable, active, color)

        love.graphics.setColor(1, 0, 1, 1)
        love.graphics.circle('fill', 40, yPosition, 10)
        if active then
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.circle('fill', 40 , yPosition, 10)
        else
            love.graphics.setColor(1, 0, 1, 0.2)
            love.graphics.circle('fill', 40, yPosition, 13)

        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(lable, 60, yPosition - 10)
    end

    local ystart = 80

    drawStat(ystart, "Floor ( go to the right)", player.state == 'floor', {r = 1, g = 1, b = 0})
    drawStat(ystart + 25, "Right Wall ( go up)", player.state == 'rightWall', {r = 1, g = 1, b = 0})
    drawStat(ystart + 50, "Ceiling ( go to the left)", player.state == 'ceiling', {r = 1, g = 1, b = 0})
    drawStat(ystart + 75, "Left Wall ( go down)", player.state == 'leftWall', {r = 1, g = 1, b = 0})
    drawStat(ystart + 100, "Air ( falling)", player.state == 'air', {r = 1, g = 1, b = 0})

    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.print("Distance: " .. tostring(distance), 30, ystart + 120)
    love.graphics.pop()

    local hint = " if you press the 'R' key you reset the game. this is experimental and will be removed later so have fun for now"
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print(hint, 20, love.graphics.getHeight() - 40)
end

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    windowWidth, windowHeight = love.graphics.getDimensions()
    resetGame()
end

function love.update(dt)
    if player:getX() + love.graphics.getWidth() +20 > loadedChuncks then -- change the plus 20 in case of bad generation
        generateTerrain(loadedChuncks, world)
    end

    if #obstacles > 1000 then -- soon this is going to get really big so starting at 50 is good for now
        table.remove(obstacles, 1)
        if #physicsObastacles > 0 then
            table.remove(physicsObastacles, 1)
        end
    end

    world:update(dt)
    player:update(dt, obstacles, love.graphics.getHeight(), love.graphics.getWidth())
    distance = math.floor(player:getX() / 10) 

    local targetCameraX = player:getX() - (love.graphics.getWidth() / 3)
    cameraX = cameraX + (targetCameraX - cameraX) * 0.01 -- this is the elastic camera movement makes it look good. or in simpler terms this is a lerp durhh
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)

    love.graphics.setColor(0.5, 0.5, 0.5, 1)

    for _, obstacle in ipairs(obstacles) do
        if obstacle.x + obstacle.width > cameraX and obstacle.x < cameraX + love.graphics.getWidth() then
            love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
    end

    player:draw()
    love.graphics.pop()

    drawUI()
end

function spawnSquareAtMouse(x, y, button)
    local worldX = x + cameraX
    local worldY = y
    table.insert(obstacles, NewAxisAlignedBoundingBox(worldX, worldY, 3, 3))
    table.insert(physicsObastacles, createPhysicsObstacle(world, worldX, worldY, 3, 3))
end
--[[
function love.mousepressed(x, y, button)
    spawnSquareAtMouse(x, y, button)
end

]]
function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) then
        spawnSquareAtMouse(x, y, 1)
    end
end
function love.touchpressed(id, x, y, dx, dy, pressure)
    spawnSquareAtMouse(x, y, button)
end
function love.keypressed(key)
    if key == "r" then
        resetGame()
    end
end

