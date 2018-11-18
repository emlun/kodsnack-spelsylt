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
--
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
Player.control_windup_time = 0.7
Player.drive_battery_cost_rate = 5
Player.turn_duration = 0.6
Player.max_horizontal_speed = 300
Player.jump_battery_cost = 10
Player.jump_speed = 800
Player.idle_retardation = Player.max_horizontal_speed / 0.3

function Player.new (sprite, controller, sfx)
  local battery = Resource.new(100, texts.resources.battery.unit_name)

  return setmetatable(
    {
      battery = battery,
      collisions = {},
      control_acceleration = Vector2.zero,
      controller = assert(controller),
      controls_active = {},
      controls_pressed = {},
      turn_progress = 1,
      facing_change_time = -math.huge,
      facing_direction = "right",
      position = Vector2.zero,
      sprite = assert(sprite),
      sfx = assert(sfx),
      velocity = Vector2.zero,
    },
    Player_mt
  )
end

function Player.activate_control (self, control, time)
  self.controls_active[control] = true

  for _, direction in pairs({ "left", "right" }) do
    if control == direction and self.facing_direction ~= direction then
      self.facing_direction = direction
      self.turn_progress = 1 - self.turn_progress
    end
  end
end

function Player.press_control (self, control, time)
  self.controls_pressed[control] = true

  if control == "left" and not self.controls_active["right"] then
    self:activate_control("left", time)
  elseif control == "right" and not self.controls_active["left"] then
    self:activate_control("right", time)
  end
end

function Player.release_control (self, control, time)
  self.controls_active[control] = false
  self.controls_pressed[control] = false

  if control == "left" and self.controls_pressed["right"] then
    self:activate_control("right", time)
  elseif control == "right" and self.controls_pressed["left"] then
    self:activate_control("left", time)
  end
end

function Player.jump (self, world)
  lume.randomchoice(self.sfx.jump):play()
  if self:has_ground_below(world) then
    local battery_usage = self.battery:consume(self.jump_battery_cost)
    self.velocity = self.velocity + Vector2(0, -self.jump_speed * battery_usage / self.jump_battery_cost)
  end
end

function Player.keypressed (self, key, time, world)
  if key == self.controller.left then
    self:press_control("left", time)
  elseif key == self.controller.right then
    self:press_control("right", time)
  elseif key == self.controller.jump then
    self:jump(world)
  end
end

function Player.keyreleased (self, key, time)
  if key == self.controller.left then
    self:release_control("left", time)
  elseif key == self.controller.right then
    self:release_control("right", time)
  end
end

function Player.get_hitbox (self)
  return self.sprite:get_hitbox(self.position.x, self.position.y)
end

function Player.has_ground_below (self, world)
  local _, _, collisions = world:check(self, Vector2.unpack(self.position + Vector2(0, 1)))
  for _, collision in pairs(collisions) do
    if collision.type == "touch" or collision.type == "slide" or collision.type == "bounce" then
      return true
    end
  end
end

function Player.is_driving (self, world)
  return (not self:is_turning())
    and self:has_ground_below(world)
    and (self.controls_active["left"] or self.controls_active["right"])
end

function Player.is_turning (self)
  return self.turn_progress < 1
end

function Player.pull_to_ground (self, world)
  self.position = Vector2(world:move(self, self.position.x, self.position.y + 10000, function () return "touch" end))
end

function Player.update_controls (self, dt, world)
  local idle_deceleration =
    math.min(
      self.velocity:mag() / dt,
      self.idle_retardation
    )
    * Vector2(-mymath.sign(self.velocity.x), 0)

  if self:is_driving(world) then
    local battery_wanted = self:is_driving(world) and self.drive_battery_cost_rate * dt or 0
    local battery_used = self.battery:consume(battery_wanted)
    local battery_factor = battery_used / battery_wanted

    if self.controls_active["left"] then
      self.control_acceleration = battery_factor * Vector2(-self.max_horizontal_speed / self.control_windup_time, 0)
    elseif self.controls_active["right"] then
      self.control_acceleration = battery_factor * Vector2(self.max_horizontal_speed / self.control_windup_time, 0)
    end

    self.control_acceleration = self.control_acceleration + (1 - battery_factor) * idle_deceleration
  else
    self.control_acceleration = idle_deceleration
  end
end

function Player.update_turning (self, dt)
  if self:is_turning() then
    local battery_used = self.battery:consume(self.drive_battery_cost_rate * dt)
    local new_progress = battery_used / self.drive_battery_cost_rate / self.turn_duration
    self.turn_progress = math.min(1, self.turn_progress + new_progress)
  end
end

function Player.update_velocity (self, dt, world)
  if self:has_ground_below(world) and self.velocity.y >= 0 then
    self.velocity = self.velocity + self.control_acceleration * dt
    self.velocity = Vector2(
      mymath.sign(self.velocity.x) * math.min(self.max_horizontal_speed, math.abs(self.velocity.x)),
      self.velocity.y
    )
  else
    self.velocity = self.velocity + self.gravity * dt
  end
end

function Player.update_position (self, dt, world)
  local actual_x, actual_y, collisions = world:move(self, Vector2.unpack(self.position + self.velocity * dt))
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

  self.position = Vector2(actual_x, actual_y)
end

function Player.update_resources (self, dt)
  self.battery:add(self.battery_recharge_rate * dt)
end

function Player.update (self, dt, world)
  self:update_controls(dt, world)
  self:update_turning(dt)
  self:update_velocity(dt, world)
  self:update_position(dt, world)
  self:update_resources(dt)
end

function Player.draw (self, camera)
  local time_since_turn = self.turn_progress * self.turn_duration

  local spritesheet, sprite_frame = self.sprite:get_frame(
    self.facing_direction,
    self.turn_duration,
    time_since_turn,
    0,
    self.position.x,
    self.sprite.scale
  )

  local view_pos = camera:project(self.sprite:get_offset_position(self.position))

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    spritesheet,
    sprite_frame,
    view_pos.x,
    view_pos.y,
    0,
    self.sprite.scale,
    self.sprite.scale
  )

  if mydebug.hitboxes then
    for draw_mode, alpha in pairs({ [love.graphics.DrawMode.line] = 1, [love.graphics.DrawMode.fill] = 0.2 }) do
      love.graphics.setColor(0, 1, 0, alpha)
      love.graphics.rectangle(
        draw_mode,
        camera:project_rect(self:get_hitbox())
      )
    end

    for _, collision in pairs(self.collisions) do
      local hb_x, hb_y, hb_w, hb_h = self:get_hitbox()

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
