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

local readonlytable = require("util.table").readonlytable


local Self = {}
local Self_mt = { __index = Self }

Self.height = 16
Self.width = 16

local function new (name)
  return readonlytable(setmetatable(
    { name = name },
    Self_mt
  ))
end

Self.spritesheet = love.graphics.newImage("resources/sprites/icons/icons.png")
Self.spritesheet:setFilter("nearest", "nearest")

Self.sprites = {
  jump =
    love.graphics.newQuad(0 * Self.width, 0, Self.width, Self.height, Self.spritesheet:getDimensions()),
  battery =
    love.graphics.newQuad(1 * Self.width, 0, Self.width, Self.height, Self.spritesheet:getDimensions()),
  rocket =
    love.graphics.newQuad(2 * Self.width, 0, Self.width, Self.height, Self.spritesheet:getDimensions()),
  mustache =
    love.graphics.newQuad(3 * Self.width, 0, Self.width, Self.height, Self.spritesheet:getDimensions()),
  spark =
    love.graphics.newQuad(4 * Self.width, 0, Self.width, Self.height, Self.spritesheet:getDimensions()),
}

for name in pairs(Self.sprites) do
  Self[name] = new(name)
end

function Self.get_sprite (self)
  return self.spritesheet, self.sprites[self.name]
end

return Self
