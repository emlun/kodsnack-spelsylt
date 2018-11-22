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

local Icons = require("sprites.Icons")
local Vector2 = require("util.Vector2")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }

Self.type = "jump"
Self.name = texts.drone.module.jump.name
Self.description = texts.drone.module.jump.description
Self.battery_cost = 10
Self.icon = Icons.jump
Self.sfx = {
  love.audio.newSource("resources/audio/klirr1.wav", "static"),
  love.audio.newSource("resources/audio/klirr2.wav", "static"),
  love.audio.newSource("resources/audio/klirr3.wav", "static"),
}
Self.speed = 800

function Self.new ()
  return setmetatable({}, Self_mt)
end

function Self.jump (self, drone, world)
  if drone:has_ground_below(world) then
    lume.randomchoice(self.sfx):play()
    local efficiency = drone.battery:consume(self.battery_cost)
    drone.velocity = drone.velocity + Vector2(0, -self.speed * efficiency)
  end
end

return Self
