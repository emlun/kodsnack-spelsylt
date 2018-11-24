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

local Constants = require("constants")
local Disguise = require("modules.Disguise")
local EmpBullet = require("entities.EmpBullet")
local Entity = require("entities.Entity")
local Jump = require("modules.Jump")
local Hover = require("modules.Hover")
local Resource = require("resource")
local Vector2 = require("util.Vector2")
local graphics = require("util.graphics")
local mydebug = require("src.debug")
local mymath = require("util.math")
local texts = require("lang.text")

local Super_mt = { __index = Entity }

local Drone = setmetatable({}, Super_mt)
local Drone_mt = { __index = Drone }

Drone.battery_drain_rate = 1
Drone.collision_elasticity = 1
Drone.control_windup_time = 0.7
Drone.drive_battery_cost_rate = 5
Drone.mass = 10
Drone.max_horizontal_speed = 300
Drone.max_horizontal_hover_speed = 400
Drone.max_vertical_speed = Jump.speed * 1.2
Drone.turn_duration = 0.6
Drone.type = "drone"
Drone.new_sfx = function ()
  local hover = love.audio.newSource("resources/audio/rocket.wav", "static")
  hover:setLooping(true)
  return {
    bzzt = love.audio.newSource("resources/audio/snap.wav", "static"),
    hover_begin = love.audio.newSource("resources/audio/rocket-ignition.wav", "static"),
    hover = hover,
  }
end

Drone.idle_retardation = Drone.max_horizontal_speed / 0.3

function Drone.new (id, is_active, sprite, controller, modules)
  local battery = Resource.new(500, texts.resources.battery.unit_name)
  local hover_fuel = Resource.new(1, texts.resources.hover_fuel.unit_name)

  return setmetatable(
    {
      battery = battery,
      collisions = {},
      control_acceleration = Vector2.zero,
      controller = assert(controller),
      controls_active = {},
      controls_pressed = {},
      facing_change_time = -math.huge,
      facing_direction = "right",
      hover_fuel = hover_fuel,
      id = id,
      is_active = is_active,
      modules = modules,
      position = Vector2.zero,
      sfx = Drone.new_sfx(),
      sprite = assert(sprite),
      time = 0,
      turn_progress = 1,
      velocity = Vector2.zero,
    },
    Drone_mt
  )
end

function Drone.activate_control (self, control)
  self.controls_active[control] = true

  for _, direction in pairs({ "left", "right" }) do
    if control == direction and self.facing_direction ~= direction then
      self.facing_direction = direction
      self.turn_progress = 1 - self.turn_progress
    end
  end
end

function Drone.has_module (self, type)
  return lume.any(self.modules, function (module)
    return module.type == type
  end)
end

function Drone.press_control (self, control)
  self.controls_pressed[control] = true

  if control == "left" and not self.controls_active["right"] then
    self:activate_control("left")
  elseif control == "right" and not self.controls_active["left"] then
    self:activate_control("right")
  elseif control == "hover" and self:has_module(Hover.type) then
    self.hovering = true
  end
end

function Drone.release_control (self, control)
  self.controls_active[control] = false
  self.controls_pressed[control] = false

  if control == "left" and self.controls_pressed["right"] then
    self:activate_control("right")
  elseif control == "right" and self.controls_pressed["left"] then
    self:activate_control("left")
  elseif control == "hover" then
    self.hovering = false
  end
end

function Drone.release_controls (self)
  for control, _ in pairs(self.controls_active) do
    self:release_control(control)
  end
  for control, _ in pairs(self.controls_pressed) do
    self:release_control(control)
  end
end

function Drone.jump (self, world)
  for _, module in ipairs(self.modules) do
    if module.jump then
      module:jump(self, world)
      break
    end
  end
end

function Drone.keypressed (self, key, world)
  if key == self.controller.left then
    self:press_control("left")
  elseif key == self.controller.right then
    self:press_control("right")
  elseif key == self.controller.jump then
    self:jump(world)
  elseif key == self.controller.hover then
    self:press_control("hover")
  elseif key == self.controller.disguise then
    self:toggle_disguise()
  end
end

function Drone.toggle_disguise (self)
  local found = false
  for _, module in ipairs(self.modules) do
    if module.type == Disguise.type then
      if found then
        module:disable()
      else
        module:toggle()
        found = true
      end
    end
  end
end

function Drone.keyreleased (self, key)
  if key == self.controller.left then
    self:release_control("left")
  elseif key == self.controller.right then
    self:release_control("right")
  elseif key == self.controller.hover then
    self:release_control("hover")
  end
end

function Drone.get_hitbox (self)
  return self.sprite:get_hitbox(self.position.x, self.position.y)
end

function Drone.is_driving (self, world)
  return (not self:is_turning())
    and self:has_ground_below(world)
    and (self.controls_active["left"] or self.controls_active["right"])
end

function Drone.is_turning (self)
  return self.turn_progress < 1
end

function Drone.update_controls (self, dt, world)
  local idle_deceleration =
    math.min(
      self.velocity:mag() / dt,
      self.idle_retardation
    )
    * Vector2(-mymath.sign(self.velocity.x), 0)

  local function control_left_right (efficiency, max_speed)
    if self.controls_active["left"] then
      return efficiency * Vector2(-max_speed / self.control_windup_time, 0)
    elseif self.controls_active["right"] then
      return efficiency * Vector2(max_speed / self.control_windup_time, 0)
    else
      return Vector2.zero
    end
  end

  if self.hovering and self.hover_fuel:check() > 0 then
    local fuel_wanted = Hover.fuel_cost_rate * dt
    local fuel_factor = self.hover_fuel:consume(fuel_wanted)

    self.control_acceleration =
      control_left_right(fuel_factor, self.max_horizontal_hover_speed)
      + fuel_factor * Hover.acceleration

  elseif self:is_driving(world) then
    local battery_wanted = self:is_driving(world) and self.drive_battery_cost_rate * dt or 0
    local battery_factor = self.battery:consume(battery_wanted)

    self.control_acceleration =
      control_left_right(battery_factor, self.max_horizontal_speed)
      + (1 - battery_factor) * idle_deceleration

  elseif self:has_ground_below(world) then
    self.control_acceleration = idle_deceleration
  else
    self.control_acceleration = Vector2.zero
  end
end

function Drone.update_turning (self, dt)
  if self:is_turning() then
    local battery_factor = self.battery:consume(self.drive_battery_cost_rate * dt)
    local new_progress = battery_factor * dt / self.turn_duration
    self.turn_progress = math.min(1, self.turn_progress + new_progress)
  end
end

function Drone.update_velocity (self, dt, world)
  self.velocity = self.velocity + self.control_acceleration * dt
  if self:has_ground_below(world) and self.velocity.y >= 0 then
    self.velocity = Vector2(
      mymath.sign(self.velocity.x) * math.min(self.max_horizontal_speed, math.abs(self.velocity.x)),
      self.velocity.y
    )
  else
    self.velocity = Vector2(
      mymath.sign(self.velocity.x) * math.min(self.max_horizontal_hover_speed, math.abs(self.velocity.x)),
      self.velocity.y
    )
  end

  self.velocity = Vector2(
    self.velocity.x,
    mymath.sign(self.velocity.y) * math.min(self.max_vertical_speed, math.abs(self.velocity.y))
  )

  if not self:has_ground_below(world) then
    self.velocity = self.velocity + Constants.gravity * dt
  end
end

function Drone.filter_collisions (self, other)
  if other.type == EmpBullet.type then
    return "cross"
  elseif
    other.type == self.type
    and (self.velocity - other.velocity):mag() > 20
    and self.position.y + ({self:get_hitbox()})[4] >= other.position.y
  then
    return "bounce"
  else
    return "slide"
  end
end

function Drone.collide_elastically (self, collision, world)
  local other = collision.other

  local total_elasticity = self.collision_elasticity * (other.collision_elasticity or 1)
  local other_mass = other.mass or 1
  local total_mass = self.mass + other_mass

  local normal = Vector2.from_xy(collision.normal)

  local self_normal_velocity = self.velocity:project_on(normal)
  local other_normal_velocity = other.velocity:project_on(normal)
  local second_part =
    (self.mass * self_normal_velocity + other_mass * other_normal_velocity)
      / total_mass

  local new_self_normal_velocity =
    (total_elasticity * other_mass * (other_normal_velocity - self_normal_velocity))
      / total_mass
    + second_part

  local new_other_normal_velocity =
    (total_elasticity * self.mass * (self_normal_velocity - other_normal_velocity))
      / total_mass
    + second_part

  if other:can_move(new_other_normal_velocity:normalized(), world) then
    self.velocity = self.velocity - self.velocity:project_on(normal) + new_self_normal_velocity
    other.velocity = other.velocity - other.velocity:project_on(normal) + new_other_normal_velocity
  else
    self.velocity = self.velocity - (1 + total_elasticity) * self_normal_velocity
  end
end

function Drone.update_position (self, dt, world)
  local goal_x, goal_y = Vector2.unpack(self.position + self.velocity * dt)
  local actual_x, actual_y, collisions = world:move(self, goal_x, goal_y, self.filter_collisions)
  for _, collision in pairs(collisions) do
    if collision.type == "touch" then
      self.velocity = Vector2.zero
    elseif collision.type == "slide" then
      self.velocity = self.velocity - self.velocity:project_on(Vector2.from_xy(collision.normal))
    elseif collision.type == "bounce" then
      if collision.other.type == "drone" then
        self:collide_elastically(collision, world)
      else
        self.velocity = self.velocity - 2 * self.velocity:project_on(Vector2.from_xy(collision.normal))
      end
    end
  end
  self.collisions = collisions

  self.position = Vector2(actual_x, actual_y)
end

function Drone.update_modules (self, dt)
  for _, module in ipairs(self.modules) do
    if module.update_drone then
      module:update_drone(self, dt)
    end
  end
end

function Drone.update_resources (self, dt)
  self.battery:consume(self.battery_drain_rate * dt)
end

function Drone.update (self, dt, world)
  self.time = self.time + dt
  self:update_controls(dt, world)
  self:update_turning(dt)
  self:update_velocity(dt, world)
  self:update_position(dt, world)
  self:update_resources(dt)
  self:update_modules(dt)
end

function Drone.will_collide_with ()
  return true
end

function Drone.collide (self, other)
  if other.type == EmpBullet.type then
    self.battery:consume(30)
    self:release_controls()
    self.sfx.bzzt:play()
  end
end

function Drone.draw (self, camera)
  local spritesheet, sprite_frame = self.sprite:get_frame(
    self.hovering,
    self.facing_direction,
    self.turn_progress,
    self.position.x,
    self.hover_fuel:check() > 0 and self.time or 0
  )

  local view_pos = camera:project(self.sprite:get_offset_position(self.hovering, self.position))

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

  for _, module in pairs(self.modules) do
    if module.draw then
      module:draw(camera, Vector2(self:get_hitbox()), self.facing_direction, self.sprite.scale)
    end
  end

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

function Drone.update_sounds (self, camera)
  if self.hovering and self.hover_fuel:check() > 0 then
    if not self.sfx.hover:isPlaying() then
      self.sfx.hover_begin:play()
      self.sfx.hover:play()
    end
  elseif self.sfx.hover:isPlaying() then
    self.sfx.hover:stop()
  end

  local volume_decay_distance = 250
  local volume = 1 / ((self.position - camera.pos):mag() / volume_decay_distance)^2
  if volume < 0.1 then
    volume = 0
  end

  lume.each(self.sfx, function (source) source:setVolume(volume) end)
end
return Drone
