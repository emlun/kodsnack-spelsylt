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

local bump = require("lib.bump")
local lume = require("lib.lume")

local debug = require("src.debug")
local Player = require("player")
local SophiaSprite = require("sprites.sophia")
local Vector2 = require("util.Vector2")


love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }


local facingChangeDuration = 0.6
local klirr = {
  love.audio.newSource("resources/audio/klirr1.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr2.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr3.wav", love.audio.SourceType.static),
}
local sprite = SophiaSprite.new(2, facingChangeDuration)


local Scene = {}

function Scene.new (controller)
  local world = bump.newWorld()
  local ground = { id = "ground", rect = { -1000, 0, 2000, world.cellSize } }
  local player = Player.new(sprite, facingChangeDuration, controller, { jump = klirr })
  player.position = Vector2(0, -({sprite:getHitbox()})[4] * 2)

  world:add(ground, unpack(ground.rect))
  world:add(player, player:getHitbox())

  player:pull_to_ground(world)

  return setmetatable(
    {
      camera_position = Vector2.zero,
      camera_scale = 1,
      player = player,
      target_camera_pos = Vector2.zero,
      target_camera_scale = 1,
      time = 0,
      world = world,
    },
    {
      __index = Scene,
    }
  )
end

function Scene.keypressed (self, key)
  self.player:keypressed(key, self.time, self.world)
end

function Scene.keyreleased (self, key)
  self.player:keyreleased(key, self.time, self.world)
end

function Scene.update (self, dt)
  self.time = self.time + dt

  self.target_camera_pos = Vector2.zero
  self.target_camera_scale = 1

  self.camera_position = lume.lerp(self.camera_position, self.target_camera_pos, 0.8 * dt)
  self.camera_scale = lume.lerp(self.camera_scale, self.target_camera_scale, 0.8 * dt)

  self.player:update(dt, self.time, self.world)
end

local function world_to_view_pos(pos, camera_pos, camera_scl, canvas_size)
  return camera_scl * (pos - camera_pos) + 0.5 * canvas_size
end

local function world_to_view_rect(camera_pos, camera_scl, canvas_size, x, y, w, h)
  local topleft = camera_scl * (Vector2(x, y) - camera_pos) + 0.5 * canvas_size
  local btmright = topleft + Vector2(w, h) * camera_scl
  return topleft.x, topleft.y, Vector2.unpack(btmright - topleft)
end

function Scene.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()
  local dimensions = Vector2(W, H)

  for _, item in ipairs(self.world:getItems()) do
    if item.sprite then
      local timeSinceTurn = self.time - item.facingChangeTime

      local spritesheet, spriteFrame = item.sprite:getQuad(
        item.facingDirection,
        timeSinceTurn,
        0,
        item.position.x,
        item.sprite.scale
      )

      local viewPos = world_to_view_pos(
        item.position,
        self.camera_position,
        self.camera_scale,
        dimensions
      )

      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(
        spritesheet,
        spriteFrame,
        viewPos.x,
        viewPos.y,
        0,
        item.sprite.scale,
        item.sprite.scale
      )

      if debug.hitboxes then
        for draw_mode, alpha in pairs({ [love.graphics.DrawMode.line] = 1, [love.graphics.DrawMode.fill] = 0.2 }) do
          love.graphics.setColor(0, 1, 0, alpha)
          love.graphics.rectangle(
            draw_mode,
            world_to_view_rect(
              self.camera_position,
              self.camera_scale,
              dimensions,
              item:getHitbox()
            )
          )
        end
      end

    elseif item.rect then
      item.rect = { -1000, 0, 2000, self.world.cellSize }
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle(
        love.graphics.DrawMode.fill,
        world_to_view_rect(
          self.camera_position,
          self.camera_scale,
          dimensions,
          unpack(item.rect)
        )
      )
    end

  end

end

return Scene
