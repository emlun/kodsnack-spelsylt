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

local Constants = require("constants")
local Icons = require("sprites.Icons")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }

Self.type = "hover"
Self.name = texts.drone.module.hover.name
Self.description = texts.drone.module.hover.description
Self.acceleration = Constants.gravity * -1.1
Self.control = "hover"
Self.fuel_cost_rate = 0.1
Self.icon = Icons.rocket

function Self.new ()
  return setmetatable({}, Self_mt)
end

return Self
