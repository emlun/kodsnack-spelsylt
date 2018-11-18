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

local module = {}

function module.arrow (from, to, camera, color)
  color = color or { 0, 1, 0, 1 }
  love.graphics.setColor(unpack(color))

  local from_x, from_y = camera:project(from):unpack()
  local to_x, to_y = camera:project(to):unpack()
  local wing_left = to + (from - to):rotate(math.pi / 8):normalized() * 10
  local wing_right = to + (from - to):rotate(-math.pi / 8):normalized() * 10

  love.graphics.line(from_x, from_y, to_x, to_y)
  love.graphics.line(to_x, to_y, camera:project(wing_left):unpack())
  love.graphics.line(to_x, to_y, camera:project(wing_right):unpack())
end

return module
