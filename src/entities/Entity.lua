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
local mydebug = require("src.debug")


local Self = {}


function Self.can_move (self, displacement, world)
  local _, _, collisions = world:check(self, Vector2.unpack(self.position + displacement))
  for _, collision in pairs(collisions) do
    if collision.type == "touch" or collision.type == "slide" or collision.type == "bounce" then
      return false
    end
  end

  return true
end

function Self.draw (self)
  mydebug.print("Unimplemented draw for type: " .. tostring(self.type))
  mydebug.print(debug.traceback())
end

function Self.get_hitbox ()
  error("Not implemented")
end

function Self.get_center (self)
  local x, y, w, h = self:get_hitbox()
  return Vector2(x + w / 2, y + h / 2)
end

function Self.has_ground_below (self, world)
  return not self:can_move(Vector2(0, 5), world)
end

function Self.pull_in_direction (self, world, direction)
  local dx, dy = Vector2.unpack(self.position + direction:normalized() * 10000)
  self.position = Vector2(world:move(self, dx, dy, function () return "touch" end))
end

function Self.pull_to_ground (self, world)
  self:pull_in_direction(world, Vector2(0, 1))
end

function Self.update (self)
  mydebug.print("Unimplemented update for type: " .. tostring(self.type))
  mydebug.print(debug.traceback())
end

function Self.draw_hitbox (self, camera)
  if mydebug.hitboxes then
    for draw_mode, alpha in pairs({ [love.graphics.DrawMode.line] = 1, [love.graphics.DrawMode.fill] = 0.2 }) do
      love.graphics.setColor(0, 1, 0, alpha)
      love.graphics.rectangle(
        draw_mode,
        camera:project_rect(self:get_hitbox())
      )
    end
  end
end

return Self
