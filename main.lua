local perlin = require("perlin")

function love.load()
    love.window.setTitle("Procedural Terrain Generation")
    love.graphics.setBackgroundColor(0.5, 0.7, 1) -- Sky color
    width, height = love.graphics.getDimensions()
    terrain = generateHeightmap(width, height)
end

function generateHeightmap(width, height)
    local heightmap = {}
    for x = 1, width do
        heightmap[x] = {}
        for y = 1, height do
            local noiseValue = perlin.perlin2d(x / 5, y / 5)
            heightmap[x][y] = noiseValue
        end
    end
    return heightmap
end

function love.draw()
    for x = 1, #terrain do
        for y = 1, #terrain[x] do
            local value = terrain[x][y]
            local color = value * 255
            if value < 0.3 then
                love.graphics.setColor(0, 0, 1) -- Water
            elseif value < 0.5 then
                love.graphics.setColor(0, 1, 0) -- Grass
            elseif value < 0.7 then
                love.graphics.setColor(0.5, 0.5, 0) -- Sand
            else
                love.graphics.setColor(1, 1, 1) -- Snow
            end
            love.graphics.points(x, y)
        end
    end
end