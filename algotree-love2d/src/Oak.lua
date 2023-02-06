local ma = love.math

return {
    type = "tree",
    cs_branch = {.5, .6, .2, .3, .2, .3},
    cs_leaf = {.2, .4, .4, .5, .2, .3},
    growTime = 4,
    maxStage = 6,
    w = 20,
    h = 42,
    splitChance = 3,
    leafSize = 1,
    leafChance = 4,
    startSpilt = true,
}