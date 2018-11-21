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

local Sophia = require("sprites.Sophia")
local Vector2 = require("util.Vector2")
local readonlytable = require("util.table").readonlytable


local Self = {}
local Self_mt = { __index = Self }

Self.height = 27
Self.width = 46
Self.hitbox_offsets = {}
Self.hitbox_offsets.right = Vector2(6, 7)
Self.hitbox_offsets.left = Vector2(
  Self.width - Sophia.hitbox_width - Self.hitbox_offsets.right.x,
  Self.hitbox_offsets.right.y
)

Self.spritesheet = love.graphics.newImage("resources/sprites/disguise/disguise.png")
Self.sprites = lume.map({0, 1, 2}, function (index)
  return {
    right = love.graphics.newQuad(
      0, index * Self.height,
      Self.width, Self.height,
      Self.spritesheet:getDimensions()
    ),
    left = love.graphics.newQuad(
      Self.width, index * Self.height,
      Self.width, Self.height,
      Self.spritesheet:getDimensions()
    ),
  }
end)

Self.spritesheet:setFilter("nearest", "nearest")

function Self.new (index, scale)
  return readonlytable(
    setmetatable(
      {
        index = assert(index),
        scale = assert(scale),
      },
      Self_mt
    )
  )
end

function Self.get_frame (self, facing)
  return self.spritesheet, self.sprites[self.index][facing]
end

return Self
