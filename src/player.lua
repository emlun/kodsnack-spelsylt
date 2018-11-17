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

local lume = require("lib.lume")

local Vector2 = require("util.Vector2")
local mymath = require("util.math")


local gravity = Vector2(0, 2000)
local controlWindupTime = 0.7
local maxHorizontalSpeed = 300
local jumpSpeed = 800
local idleRetardation = maxHorizontalSpeed / 0.3

local Player = {}

function Player.new (sprite, facingChangeDuration, controller, sfx)
  return setmetatable(
    {
      controlAcceleration = Vector2.zero,
      controller = assert(controller),
      controlsActive = {},
      controlsPressed = {},
      facingChangeDuration = assert(facingChangeDuration),
      facingChangeTime = -math.huge,
      facingDirection = "right",
      position = Vector2.zero,
      sprite = assert(sprite),
      sfx = assert(sfx),
      velocity = Vector2.zero,
    },
    {
      __index = Player,
    }
  )
end

function Player.activateControl (self, control, time)
  self.controlsActive[control] = true

  for _, direction in pairs({ "left", "right" }) do
    if control == direction and self.facingDirection ~= direction then
      self.facingDirection = direction
      self.facingChangeTime = time
    end
  end
end

function Player.pressControl (self, control, time)
  self.controlsPressed[control] = true

  if control == "left" and not self.controlsActive["right"] then
    self:activateControl("left", time)
  elseif control == "right" and not self.controlsActive["left"] then
    self:activateControl("right", time)
  end
end

function Player.releaseControl (self, control, time)
  self.controlsActive[control] = false
  self.controlsPressed[control] = false

  if control == "left" and self.controlsPressed["right"] then
    self:activateControl("right", time)
  elseif control == "right" and self.controlsPressed["left"] then
    self:activateControl("left", time)
  end
end

function Player.jump (self, world)
  lume.randomchoice(self.sfx.jump):play()
  if self:hasGroundBelow(world) then
    self.velocity = self.velocity + Vector2(0, -jumpSpeed)
  end
end

function Player.keypressed (self, key, time, world)
  if key == self.controller.left then
    self:pressControl("left", time)
  elseif key == self.controller.right then
    self:pressControl("right", time)
  elseif key == self.controller.jump then
    self:jump(world)
  end
end

function Player.keyreleased (self, key, time)
  if key == self.controller.left then
    self:releaseControl("left", time)
  elseif key == self.controller.right then
    self:releaseControl("right", time)
  end
end

function Player.getHitbox (self)
  return self.sprite:getHitbox(self.position.x, self.position.y)
end

function Player.hasGroundBelow (self, world)
  local _, _, collisions = world:check(self, Vector2.unpack(self.position + Vector2(0, 1)))
  for _, collision in pairs(collisions) do
    if collision.type == "touch" or collision.type == "slide" or collision.type == "bounce" then
      return true
    end
  end
end

function Player.isTurning (self, time)
  return time - self.facingChangeTime < self.facingChangeDuration
end

function Player.pull_to_ground (self, world)
  self.position = Vector2(world:move(self, self.position.x, self.position.y + 10000, function () return "touch" end))
end

function Player.update (self, dt, time, world)
  if self.controlsActive["left"] and not self:isTurning(time) then
    self.controlAcceleration = Vector2(-maxHorizontalSpeed / controlWindupTime, 0)
  elseif self.controlsActive["right"] and not self:isTurning(time) then
    self.controlAcceleration = Vector2(maxHorizontalSpeed / controlWindupTime, 0)
  else
    self.controlAcceleration =
      math.min(
        self.velocity:mag() / dt,
        idleRetardation
      )
      * Vector2(-mymath.sign(self.velocity.x), 0)
  end

  if self:hasGroundBelow(world) and self.velocity.y >= 0 then
    self.velocity = self.velocity + self.controlAcceleration * dt
    self.velocity = Vector2(
      mymath.sign(self.velocity.x) * math.min(maxHorizontalSpeed, math.abs(self.velocity.x)),
      self.velocity.y
    )
  else
    self.velocity = self.velocity + gravity * dt
  end

  local actualX, actualY, collisions = world:move(self, Vector2.unpack(self.position + self.velocity * dt))
  for _, collision in pairs(collisions) do
    if collision.type == "touch" then
      self.velocity = Vector2.zero
    elseif collision.type == "slide" then
      self.velocity = self.velocity + self.velocity:elmul(collision.normal)
    elseif collision.type == "bounce" then
      self.velocity = self.velocity:elmul(collision.normal)
    end
  end
  self.position = Vector2(actualX, actualY)
end

function Player.collision (self)
  self.velocity = Vector2.zero
end

return Player
