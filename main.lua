local ldtk = require "resources.libraries.ldtk.ldtk"
local objects = {}
local collObjects = {}

local class = require 'resources.libraries.classic.classic'
local object = class:extend()

function object:new(entity)
    self.x, self.y = entity.x, entity.y
    self.w, self.h = entity.width, entity.height
    self.visible = entity.visible
    self.props = entity.props
end

function object:draw()
    if self.visible and not self.props.collision then
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end
end
local box = class:extend()

function box:new(entity)
    self.body = love.physics.newBody(world, entity.x+(entity.width/2), entity.y+(entity.height/2))
    self.shape = love.physics.newRectangleShape(0, 0, entity.width, entity.height, 0)
    self.fixture = love.physics.newFixture(self.body, self.shape)
end

function box:draw()
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function love.load()
    world = love.physics.newWorld(0, 0, true)


    love.window.setMode(512, 512)

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

    ldtk:load("resources/art/tilemaps/map.ldtk")
    ldtk:setFlipped(true)
    function ldtk.onEntity(entity)
        if not entity.props.collision then
            local n_obj = object(entity)
            table.insert(objects, n_obj)
        else
            local n_obj = box(entity)
            table.insert(collObjects, n_obj)
        end
    end

    function ldtk.onLayer(layer)
        table.insert(objects, layer)
    end

    function ldtk.onLevelLoaded(level)
        objects = {}

        love.graphics.setBackgroundColor(level.backgroundColor)
    end

    function ldtk.onLevelCreated(level)
        if level.props.create then
            load(level.props.create)()
        end
    end

    ldtk:level("Level_0")
end

function love.draw()
    love.graphics.scale(2, 2)

    for _, obj in ipairs(objects) do
        obj:draw()
    end

    for _, obj in ipairs(collObjects) do
        obj:draw()
    end
end

function love.update(dt)
    world:update(dt)
end