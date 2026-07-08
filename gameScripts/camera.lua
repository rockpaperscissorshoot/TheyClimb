local camera = {
    x = 0,
    y = 0,
    cameraTargetX = 0,
    cameraTargetY = 0,
    cameraLerpSpeed = 0.067,
    cameraZoom = 0.34
}

function camera.load()
    -- i guess not hting is needed lol
end

function camera.update(dt, target)
    camera.cameraTargetX = target:getX()
    camera.cameraTargetY = target:getY() 

    camera.x = camera.x + (camera.cameraTargetX - camera.x) * camera.cameraLerpSpeed
    camera.y = camera.y + (camera.cameraTargetY - camera.y) * camera.cameraLerpSpeed
end

function camera.begin()
    love.graphics.push()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.translate(screenWidth / 2, screenHeight / 2)
    love.graphics.scale(camera.cameraZoom, camera.cameraZoom)
    love.graphics.translate(-camera.x, -camera.y)
end

function camera.off()
    love.graphics.pop()
end

function camera.screenToWorld(ScreenX, ScreenY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local worldX = (ScreenX - screenWidth / 2) / camera.cameraZoom + camera.x
    local worldY = (ScreenY - screenHeight / 2) / camera.cameraZoom + camera.y
    return worldX, worldY
end

return camera