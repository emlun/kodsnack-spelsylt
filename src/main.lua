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

local bump = require("lib.bump")
local lovebird = require("lib.lovebird")
local lume = require("lib.lume")
local lurker = require("lib.lurker")

local SophiaSprite = require("sprites.sophia")
local Vector2 = require("util.Vector2")

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
local controlChangedTime = -math.huge
local maxSpeed = 300
local idleRetardation = maxSpeed / (controlWindupTime * 1.5)
local facingDirection = "right"
local facingChangeTimePrev = -math.huge
local facingChangeTime = -math.huge
local facingChangeDuration = 0.15
local klirr
local isTitleScreen = true
local titleImage

local controller = {
  jump = "space",
  left = "left",
  right = "right",
}

love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }

function init()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")

  sprite = SophiaSprite.new(facingChangeDuration)

  if not music then
    music = love.audio.newSource("resources/audio/main-theme.mp3", love.audio.SourceType.static)
    music:setLooping(true)
  end
  if not music:isPlaying() then love.audio.play(music) end

  klirr = {
    love.audio.newSource("resources/audio/klirr1.wav", love.audio.SourceType.static),
    love.audio.newSource("resources/audio/klirr2.wav", love.audio.SourceType.static),
    love.audio.newSource("resources/audio/klirr3.wav", love.audio.SourceType.static),
  }

  titleImage = love.graphics.newImage("resources/img/title/title.png")
end

init()

function love.load()
end

function setControl(newControl)
  control_prev = control
  control = newControl
  controlChangedTime = time

  if newControl == "left" and facingDirection == "right" then
    facingDirection = "left"
    facingChangeTimePrev = facingChangeTime
    facingChangeTime = time
  elseif newControl == "right" and facingDirection == "left" then
    facingDirection = "right"
    facingChangeTimePrev = facingChangeTime
    facingChangeTime = time
  end

end

function jump()
  love.audio.play(lume.randomchoice(klirr))
end

function love.keypressed(key, scancode, isrepeat)
  if isTitleScreen then
    if key == "return" then
      isTitleScreen = false
    end
  else
    if key == controller.left and control == nil then
      setControl("left")
    elseif key == controller.right and control == nil then
      setControl("right")
    elseif key == controller.jump then
      jump()
    end
  end
end

function love.keyreleased(key, scancode)
  if key == controller.left and love.keyboard.isDown(controller.right) then
    setControl("right")
  elseif key == controller.right and love.keyboard.isDown(controller.left) then
    setControl("left")
  elseif key == controller.left or key == controller.right then
    setControl(nil)
  end
end

function love.update(dt)
  lovebird.update()
  lurker.update()
  time = time + dt

  if not isTitleScreen then
    target_camera_pos = Vector2.zero
    target_camera_scale = 1

    camera_pos = lume.lerp(camera_pos, target_camera_pos, 0.8 * dt)
    camera_scale = lume.lerp(camera_scale, target_camera_scale, 0.8 * dt)

    if control == "left" then
      controlAcceleration = Vector2(-maxSpeed / controlWindupTime, 0)
    elseif control == "right" then
      controlAcceleration = Vector2(maxSpeed / controlWindupTime, 0)
    else
      controlAcceleration = math.min(vel:mag() / dt, idleRetardation) * Vector2(vel.x > 0 and -1 or 1, 0)
    end

    vel = vel + controlAcceleration * dt
    vel = vel:normalized() * math.min(maxSpeed, vel:mag())

    pos = pos + vel * dt
  end
end

local function world_to_view_pos(pos, camera_pos, camera_scale, canvas_size)
  return camera_scale * (pos - camera_pos) + 0.5 * canvas_size
end


function love.draw()
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()
  local dimensions = Vector2(W, H)

  if isTitleScreen then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
      titleImage,
      W / 2 - titleImage:getWidth() / 2,
      H * (1 - 1 / 1.618) - titleImage:getHeight() / 2 + math.sin(time * 2 * math.pi / 10) * 10
    )

    local pressReturnDelay = 3
    if time > pressReturnDelay then
      local text = love.graphics.newText(love.graphics.newFont(12), "Tryck [RETUR]")
      local t = (time - pressReturnDelay) * 2 * math.pi / 5
      love.graphics.setColor(0.8, 0.8, 0.8, 0.5 - math.cos(t) * 0.4)
      love.graphics.draw(text, W / 2 - text:getWidth() / 2, H / 1.618 - text:getHeight() / 2)
    end
  else
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle(love.graphics.DrawMode.fill, 0, H / 2, W, H)

    local scale = 2

    local timeSinceTurn = time - facingChangeTime

    local spritesheet, spriteFrame = sprite:getQuad(facingDirection, timeSinceTurn, 0, pos.x, scale)
    local spriteViewport = {spriteFrame:getViewport()}

    local viewPos = world_to_view_pos(pos, camera_pos, camera_scale, dimensions)

    love.graphics.draw(
      spritesheet,
      spriteFrame,
      viewPos.x - (spriteViewport[3] / 2) * scale,
      viewPos.y - (spriteViewport[4]) * scale,
      0,
      scale,
      scale
    )
  end
end
