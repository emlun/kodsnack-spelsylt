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
local readonlytable = require("util.table").readonlytable


local controlWindupTime = 0.15
local maxSpeed = 300
local idleRetardation = maxSpeed / (controlWindupTime * 1.5)

local Player = {}

function Player.new (controller, sfx)
  return setmetatable(
    {
      controlAcceleration = Vector2.zero,
      controller = controller,
      controlsActive = {},
      controlsPressed = {},
      facingChangeTime = -math.huge,
      facingDirection = "right",
      position = Vector2.zero,
      sfx = sfx,
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

function Player.jump (self)
  lume.randomchoice(self.sfx.jump):play()
end

function Player.keypressed (self, key, time)
  if key == self.controller.left then
    self:pressControl("left", time)
  elseif key == self.controller.right then
    self:pressControl("right", time)
  elseif key == self.controller.jump then
    self:jump()
  end
end

function Player.keyreleased (self, key, time)
  if key == self.controller.left then
    self:releaseControl("left", time)
  elseif key == self.controller.right then
    self:releaseControl("right", time)
  end
end

function Player.update (self, dt)
  if self.controlsActive["left"] then
    self.controlAcceleration = Vector2(-maxSpeed / controlWindupTime, 0)
  elseif self.controlsActive["right"] then
    self.controlAcceleration = Vector2(maxSpeed / controlWindupTime, 0)
  else
    self.controlAcceleration =
      math.min(
        self.velocity:mag() / dt,
        idleRetardation
      )
      * Vector2(self.velocity.x > 0 and -1 or 1, 0)
  end

  self.velocity = self.velocity + self.controlAcceleration * dt
  self.velocity = self.velocity:normalized() * math.min(maxSpeed, self.velocity:mag())

  self.position = self.position + self.velocity * dt
end

return readonlytable(Player)
