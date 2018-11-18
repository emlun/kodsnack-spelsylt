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

local SophiaSprite = require("sprites.SophiaSprite")
local readonlytable = require("util.table").readonlytable


local Super_mt = { __index = SophiaSprite }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.hitbox_offsets = { left = 2, top = 1, right = 1, bottom = 0 }
Self.height = Self.hitbox_height + Self.hitbox_offsets.top + Self.hitbox_offsets.bottom
Self.width = Self.hitbox_width + Self.hitbox_offsets.left + Self.hitbox_offsets.right
Self.spritesheet = love.graphics.newImage("resources/sprites/sophia-hover.png")
Self.fire_framerate = 10

Self.spritesheet:setFilter("nearest", "nearest")

local turn_left = {
  love.graphics.newQuad(65, 89, 26, 17, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(93, 89, 26, 26, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(121, 89, 26, 34, Self.spritesheet:getDimensions()),
}

local turn_right = {
  love.graphics.newQuad(213, 89, 26, 17, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(185, 89, 26, 26, Self.spritesheet:getDimensions()),
  love.graphics.newQuad(157, 89, 26, 34, Self.spritesheet:getDimensions()),
}

Self.sprites = {
  left = {
    turn_right,
    turn_left,
    {
      love.graphics.newQuad(59, 52, 26, 17, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(90, 52, 26, 26, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(121, 52, 26, 34, Self.spritesheet:getDimensions()),
    }
  },
  right = {
    turn_left,
    turn_right,
    {
      love.graphics.newQuad(219, 52, 26, 17, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(188, 52, 26, 26, Self.spritesheet:getDimensions()),
      love.graphics.newQuad(157, 52, 26, 34, Self.spritesheet:getDimensions()),
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

function Self.get_frame (self, facing, turn_progress, time)
  local fire_frames = self:get_facing_and_turn_frame(facing, turn_progress)
  local fire_frame_index =
    math.min(
      math.floor(lume.pingpong(time * self.fire_framerate) * (#fire_frames + 1)) + 1,
      #fire_frames
    )

  return self.spritesheet, fire_frames[fire_frame_index]
end

return Self
