-- Scrounge
-- Copyright (C) 2018  Emil Lundberg
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- luacheck: globals love

local Entity = require("entities.Entity")

local Super_mt = { __index = Entity }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.type = "module"
Self.scale = 2

function Self.new (module, position)
  return setmetatable(
    {
      module = assert(module),
      position = assert(position),
      time = 0,
    },
    Self_mt
  )
end

function Self.get_hitbox (self)
  return self.position.x, self.position.y, self.module.icon.width * self.scale, self.module.icon.height * self.scale
end

function Self.update (self, dt)
  self.time = self.time + dt
end

function Self.draw (self, camera)
  local spritesheet, sprite = self.module.icon:get_sprite()

  local view_pos = camera:project(self.position)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    spritesheet,
    sprite,
    view_pos.x,
    view_pos.y,
    0,
    self.scale,
    self.scale
  )

  self:draw_hitbox(camera)
end

return Self
