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
local Sprite = require("sprites.Disguise")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }

Self.type = "disguise"
Self.name = texts.drone.module.disguise.name
Self.description = texts.drone.module.disguise.description
Self.icon = Icons.mustache

function Self.new (sprite_index)
  sprite_index = sprite_index or math.floor(lume.random(0, 1) * #Sprite.sprites) + 1
  return setmetatable(
    {
      sprite = Sprite.new(sprite_index, 2),
    },
    Self_mt
  )
end

function Self.draw (self, camera, drone_hitbox_position, drone_facing, drone_sprite_scale)
  local spritesheet, sprite_frame = self.sprite:get_frame(drone_facing)

  local x, y = camera:project(drone_hitbox_position - self.sprite.hitbox_offsets[drone_facing] * drone_sprite_scale):unpack()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    spritesheet,
    sprite_frame,
    x,
    y,
    0,
    self.sprite.scale,
    self.sprite.scale
  )
end

return Self
