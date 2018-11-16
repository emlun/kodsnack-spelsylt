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

local mymath = require("util.math")
local readonlytable = require("util.table").readonlytable

local spritesheet
local sprites

local wheelFramerate = 1 / (8 * math.pi)

local Sprite = {}

function init ()
  spritesheet = love.graphics.newImage("resources/sophia.png")

  local turnLeft = {
    love.graphics.newQuad(11, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(44, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(76, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(110, 80, 25, 17, spritesheet:getDimensions()),
  }

  local turnRight = {
    love.graphics.newQuad(145, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(178, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(210, 80, 25, 17, spritesheet:getDimensions()),
    love.graphics.newQuad(243, 80, 25, 17, spritesheet:getDimensions()),
  }

  sprites = {
    left = {
      turnRight,
      turnLeft,
      {
        love.graphics.newQuad(13, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(44, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(77, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(109, 5, 25, 17, spritesheet:getDimensions()),
      }
    },
    right = {
      turnLeft,
      turnRight,
      {
        love.graphics.newQuad(146, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(178, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(211, 5, 25, 17, spritesheet:getDimensions()),
        love.graphics.newQuad(242, 5, 25, 17, spritesheet:getDimensions()),
      }
    },
  }
end

function getQuad (self, facing, timeSinceTurn, wheelOrigin, wheelX, scale)
  local facingSprite = sprites[facing]

  local turnFrameIndex = math.floor(math.min(
    #facingSprite,
    math.max(0, timeSinceTurn) / self.turnDuration * #facingSprite + 1
  ))

  if not mymath.isFinite(turnFrameIndex) then
    turnFrameIndex = #facingSprite
  end

  local wheelFrames = facingSprite[turnFrameIndex]
  local wheelFrameIndex = (math.floor(wheelX / scale * wheelFramerate * #wheelFrames) % #wheelFrames) + 1

  return spritesheet, wheelFrames[wheelFrameIndex]
end

function Sprite.new (turnDuration)
  return readonlytable{
    turnDuration = assert(turnDuration),
    getQuad = getQuad,
  }
end

init()
return readonlytable(Sprite)
