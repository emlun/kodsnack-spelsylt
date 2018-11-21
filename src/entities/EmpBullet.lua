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

local lume = require("lib.lume")

local Entity = require("entities.Entity")
local Vector2 = require("util.Vector2")


local Super_mt = { __index = Entity }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.colors = {
  { 0, 1, 1, 0.8 },
  { 0.7, 1, 1, 0.8 },
}
Self.color_period = 1
Self.radius = 5
Self.speed = 400
Self.type = "emp-bullet"
Self.velocity = Vector2.zero

function Self.new (center_position, direction)
  local _, _, width, height = Self.get_hitbox(setmetatable({ position = center_position }, Self_mt))
  return setmetatable(
    {
      position = center_position - 0.5 * Vector2(width, height),
      time = 0,
      velocity = Self.speed * direction:normalized(),
    },
    Self_mt
  )
end

function Self.get_color (self)
  local t = lume.pingpong(self.time / self.color_period)
  return lume.map({1, 2, 3, 4}, function (index)
    return lume.lerp(self.colors[1][index], self.colors[2][index], t)
  end)
end

function Self.get_hitbox (self)
  return
    self.position.x,
    self.position.y,
    2 * self.radius,
    2 * self.radius
end

function Self.filter_collisions (self, other)
  if other.will_collide_with then
    if other:will_collide_with(self) then
      return "touch"
    else
      return "cross"
    end
  else
    return "touch"
  end
end

function Self.update (self, dt, world)
  self.time = self.time + dt

  local goal_x, goal_y = (self.position + self.velocity * dt):unpack()
  local actual_x, actual_y, collisions = world:move(
    self,
    goal_x, goal_y,
    self.filter_collisions
  )
  self.position = Vector2(actual_x, actual_y)

  for _, collision in ipairs(collisions) do
    if collision.type == "touch" or collision.type == "slide" then
      if collision.other.collide then
        collision.other:collide(self, dt, world)
      end

      world:remove(self)
      break
    end
  end
end

function Self.draw (self, camera)
  local center_x, center_y = camera:project(self:get_center()):unpack()

  love.graphics.setColor(self:get_color())
  love.graphics.circle("fill", center_x, center_y, self.radius)

  self:draw_hitbox(camera)
end

return Self
