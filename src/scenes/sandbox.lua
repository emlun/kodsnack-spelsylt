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
local sti = require("lib.sti.init")

local Camera = require("camera")
local Hud = require("hud.Hud")
local Player = require("player")
local ResourceBar = require("hud.ResourceBar")
local SophiaSprite = require("sprites.sophia")
local Vector2 = require("util.Vector2")
local mydebug = require("src.debug")
local texts = require("lang.text")


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
local Scene_mt = { __index = Scene }


function Scene.new (controller)
  return setmetatable(
    {
      controller = controller,
    },
    Scene_mt
  )
end

function Scene.enter (self)
  local world = bump.newWorld()
  local player = Player.new(sprite, facingChangeDuration, self.controller, { jump = klirr })
  local hud = Hud.new()
  local map = sti("maps/sandbox.lua", { "bump" })
  map:bump_init(world)

  hud:add(ResourceBar.new(player.battery, 100, 20, texts.resources.battery.name), 30, 30)

  for _, object in pairs(map.objects) do
    if object.type == "spawn-player" then
      player.position = Vector2(object.x, object.y)
    end
  end

  world:add(player, player:getHitbox())

  player:pull_to_ground(world)

  self.camera = Camera.new(Vector2(love.graphics.getDimensions()), player.position, 1)
  self.hud = hud
  self.map = map
  self.player = player
  self.time = 0
  self.world = world
end

function Scene.keypressed (self, key)
  if key == "escape" then
    self.onExit()
  else
    self.player:keypressed(key, self.time, self.world)
  end
end

function Scene.keyreleased (self, key)
  self.player:keyreleased(key, self.time, self.world)
end

function Scene.update (self, dt)
  self.time = self.time + dt

  self.map:update(dt)

  self.player:update(dt, self.time, self.world)

  self.camera:move_to(self.player.position + Vector2(self.player.sprite:getDimensions()) / 2)
end

function Scene.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()

  local view_origin = self.camera:project(Vector2.zero)
  self.map:draw(view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

  if mydebug.hitboxes then
    love.graphics.setColor(1, 1, 1)
    self.map:bump_draw(self.world, view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(W / 2, H / 2 - 10, W / 2, H / 2 + 10)
    love.graphics.line(W / 2 - 10, H / 2, W / 2 + 10, H / 2)
  end

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

      local viewPos = self.camera:project(item.sprite:getOffsetPosition(item.position))

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

      if mydebug.hitboxes then
        for draw_mode, alpha in pairs({ [love.graphics.DrawMode.line] = 1, [love.graphics.DrawMode.fill] = 0.2 }) do
          love.graphics.setColor(0, 1, 0, alpha)
          love.graphics.rectangle(
            draw_mode,
            self.camera:project_rect(item:getHitbox())
          )
        end
      end

    elseif item.rect then
      item.rect = { -1000, 0, 2000, self.world.cellSize }
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle(
        love.graphics.DrawMode.fill,
        self.camera:project_rect(unpack(item.rect))
      )
    end
  end

  self.hud:draw(love.graphics, W, H, self.time)

end

return Scene
