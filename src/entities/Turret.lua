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

local Drone = require("entities.Drone")
local Entity = require("entities.Entity")
local Vector2 = require("util.Vector2")
local mydebug = require("src.debug")


local Super_mt = { __index = Entity }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.aim_time = 1
Self.firing_period = 2
Self.beam_color = {
  targeting = { 1, 0, 0, 1 },
  lingering = { 0.7, 0.7, 0.7, 1 },
  scanning = { 1, 0, 0, 0.5 },
}
Self.linger_timeout = 3
Self.radius = 20
Self.range = 3000
Self.sweep_period = 4
Self.type = "turret"
Self.velocity = Vector2.zero

function Self.new (id, facing_direction)
  return setmetatable(
    {
      aim_progress = 0,
      facing_direction = facing_direction:normalized(),
      id = id,
      position = Vector2.zero,
      state = "scanning",
      state_change_time = 0,
      sweep_offset = 0.5,
      target = nil,
      target_point = Vector2.zero,
      time = 0,
      zero_angle = (facing_direction:angle() - math.pi / 2) % (2 * math.pi),
    },
    Self_mt
  )
end

function Self.snap_backwards (self, world)
  self:pull_in_direction(world, -self.facing_direction)
  mydebug.print("snap turret", self.id, "to", self.position, "zero_angle", self.zero_angle)
end

function Self.get_hitbox (self)
  return
    self.position.x,
    self.position.y,
    Vector2.unpack(
      self.radius * Vector2(
        2 - math.abs(self.facing_direction.x),
        2 - math.abs(self.facing_direction.y)
      )
    )
end

function Self.get_arc_center (self)
  local dv

  if self.facing_direction.x > 0 then
    dv = 1 * self.facing_direction:rotate(math.pi / 2) + 0 * self.facing_direction

  elseif self.facing_direction.y > 0 then
    dv = (-1) * self.facing_direction:rotate(math.pi / 2) + 0 * self.facing_direction

  elseif self.facing_direction.x < 0 then
    dv = (-1) * self.facing_direction:rotate(math.pi / 2) + (-1) * self.facing_direction

  elseif self.facing_direction.y < 0 then
    dv = (1) * self.facing_direction:rotate(math.pi / 2) + (-1) * self.facing_direction
  end
  return self.position + self.radius * dv
end

Self.get_aim_origin = Self.get_center

function Self.update (self, dt, world)
  self.time = self.time + dt
  self:update_target(dt, world)
  self:update_firing(dt, world)
end

function Self.find_target (self, world, pos)
  local center = self:get_aim_origin()
  pos = pos or self.target:get_center()

  local iteminfo = world:querySegmentWithCoords(center.x, center.y, pos:unpack())
  if #iteminfo > 1 and iteminfo[2].item == self.target then
    return iteminfo[2]
  end
end

function Self.is_target_visible (self, world)
  local center = self:get_aim_origin()
  local iteminfo = world:querySegmentWithCoords(center.x, center.y, self.target:get_center():unpack())
  return #iteminfo > 1 and iteminfo[2].item == self.target
end

function Self.update_target (self, dt, world)
  if self.state == "targeting" then
    local target_iteminfo = self:find_target(world)
    if not target_iteminfo then
      target_iteminfo = self:find_target(world, self.target_point)
    end

    if target_iteminfo then
      self.target_point = Vector2(target_iteminfo.x2, target_iteminfo.y2)
      self.aim_progress = self.aim_progress + dt
    else
      self:set_state_lingering()
    end

  elseif self.state == "lingering" then
    if self.time - self.state_change_time > self.linger_timeout then
      self:set_state_scanning()
    else
      local target_iteminfo = self:find_target(world, self.target_point)
      if target_iteminfo then
        self:set_state_targeting(target_iteminfo)
      end
    end

  else
    local aim_angle =
      (
        lume.pingpong(
          (self.time - self.state_change_time)
            / self.sweep_period
          + self.sweep_offset
        ) * math.pi
        + self.zero_angle
      ) % (2 * math.pi)

    local center = self:get_aim_origin()
    local target_point = center + Vector2.from_polar(aim_angle, self.range)

    local iteminfo = world:querySegmentWithCoords(center.x, center.y, target_point:unpack())
    if #iteminfo > 1 then
      if self:will_target(iteminfo[2].item) then
        self:set_state_targeting(iteminfo[2])
      else
        self.target_point = Vector2(iteminfo[2].x1, iteminfo[2].y1)
      end
    end
  end
end

function Self.update_firing (self, _, world)
  if self.state == "targeting" and self.aim_progress > self.aim_time + self.firing_period then
    self.aim_progress = self.aim_progress - self.firing_period
    self:fire(world)
  end
end

function Self.fire (self, world)
  mydebug.print("FIRE!", self.target:get_center(), (self.target:get_center() - self:get_aim_origin()):angle(), self.aim_progress)
end

function Self.set_state_targeting (self, iteminfo)
  self.state = "targeting"
  self.target = iteminfo.item
  self.state_change_time = self.time
  self.target_point = Vector2(iteminfo.x2, iteminfo.y2)

  mydebug.print("turret", self.id, self.state, self.target, self.target_point, self.aim_progress)
end

function Self.set_state_lingering (self)
  self.state = "lingering"
  self.state_change_time = self.time
  self.aim_progress = 0
  mydebug.print("turret", self.id, self.state, self.target, self.target_point, self.aim_progress)
end

function Self.set_state_scanning (self)
  self.state = "scanning"
  self.state_change_time = self.time
  self.sweep_offset = ((self.target_point - self:get_aim_origin()):angle() - self.zero_angle) / math.pi
  self.target = nil
  mydebug.print("turret", self.id, self.state, self.target, self.target_point, self.aim_progress, self.sweep_offset)
end

function Self.will_target (_, item)
  return item.type == Drone.type
end

function Self.draw (self, camera)
  local center_x, center_y = camera:project(self:get_arc_center()):unpack()

  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.arc("fill", center_x, center_y, self.radius, self.zero_angle, self.zero_angle + math.pi)

  local aim_origin_x, aim_origin_y = camera:project(self:get_aim_origin()):unpack()
  love.graphics.setColor(unpack(self.beam_color[self.state]))
  love.graphics.line(aim_origin_x, aim_origin_y, camera:project(self.target_point):unpack())

  if mydebug.hitboxes then
    for draw_mode, alpha in pairs({ [love.graphics.DrawMode.line] = 1, [love.graphics.DrawMode.fill] = 0.2 }) do
      love.graphics.setColor(0, 1, 0, alpha)
      love.graphics.rectangle(
        draw_mode,
        camera:project_rect(self:get_hitbox())
      )
    end
  end
end

return Self
