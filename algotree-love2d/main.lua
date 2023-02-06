local Plant = require 'src.Plant'

local tree

function love.load()
  tree = Plant:init("Sakura", {x = 400, y = 560, growTime = 0.5})
end

function love.draw()
  tree:draw()
end

function love.update(dt)
  tree:update(dt)
end
