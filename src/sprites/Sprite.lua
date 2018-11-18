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


local Self = {}

function Self.get_offset_position (self, pos)
  return pos - Vector2(self.hitbox_offsets.left, self.hitbox_offsets.top) * self.scale
end

function Self.get_hitbox (self, x, y)
  x = x or 0
  y = y or 0
  return
    x,
    y,
    self:get_hitbox_dimensions()
end

function Self.get_hitbox_dimensions (self)
  return
    (self.width - self.hitbox_offsets.left - self.hitbox_offsets.right) * self.scale,
    (self.height - self.hitbox_offsets.top - self.hitbox_offsets.bottom) * self.scale
end

return Self
