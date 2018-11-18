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

local Vector2 = require("util.Vector2")
local mymath = require("util.math")
local readonlytable = require("util.table").readonlytable


local wheel_framerate = 1 / (8 * math.pi)

local width = 26
local height = 18
local spritesheet = love.graphics.newImage("resources/sprites/sophia.png")
spritesheet:setFilter("nearest", "nearest")

local turn_left = {
  love.graphics.newQuad(11, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(44, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(76, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(110, 80, width, height, spritesheet:getDimensions()),
}

local turn_right = {
  love.graphics.newQuad(145, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(178, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(210, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(243, 80, width, height, spritesheet:getDimensions()),
}

local sprites = {
  left = {
    turn_right,
    turn_left,
    {
      love.graphics.newQuad(13, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(44, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(77, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(109, 5, width, height, spritesheet:getDimensions()),
    }
  },
  right = {
    turn_left,
    turn_right,
    {
      love.graphics.newQuad(146, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(178, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(211, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(242, 5, width, height, spritesheet:getDimensions()),
    }
  },
}

local Self = {}

function Self.new (scale)
  return readonlytable(
    setmetatable(
      {
        hitbox_offsets = { left = 2, top = 1, right = 1, bottom = 0 },
        scale = assert(scale),
      },
      {
        __index = Self,
      }
    )
  )
end

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
    (width - self.hitbox_offsets.left - self.hitbox_offsets.right) * self.scale,
    (height - self.hitbox_offsets.top - self.hitbox_offsets.bottom) * self.scale
end

function Self.get_frame (self, facing, turn_duration, time_since_turn, wheel_origin, wheel_x)
  local facing_sprite = sprites[facing]

  local turn_frame_index = math.floor(math.min(
    #facing_sprite,
    math.max(0, time_since_turn) / turn_duration * (#facing_sprite - 1) + 1
  ))

  if not mymath.is_finite(turn_frame_index) then
    turn_frame_index = #facing_sprite
  end

  local wheel_frames = facing_sprite[turn_frame_index]
  local wheel_frame_index =
    (math.floor((wheel_x - wheel_origin) / self.scale * wheel_framerate * #wheel_frames) % #wheel_frames) + 1

  return spritesheet, wheel_frames[wheel_frame_index]
end

return Self
