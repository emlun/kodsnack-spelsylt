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

local Sprite = require("sprites.Sprite")
local mymath = require("util.math")


local Super_mt = { __index = Sprite }

local Self = setmetatable({}, Super_mt)

Self.hitbox_height = 17
Self.hitbox_width = 23

function Self.get_facing_and_turn_frame (self, facing, turn_progress)
  local facing_sprite = self.sprites[facing]

  local turn_frame_index = math.floor(math.min(
    #facing_sprite,
    turn_progress * (#facing_sprite - 1) + 1
  ))

  if not mymath.is_finite(turn_frame_index) then
    turn_frame_index = #facing_sprite
  end

  return facing_sprite[turn_frame_index]
end

function Self.get_hitbox_dimensions (self)
  return self.hitbox_width * self.scale, self.hitbox_height * self.scale
end

return Self
