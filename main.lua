love.window.setMode(800,800, {resizable=true, vsync=true})

local world
local ground
local box
local kong

local cameraX = 0
local cameraY = 0
local cameraTargetX = 0
local cameraTargetY = 0
local cameraZoom = 0.36

local sliderModule = {
    x = 0,
    y = 0,
    width = 200,
    height = 20,
    minZoom = 0.01,
    maxZoom = 1.0,
    draggingSlider = false,
    knobSize = 20,
}

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)
    ground = {}
    box = {}
    kong = {}

    ground.body = love.physics.newBody(world, 400, 550, "static")
    ground.shape = love.physics.newRectangleShape(1600, 100)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)


    box.body = love.physics.newBody(world, 400, 200, "dynamic")
    box.shape = love.physics.newRectangleShape(107, 107)
    box.fixture = love.physics.newFixture(box.body, box.shape, 1)

    kong.body = love.physics.newBody(world,800, -12000, "dynamic")
    kong.shape = love.physics.newRectangleShape(150, 3884)
    kong.fixture = love.physics.newFixture(kong.body, kong.shape, 1)
    sliderModule.x = love.graphics.getWidth() / 2 - sliderModule.width / 2
    sliderModule.y = love.graphics.getHeight() - 50
end

function love.update(dt)

    box.body:applyForce(433, 0)  
    world:update(dt)

    cameraTargetX = box.body:getX()
    cameraTargetY = box.body:getY()/-0.73 -- this is just to show scale

    cameraX = cameraX + (cameraTargetX - cameraX) * 0.067
    cameraY = cameraY + (cameraTargetY - cameraY) * 0.067
end

function love.draw()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.push()
    love.graphics.translate(screenWidth / 2, screenHeight / 2)
    love.graphics.scale(cameraZoom, cameraZoom)
    love.graphics.translate(-cameraX, -cameraY)

    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.polygon("fill", box.body:getWorldPoints(box.shape:getPoints()))

    love.graphics.setColor(0.67, 0.67, 0.67)
    love.graphics.polygon("fill", kong.body:getWorldPoints(kong.shape:getPoints()))

    love.graphics.pop()

    drawSlider()
end

function drawSlider()
    local sliderX = sliderModule.x
    local sliderY = sliderModule.y
    local sliderWidth = sliderModule.width
    local sliderHeight = sliderModule.height

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", sliderX, sliderY-sliderHeight/2, sliderWidth, sliderHeight)

    local sliderValue = (cameraZoom - sliderModule.minZoom) / (sliderModule.maxZoom - sliderModule.minZoom)
    sliderValue = math.max(0, math.min(1, sliderValue))
    local knobX = sliderX + sliderValue * (sliderWidth)
    local knobY = sliderY
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.circle("fill", knobX, sliderModule.y - (sliderModule.knobSize - sliderModule.height) / 2, sliderModule.knobSize)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Zoom: %.2f", cameraZoom), sliderX, sliderY + 30)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if ismouseOnKnob(x, y) then
            sliderModule.draggingSlider = true
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    if sliderModule.draggingSlider then
        updateCameraZoom(x)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        sliderModule.draggingSlider = false
    end
end

function ismouseOnKnob(x, y)
    local sliderValue = (cameraZoom - sliderModule.minZoom) / (sliderModule.maxZoom - sliderModule.minZoom)
    sliderValue = math.max(0, math.min(1, sliderValue))
    local knobX = sliderModule.x + sliderValue * (sliderModule.width)
    local knobY = sliderModule.y 

    return math.distance(x, y, knobX, knobY) < sliderModule.knobSize + 2
end

function updateCameraZoom(x)
    local sliderValue = (x - sliderModule.x) / sliderModule.width
    sliderValue = math.max(0, math.min(1, sliderValue))
    cameraZoom = sliderModule.minZoom + sliderValue * (sliderModule.maxZoom - sliderModule.minZoom)
end

function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- This is the math part. Think  of this worlds most thrilling large monsters of humongous sizes. 
-- The biggest of monsters like king kong and godzilla are the most captivitating of the massive beasts. 
-- It's for that reasons that kaiju movies are so popular. The thrill of seeing these giant monsters wreak havoc on cities and battle each other is unmatched. 
-- The sheer scale of destruction and the awe-inspiring visuals make for an unforgettable cinematic experience.
-- Whether it's the towering presence of Godzilla or the primal strength of King Kong, 
-- these colossal creatures continue to captivate audiences around the world. 
-- So if the best dipition (other than MLOM) of kong was in TV series Skull island in whic they depicted kong as around 200 feet tall,
-- that would mean hes about 60.69 meters. We also know that at 16X zoom, our 50x50px box is about less than a meter in size. 
-- I want the player to feel like their contribtuion is huge, so i want the carecter to feel like a giant, but cower in fear of something around the same scope.
-- Think about it like the universe. Looking out on the universe makes you seem so small, but you are still a part of it. 
-- You are still a giant in your own right, even if you are small compared to the vastness of the cosmos. your contribtuions can change the world
-- i want the player to feel like they are a giant, but also feel like they are a part of something bigger.
-- So for them to feel like a giant they need the size of kong. and since we know the cube is around 0.78m then kong should be around 36.19x the size of the cube. 
-- so at zoom level 16 the cube is 800 pixels in size, so kong should be around 36.19 * 800 = 28,952 pixels in size.
-- but since we dont want the size of kong we want the amount of zoom needed to make the cube seem like the human.
-- 64 px = 1m 
-- x px = 60.69m
-- x = 60.69 * 64
-- x = 3884.16 px
-- to achieve a zoom level in which the dimensions of the screen are 3884.16pixels tall we need to have a zoom of 0.20 to get the optimal feel

-- this doesnt feel the nicest but now we can understand what we are dealing with multiple kongs at multiple times in life so lets get a wide range of values
-- zoom of 0.36
-- to document kong sizes we need to have a assosiated timeline
-- Kong: skull Island (2017) || He was 104 feet => 31.7m => 2028.8px => 0.39 zoom
-- Godzilla: King of the Monsters (2019) || not enough info may
-- Godzilla vs. Kong(2021) || He was 335 feet => 102.11m => 6535.04px => 0.12 zoom
-- Skull Islasnd (2023) || He was 200 feet => 60.69m => 3884.16 => 0.20 zoom
-- monarch: Legacy of monsters (2023-2026) || same as 2021
-- Godzilla x Kong: The New Empire (2024) || same as 2021
-- Godzilla x Kong: Supernova (2027) || might be the same as 2021 but we dont know yet
-- also knowing how my math works i now realize i need to change the size of my cube
-- 1.6764m * 64px = 107px
