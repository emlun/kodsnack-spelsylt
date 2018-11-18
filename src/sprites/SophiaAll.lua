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

local readonlytable = require("util.table").readonlytable
local SophiaHover = require("sprites.SophiaHover")
local SophiaNormal = require("sprites.Sophia")
local SophiaSprite = require("sprites.SophiaSprite")


local Super_mt = { __index = SophiaSprite }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

function Self.new (scale)
  return readonlytable(
    setmetatable(
      {
        scale = assert(scale),
        ground_sprite = SophiaNormal.new(scale),
        hover_sprite = SophiaHover.new(scale),
      },
      Self_mt
    )
  )
end

function Self.get_offset_position (self, hover, pos)
  if hover then
    return self.hover_sprite:get_offset_position(pos)
  else
    return self.ground_sprite:get_offset_position(pos)
  end
end

function Self.get_frame (self, hover, facing, turn_progress, wheel_x, time)
  if hover then
    return self.hover_sprite:get_frame(facing, turn_progress, time)
  else
    return self.ground_sprite:get_frame(facing, turn_progress, wheel_x)
  end
end

return Self
