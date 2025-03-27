local class = require 'resources.libraries.classic.classic'
local object = class:extend()

function object:new(entity)
    self.x, self.y = entity.x, entity.y
    self.w, self.h = entity.width, entity.height
    self.visible = entity.visible
    self.props = entity.props
end

function object:draw()
    if self.visible then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end
end

return object