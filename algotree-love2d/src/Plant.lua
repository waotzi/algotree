local copy = require "copy"

local gr = love.graphics
local ma = love.math

local deg_to_rad = math.pi / 180

-- default template
local template = {
    -- default type of plant
    type = "tree",
    -- how long it takes to grow
    growTime = 1,
    -- branch colorscheme
    cs_branch = {.5, .7, .2, .4, .2, .3},
    -- leaf colorscheme
    cs_leaf = {.2, .2, .5, .6, .2, .4},
    -- how many layers the tree will have
    maxStage = 7,
    -- coords
    x = 600, y = 800,
    -- scale
    scale = 1,
    -- size of leaves
    leafSize = 1,
    -- chance of growing a leaf, 0 - 10, 0 is to grow always
    leafChance = 0,
    -- table of all branches, each layer in their of table
    branches = {},
    -- table of all layer
    leaves = {},
    -- the random angle divergence
    splitAngle = {20, 30},
    -- set the frequency of splitting up branhes
    -- generates random number from 1 - 10
    -- if > splitChance then split
    -- else do not split
    splitChance = 4,
    -- the scale of how the size should change at each growth
    changeW = .9,
    changeH = .95,
    -- used for first branch
    currentStage = 0,
    changeColor = {0, 0, 0},
    w = 12, h = 32,
    randStage = false,
 }


-- fill self with properties of plant or prop
local function fill_self(self, props)
    for k, v in pairs(copy(props)) do
        self[k] = v
    end
end

local function init(self, name, props)
    -- fill with template
    fill_self(self, template)
    -- fill with name of plant if provided
    if name then
        assert(type(name) == "string", "name of plant needs to be string")
        local props = require ("src." .. name)
        assert(type(props) == "table", "props from name need to be a table of key values")
        fill_self(self, props)
    end
    -- fill with table if provided
    if props then
        assert(type(props) == "table", "props needs to be a table of key values")
        fill_self(self, props)
    end

    -- set timer value for values counting to 0
    self.growTimer = self.growTime

    if self.randStage then
        self.currentStage = ma.random(0, self.maxStage)
    end
    if self.currentStage == 0 then
        self.first = true
    else
        for _ = #self.branches, self.currentStage do
            table.insert(self.branches, grow(self))
        end
    end
    -- return the new plant
    return copy(self)
end

local function getColor(cs)
    local function rnc(l, r)
        return ma.random(l * 100, r * 100) * 0.01
    end
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end



local function addLeaf(x, y, w, cs)
    return { x = x, y = y, color = getColor(cs), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

local function get_branch(self, v, angle, oh)
    local l = #self.branches
    local cs_b, cs_l = self.cs_branch, self.cs_leaf
    local w, h = v.w * self.changeW, v.h * self.changeH
    local rtn = {}
    rtn.color = getColor(cs_b)
    rtn.deg, rtn.w, rtn.h = angle, w, h
    local nx = math.floor(v.n[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(v.n[2] + math.sin(angle * deg_to_rad) * h)
    rtn.n = {nx, ny}
    rtn.p = v.n
    local grow_leaf = ma.random(0, 10)
    if l > 2 and grow_leaf > self.leafChance  then
        rtn.leaf = addLeaf(ma.random(-w, w), ma.random(-2, 2), w * self.leafSize, cs_l)
    end
    -- add special variable of original height
    -- used for cactus grow function
    if oh then
        rtn.oh = oh * .7
    end
    return rtn
end

local function grow(self)
    local prev = self.branches[#self.branches]
    local row = {}
    if not prev then
        -- make one start branch if no branches given
        local w, h = self.w, self.h
        local p = {0, self.y}
        local n = {0, self.y - h}
        if not self.twoBranch then
            local b = {deg = -90, h = h, n = n, p = p, w = w}
            b.color = getColor(self.cs_branch)
            table.insert(row, b)
        else
            n = {ma.random(5, 10), self.y - h}
            local b1 = {deg = -100, h = h, n = n, p = p, w = w}
            b1.color = getColor(self.cs_branch)
            table.insert(row, b1)
            n = {ma.random(-10, -5), self.y - h}
            local b2 = {deg = -80, h = h, n = n, p = p, w = w}
            b2.color = getColor(self.cs_branch)
            table.insert(row, b2)
        end
        self.first = false
    else
        for _, v in ipairs(prev) do
            if v.oh and v.h ~= v.oh then
                v.h = v.oh
            end
            -- decide if branch should split into two
            local split = ma.random(0, 10)

            if split > self.splitChance or #prev < 3 and self.startSplit then
                local sa = self.splitAngle
                --- CACTUS
                if self.type == "cactus" then
                    table.insert(row, get_branch(self, v, -90))
                    local rd = v.deg + ma.random(30, 40) * ma.random(-1, 1)
                    local oh = v.h
                    v.h = oh * .6
                    table.insert(row, get_branch(self, v, rd, oh))
                else -- TREE
                    local rd = v.deg - ma.random(sa[1], sa[2])
                    table.insert(row, get_branch(self, v, rd))
                    rd = v.deg + ma.random(sa[1], sa[2])
                    table.insert(row, get_branch(self, v, rd))
                end
            else
                --CACTUS
                if self.type == "cactus" then
                    table.insert(row, get_branch(self, v, -90))
                else -- TREE
                    table.insert(row, get_branch(self, v, v.deg + ma.random(-10, 10)))
                end
            end
        end
    end
    return row
end

local function draw(self)
    local leaves = {}
    local x = self.x
    local l = #self.branches
    if l > 0 then
        for i, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                local leaf = v.leaf
                local px, py = v.p[1], v.p[2]
                local nx, ny = v.n[1], v.n[2]
                if i == l then
                    nx = px + (nx - px) / (self.growTime / self.growTimer)
                    ny = py + (ny - py) / (self.growTime / self.growTimer)
                    v.color[4] = (self.growTimer / self.growTime)
                    if leaf then
                        leaf.color[4] = (self.growTimer / self.growTime)
                    end
                end
                px, nx = x + px, x + nx
                gr.setColor(v.color)
                gr.setLineWidth(v.w * self.scale)
                gr.line(px, py, nx, ny)
                if leaf then
                    table.insert(leaves, {x = nx + leaf.x, y = ny + leaf.y, w = leaf.w, h = leaf.h, color = leaf.color })
                end
            end
        end
        for _, v in ipairs(leaves) do
            gr.setColor(v.color)
            gr.ellipse("fill", v.x, v.y, v.w, v.h)
        end
    end
end

local function update(self, dt)
    local l = #self.branches
    if (l > 0 or self.first) then
        if l < self.maxStage then
            self.growTimer = self.growTimer + dt
            if self.growTimer >= self.growTime then
                table.insert(self.branches, grow(self))
                self.growTimer = 0
            end
        end
    end
end


return {
    init = init,
    update = update,
    collided = collided,
    draw = draw,
    getHitbox = getHitbox,
}