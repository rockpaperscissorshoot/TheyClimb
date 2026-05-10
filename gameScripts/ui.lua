local ui  = {}
local camera 

local slider = {
    x = 0,
    y = 0,
    width = 200,
    height = 20,
    knobSize = 10,
    minZoom = 0.01,
    maxZoom = 1,
    isDragging = false
}

function ui.load(cam)
    camera = cam
end

function ui.draw()
    slider.x = love.graphics.getWidth() / 2 - slider.width / 2
    slider.y = love.graphics.getHeight() - 50

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", slider.x, slider.y - slider.height/2 , slider.width , slider.height)

    local knobValue = (camera.cameraZoom - slider.minZoom) / (slider.maxZoom - slider.minZoom)
    knobValue = math.max(0, math.min(1, knobValue))
    local knobX = slider.x + knobValue * slider.width
    local knobY = slider.y
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("fill", knobX, knobY - (slider.knobSize - slider.height)/2, slider.knobSize)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Zoom: %.2f", camera.cameraZoom), slider.x, slider.y + 30)
end

function ui.mousemoved(x,y)
    if slider.isDragging then 
        local knobValue = (x - slider.x) / slider.width
        knobValue = math.max(0, math.min(1, knobValue))
        camera.cameraZoom = slider.minZoom + knobValue * (slider.maxZoom - slider.minZoom)
    end
end

function ui.mousepressed(x,y, button)
    if button == 1 and ui.isOnKob(x, y) then
        slider.isDragging = true
    end
end

function ui.mousereleased(x,y, button)
    if button == 1 then
        slider.isDragging = false
    end
end

function ui.isOnKob(x, y)
    local knobValue = (camera.cameraZoom - slider.minZoom) / (slider.maxZoom - slider.minZoom)
    knobValue = math.max(0, math.min(1, knobValue))
    local knobX = slider.x + knobValue * slider.width
    local knobY = slider.y
    local dx = x - knobX
    local dy = y - (knobY - (slider.knobSize - slider.height)/2)
    return math.sqrt(dx * dx + dy * dy) <= slider.knobSize + 2
end

return ui
