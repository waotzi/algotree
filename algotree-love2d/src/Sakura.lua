local ma = love.math

return {
    special = "sakura",
    cs_branch = {.4, .5, 0, 0, .2, .3},
    cs_leaf = {.8, 1, .6, .7, .7, .8},
    splitAngle = {30, 40},
    growTime = ma.random(4, 7),
    maxStage = ma.random(7, 8),
    w = ma.random(22, 27),
    h = ma.random(72, 86),
}