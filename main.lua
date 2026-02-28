local perlin = require("perlin")

function love.load()
    love.window.setTitle("Procedural Terrain Generation")
    love.graphics.setBackgroundColor(0.5, 0.7, 1) -- Sky color
    width, height = love.graphics.getDimensions()
    terrain = generateTerrain(width, height)
end

function generateTerrain(width, height)
    local terrain = {}
    for x = 1, width do
        terrain[x] = {}
        for y = 1, height do
            local noiseValue = perlin.perlin2d(x / 100, y / 100)
            terrain[x][y] = noiseValue
        end
    end
    return terrain
end

function love.draw()
    for x = 1, #terrain do
        for y = 1, #terrain[x] do
            local value = terrain[x][y]
            local color = value * 255
            love.graphics.setColor(color / 255, color / 255, color / 255)
            love.graphics.points(x, y)
        end
    end
end