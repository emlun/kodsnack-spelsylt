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

local Resource = require("resource")
local Vector2 = require("util.Vector2")
local graphics = require("util.graphics")
local mydebug = require("src.debug")
local mymath = require("util.math")
local texts = require("lang.text")


local Player = {}
local Player_mt = { __index = Player }

Player.gravity = Vector2(0, 2000)
Player.battery_recharge_rate = 1
Player.controlWindupTime = 0.7
Player.drive_battery_cost_rate = 5
Player.facingChangeDuration = 0.6
Player.maxHorizontalSpeed = 300
Player.jump_battery_cost = 10
Player.jumpSpeed = 800
Player.idleRetardation = Player.maxHorizontalSpeed / 0.3

function Player.new (sprite, controller, sfx)
  local battery = Resource.new(100, texts.resources.battery.unit_name)

  return setmetatable(
    {
      battery = battery,
      collisions = {},
      controlAcceleration = Vector2.zero,
      controller = assert(controller),
      controlsActive = {},
      controlsPressed = {},
      facingChangeTime = -math.huge,
      facingDirection = "right",
      position = Vector2.zero,
      sprite = assert(sprite),
      sfx = assert(sfx),
      velocity = Vector2.zero,
    },
    Player_mt
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
    local battery_usage = self.battery:consume(self.jump_battery_cost)
    self.velocity = self.velocity + Vector2(0, -self.jumpSpeed * battery_usage / self.jump_battery_cost)
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

function Player.isDriving (self, time)
  return self:isTurning(time) or self.controlsActive["left"] or self.controlsActive["right"]
end

function Player.isTurning (self, time)
  return time - self.facingChangeTime < self.facingChangeDuration
end

function Player.pull_to_ground (self, world)
  self.position = Vector2(world:move(self, self.position.x, self.position.y + 10000, function () return "touch" end))
end

function Player.update_controls (self, dt, time)
  if self.controlsActive["left"] and not self:isTurning(time) and self.battery:check() > 0 then
    self.controlAcceleration = Vector2(-self.maxHorizontalSpeed / self.controlWindupTime, 0)
  elseif self.controlsActive["right"] and not self:isTurning(time) and self.battery:check() > 0 then
    self.controlAcceleration = Vector2(self.maxHorizontalSpeed / self.controlWindupTime, 0)
  else
    self.controlAcceleration =
      math.min(
        self.velocity:mag() / dt,
        self.idleRetardation
      )
      * Vector2(-mymath.sign(self.velocity.x), 0)
  end
end

function Player.update_velocity (self, dt, world)
  if self:hasGroundBelow(world) and self.velocity.y >= 0 then
    self.velocity = self.velocity + self.controlAcceleration * dt
    self.velocity = Vector2(
      mymath.sign(self.velocity.x) * math.min(self.maxHorizontalSpeed, math.abs(self.velocity.x)),
      self.velocity.y
    )
  else
    self.velocity = self.velocity + self.gravity * dt
  end
end

function Player.update_position (self, dt, world)
  local actualX, actualY, collisions = world:move(self, Vector2.unpack(self.position + self.velocity * dt))
  for _, collision in pairs(collisions) do
    if collision.type == "touch" then
      self.velocity = Vector2.zero
    elseif collision.type == "slide" then
      self.velocity = self.velocity - self.velocity:project_on(Vector2.from_xy(collision.normal))
    elseif collision.type == "bounce" then
      self.velocity = self.velocity + 2 * self.velocity:project_on(Vector2.from_xy(collision.normal))
    end
  end
  self.collisions = collisions

  self.position = Vector2(actualX, actualY)
end

function Player.update_resources (self, dt, time)
  if self:isDriving(time) then
    self.battery:consume(self.drive_battery_cost_rate * dt)
  else
    self.battery:add(self.battery_recharge_rate * dt)
  end
end

function Player.update (self, dt, time, world)
  self:update_controls(dt, time)
  self:update_velocity(dt, world)
  self:update_position(dt, world)
  self:update_resources(dt, time)
end

function Player.draw (self, camera)
  if mydebug.hitboxes then
    for _, collision in pairs(self.collisions) do
      local hb_x, hb_y, hb_w, hb_h = self:getHitbox()

      local dim = Vector2(hb_w, hb_h)
      local center = (2 * Vector2(hb_x, hb_y) + dim) / 2
      local normal = Vector2.from_xy(collision.normal)

      local arrow_start = center - normal:elmul(dim) / 2
      local arrow_span = normal:elmul(dim + Vector2(20, 20))

      graphics.arrow(arrow_start, arrow_start + arrow_span, camera, { 0, 1, 1 })
    end
  end
end

return Player
