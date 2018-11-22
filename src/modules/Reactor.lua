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

local Icons = require("sprites.Icons")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }

Self.type = "reactor"
Self.name = texts.drone.module.reactor.name
Self.description = texts.drone.module.reactor.description
Self.icon = Icons.battery
Self.recharge_rate = 2

function Self.new ()
  return setmetatable({}, Self_mt)
end

function Self.update_drone (self, drone, dt)
  drone.battery:add(self.recharge_rate * dt)
end

return Self
