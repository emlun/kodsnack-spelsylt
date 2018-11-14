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
local pos = Vector2.zero
local vel = Vector2.zero
local controlWindupTime = 0.15
local controlAcceleration = Vector2.zero
local control_prev = nil
local control = nil
local controlChangedTime = time
local maxSpeed = 300
local idleRetardation = maxSpeed / (controlWindupTime * 1.5)
local facingDirection = "right"

local controller = {
  left = "left",
  right = "right",
}

love.graphics.DrawMode = { fill = "fill", line = "line" }

function love.load()
  math.randomseed(os.time())
  spritesheet = love.graphics.newImage("resources/sophia.png")
  sprites = {
    left = {
      love.graphics.newQuad(13, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(44, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(77, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(109, 5, 25, 17, spritesheet:getDimensions()),
    },
    right = {
      love.graphics.newQuad(146, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(178, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(211, 5, 25, 17, spritesheet:getDimensions()),
      love.graphics.newQuad(242, 5, 25, 17, spritesheet:getDimensions()),
    },
  }
end

function setControl(newControl)
    control_prev = control
    control = newControl
    controlChangedTime = time
end

function love.keypressed(key, scancode, isrepeat)
  if key == controller.left and control == nil then
    setControl("left")
  elseif key == controller.right and control == nil then
    setControl("right")
  end
end

function love.keyreleased(key, scancode)
  if
    (key == controller.left and control == "left")
    or (key == controller.right and control == "right")
  then
    setControl(nil)
  end
end

function love.update(dt)
  time = time + dt

  target_camera_pos = Vector2.zero
  target_camera_scale = 1

  camera_pos = mymath.lerp(camera_pos, target_camera_pos, 0.8 * dt)
  camera_scale = mymath.lerp(camera_scale, target_camera_scale, 0.8 * dt)

  if control == "left" then
    controlAcceleration = Vector2(-maxSpeed / controlWindupTime, 0)
  elseif control == "right" then
    controlAcceleration = Vector2(maxSpeed / controlWindupTime, 0)
  else
    controlAcceleration = math.min(vel:mag() / dt, idleRetardation) * Vector2(vel.x > 0 and -1 or 1, 0)
  end

  vel = vel + controlAcceleration * dt
  vel = vel:normalized() * math.min(maxSpeed, vel:mag())

  if control == "left" then
    facingDirection = "left"
  elseif control == "right" then
    facingDirection = "right"
  end

  pos = pos + vel * dt
end

local function world_to_view_pos(pos, camera_pos, camera_scale, canvas_size)
  return camera_scale * (pos - camera_pos) + 0.5 * canvas_size
end


function love.draw()
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()
  local dimensions = Vector2(W, H)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle(love.graphics.DrawMode.fill, 0, H / 2, W, H)

  local scale = 2
  local spriteWheelIndex = (math.floor(pos.x / 25 * scale) % #sprites.left) + 1

  local sprite = sprites[facingDirection][spriteWheelIndex]
  local spriteViewport = {sprite:getViewport()}

  local viewPos = world_to_view_pos(pos, camera_pos, camera_scale, dimensions)

  love.graphics.draw(
    spritesheet,
    sprite,
    viewPos.x - (spriteViewport[3] / 2) * scale,
    viewPos.y - (spriteViewport[4]) * scale,
    0,
    scale,
    scale
  )
end
