love.window.setMode(800,800, {resizable=true, vsync=true})

local world
local ground
local box

local cameraX = 0
local cameraY = 0
local cameraTargetX = 0
local cameraTargetY = 0
local cameraZoom = 1

local sliderModule = {
    x = 0,
    y = 0,
    width = 200,
    height = 20,
    minZoom = 0.1,
    maxZoom = 16.0,
    draggingSlider = false,
    knobSize = 20,
}

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)
    ground = {}
    box = {}
    ground.body = love.physics.newBody(world, 400, 550, "static")
    ground.shape = love.physics.newRectangleShape(1600, 100)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)


    box.body = love.physics.newBody(world, 400, 200, "dynamic")
    box.shape = love.physics.newRectangleShape(50, 50)
    box.fixture = love.physics.newFixture(box.body, box.shape, 1)

    sliderModule.x = love.graphics.getWidth() / 2 - sliderModule.width / 2
    sliderModule.y = love.graphics.getHeight() - 50
end

function love.update(dt)

    box.body:applyForce(0, 0)  
    world:update(dt)

    cameraTargetX = box.body:getX()
    cameraTargetY = box.body:getY() 

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