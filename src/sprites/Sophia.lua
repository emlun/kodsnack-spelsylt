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

local SophiaSprite = require("sprites.SophiaSprite")
local readonlytable = require("util.table").readonlytable


local Super_mt = { __index = SophiaSprite }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.height = 18
Self.hitbox_offsets = { left = 2, top = 1, right = 1, bottom = 0 }
Self.spritesheet = love.graphics.newImage("resources/sprites/sophia.png")
Self.wheel_framerate = 1 / (8 * math.pi)
Self.width = 26

Self.spritesheet:setFilter("nearest", "nearest")

local turn_left = {
  love.graphics.newQuad(11, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(44, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(76, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(110, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
}

local turn_right = {
  love.graphics.newQuad(145, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(178, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(210, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(243, 80, Self.width, Self.height, Self.spritesheet:getDimensions()),
}

Self.sprites = {
  left = {
    turn_right,
    turn_left,
    {
      love.graphics.newQuad(13, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(44, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(77, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(109, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
    }
  },
  right = {
    turn_left,
    turn_right,
    {
      love.graphics.newQuad(146, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(178, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(211, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(242, 5, Self.width, Self.height, Self.spritesheet:getDimensions()),
    }
  },
}

function Self.new (scale)
  return readonlytable(
    setmetatable(
      {
        scale = assert(scale),
      },
      Self_mt
    )
  )
end

function Self.get_frame (self, facing, turn_progress, wheel_x)
  local wheel_frames = self:get_facing_and_turn_frame(facing, turn_progress)
  local wheel_frame_index =
    (math.floor(wheel_x / self.scale * self.wheel_framerate * #wheel_frames) % #wheel_frames) + 1

  return self.spritesheet, wheel_frames[wheel_frame_index]
end

return Self
