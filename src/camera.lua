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

local Vector2 = require("util.Vector2")


local Camera = {}
local Camera_mt = { __index = Camera }

function Camera.new (dimensions, pos, scale)
  return setmetatable(
    {
      center_offset = 0.5 * dimensions,
      pos = pos,
      scale = scale or 1,
    },
    Camera_mt
  )
end

function Camera.set_dimensions (self, dimensions)
  self.center_offset = 0.5 * dimensions
end

function Camera.move_to (self, pos)
  self.pos = pos
end

function Camera.project(self, pos)
  return self.scale * (pos - self.pos) + self.center_offset
end

function Camera.project_rect(self, x, y, w, h)
  local topleft = self:project(Vector2(x, y))
  return topleft.x, topleft.y, Vector2.unpack(Vector2(w, h) * self.scale)
end

function Camera.project_line(self, v1, v2)
  local topleft = self:project(v1)
  return topleft.x, topleft.y, self:project(v2):unpack()
end

return Camera
