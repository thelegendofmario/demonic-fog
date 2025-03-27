local ldtk = require "resources.libraries.ldtk.ldtk"
local class = require 'resources.libraries.classic.classic'
local config = require 'resources.config'
local object = require 'resources.objects'

local phys = class:extend()
local player = class:extend()

local objects = {}
local collObjects = {}





function phys:new(entity, typeofbody)
    local typeofbody = typeofbody or "static"
    self.body = love.physics.newBody(world, entity.x+(entity.width/2), entity.y+(entity.height/2), typeofbody)
    self.shape = love.physics.newRectangleShape(0, 0, entity.width, entity.height, 0)
    self.fixture = love.physics.newFixture(self.body, self.shape)
end

function phys:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end


function player:new(entity)
    self.body = love.physics.newBody(world, entity.x, entity.y, "dynamic")
    self.shape = love.physics.newRectangleShape(entity.x, entity.y, entity.width, entity.height, 0)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function player:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end


function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 10, true)
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

    ldtk:load("resources/art/tilemaps/map.ldtk")
    ldtk:setFlipped(true)
    function ldtk.onEntity(entity)
        if not entity.props.collision and not entity.props.player then
            local n_obj = object(entity)
            table.insert(objects, n_obj)
        elseif entity.props.player then
            main = player(entity)
        else
            local n_obj = phys(entity)
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
    -- draw tilemap & entities. DO NOT REMOVE :)
    for _, obj in ipairs(objects) do
        obj:draw()
    end
    if config.drawPhysics then
        for _, obj in ipairs(collObjects) do
            obj:draw()
        end
    end

    main:draw()

    
end

function love.update(dt)
    world:update(dt)
    mx, my = love.mouse.getPosition()
    x, y = main.body:getWorldCenter()

    if love.keyboard.isDown("right") then
        main.body:applyForce(config.playerSpeed*dt, 0)
    elseif love.keyboard.isDown("left") then
        main.body:applyForce(-config.playerSpeed*dt, 0)
    end

    if love.keyboard.isDown("up") then
        main.body:applyForce(0, -config.playerSpeed*dt)
    elseif love.keyboard.isDown("down") then
        main.body:applyForce(0, config.playerSpeed*dt)
    end

    angle = math.atan2((my-y), (mx-x))
    print((my-y),(mx-x),angle)
    main.body:setAngle(angle)

end