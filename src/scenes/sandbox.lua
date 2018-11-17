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

local Player = require("player")
local SophiaSprite = require("sprites.sophia")
local Vector2 = require("util.Vector2")


love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }


local facingChangeDuration = 0.15
local klirr = {
  love.audio.newSource("resources/audio/klirr1.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr2.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr3.wav", love.audio.SourceType.static),
}
local sprite = SophiaSprite.new(facingChangeDuration)


local Scene = {}

function Scene.new (controller)
  return setmetatable(
    {
      camera_position = Vector2.zero,
      camera_scale = 1,
      player = Player.new(controller, { jump = klirr }),
      target_camera_pos = Vector2.zero,
      target_camera_scale = 1,
      time = 0,
    },
    {
      __index = Scene,
    }
  )
end

function Scene.keypressed (self, key)
  self.player:keypressed(key, self.time)
end

function Scene.keyreleased (self, key)
  self.player:keyreleased(key, self.time)
end

function Scene.update (self, dt)
  self.time = self.time + dt

  self.target_camera_pos = Vector2.zero
  self.target_camera_scale = 1

  self.camera_position = lume.lerp(self.camera_position, self.target_camera_pos, 0.8 * dt)
  self.camera_scale = lume.lerp(self.camera_scale, self.target_camera_scale, 0.8 * dt)

  self.player:update(dt)
end

local function world_to_view_pos(pos, camera_pos, camera_scl, canvas_size)
  return camera_scl * (pos - camera_pos) + 0.5 * canvas_size
end

function Scene.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()
  local dimensions = Vector2(W, H)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle(love.graphics.DrawMode.fill, 0, H / 2, W, H)

  local scale = 2

  local timeSinceTurn = self.time - self.player.facingChangeTime

  local spritesheet, spriteFrame = sprite:getQuad(
    self.player.facingDirection,
    timeSinceTurn,
    0,
    self.player.position.x,
    scale
  )
  local spriteViewport = {spriteFrame:getViewport()}

  local viewPos = world_to_view_pos(
    self.player.position,
    self.camera_position,
    self.camera_scale,
    dimensions
  )

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

return Scene
