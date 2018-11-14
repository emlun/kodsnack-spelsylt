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

package.path = package.path .. ";./src/?.lua"
local Vector2 = require("util.Vector2")
local mymath = require("util.math")

local camera_pos = Vector2(0, 0)
local camera_scale = 1
local target_camera_pos = camera_pos
local target_camera_scale = camera_scale
local time = 0

local spritesheet
local sprites

love.graphics.DrawMode = { fill = "fill", line = "line" }

function love.load()
  math.randomseed(os.time())
  spritesheet = love.graphics.newImage("resources/sophia.png")
  sprites = {
    left = {
      love.graphics.newQuad(13, 5, 25, 17, spritesheet:getDimensions()),
    },
  }
end

function love.update(dt)
  time = time + dt

  target_camera_pos = Vector2.zero
  target_camera_scale = 1

  camera_pos = mymath.lerp(camera_pos, target_camera_pos, 0.8 * dt)
  camera_scale = mymath.lerp(camera_scale, target_camera_scale, 0.8 * dt)

end

local function world_to_view_pos(pos, camera_pos, camera_scale, canvas_size)
  return camera_scale * (pos - camera_pos) + 0.5 * canvas_size
end


function love.draw()
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle(love.graphics.DrawMode.fill, 0, H * 2 / 3, W, H)

  local sprite = sprites.left[1]
  local spriteViewport = {sprite:getViewport()}
  local scale = 2

  love.graphics.draw(
    spritesheet,
    sprite,
    W / 2 - (spriteViewport[3] / 2) * scale,
    H * 2 / 3 - (spriteViewport[4]) * scale,
    0,
    scale,
    scale
  )
end
