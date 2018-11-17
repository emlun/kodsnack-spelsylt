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

local mymath = require("util.math")
local readonlytable = require("util.table").readonlytable


local wheelFramerate = 1 / (8 * math.pi)

local width = 25
local height = 17
local spritesheet = love.graphics.newImage("resources/sophia.png")

local turnLeft = {
  love.graphics.newQuad(11, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(44, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(76, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(110, 80, width, height, spritesheet:getDimensions()),
}

local turnRight = {
  love.graphics.newQuad(145, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(178, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(210, 80, width, height, spritesheet:getDimensions()),
  love.graphics.newQuad(243, 80, width, height, spritesheet:getDimensions()),
}

local sprites = {
  left = {
    turnRight,
    turnLeft,
    {
      love.graphics.newQuad(13, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(44, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(77, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(109, 5, width, height, spritesheet:getDimensions()),
    }
  },
  right = {
    turnLeft,
    turnRight,
    {
      love.graphics.newQuad(146, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(178, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(211, 5, width, height, spritesheet:getDimensions()),
      love.graphics.newQuad(242, 5, width, height, spritesheet:getDimensions()),
    }
  },
}

local Sprite = {}

function Sprite.new (scale, turnDuration)
  return readonlytable(
    setmetatable(
      {
        scale = assert(scale),
        turnDuration = assert(turnDuration),
      },
      {
        __index = Sprite,
      }
    )
  )
end

function Sprite.getDimensions (self)
  return width * self.scale, height * self.scale
end

function Sprite.getHitbox (self, x, y)
  x = x or 0
  y = y or 0
  local dx = 2
  local dy = 1
  return
    x + dx * self.scale,
    y + dy * self.scale,
    (width - dx - 2) * self.scale,
    (height - dy - 2) * self.scale
end

function Sprite.getQuad (self, facing, timeSinceTurn, wheelOrigin, wheelX)
  local facingSprite = sprites[facing]

  local turnFrameIndex = math.floor(math.min(
    #facingSprite,
    math.max(0, timeSinceTurn) / self.turnDuration * #facingSprite + 1
  ))

  if not mymath.isFinite(turnFrameIndex) then
    turnFrameIndex = #facingSprite
  end

  local wheelFrames = facingSprite[turnFrameIndex]
  local wheelFrameIndex =
    (math.floor((wheelX - wheelOrigin) / self.scale * wheelFramerate * #wheelFrames) % #wheelFrames) + 1

  return spritesheet, wheelFrames[wheelFrameIndex]
end

return Sprite
