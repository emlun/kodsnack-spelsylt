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

local Camera = require("camera")
local DroneStatusBar = require("hud.DroneStatusBar")
local Hud = require("hud.Hud")
local ResourceBar = require("hud.ResourceBar")
local Turret = require("entities.Turret")
local Vector2 = require("util.Vector2")
local mydebug = require("src.debug")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }


function Self.new (controller)
  return setmetatable(
    {
      controller = controller,
    },
    Self_mt
  )
end

function Self.enter (self, drones, map)
  local world = bump.newWorld()

  local active_drone = 1

  local hud = Hud.new()
  map:bump_init(world)

  local battery_bar = ResourceBar.new(
    drones[active_drone].battery,
    200,
    20,
    {
      show_text = true,
      label = texts.resources.battery.name,
    }
  )
  local hover_fuel_bar = ResourceBar.new(
    drones[active_drone].hover_fuel,
    200,
    20,
    {
      show_text = true,
      label = texts.resources.hover_fuel.name,
      color = { 1, 0.5, 0 },
    }
  )
  hud:add(battery_bar, 30, 30)
  hud:add(hover_fuel_bar, 30, 30 + battery_bar:get_height() + 5)

  lume.each(drones, function (drone, i)
    world:add(drone, drone:get_hitbox())
    drone:pull_to_ground(world)
  end)

  local turrets = {}
  for _, object in pairs(map.objects) do
    if object.type == "spawn-turret" then
      local facing_x = assert(object.properties.facing_x)
      local facing_y = assert(object.properties.facing_y)

      local turret = Turret.new(#turrets + 1, Vector2(facing_x, facing_y))
      turret.position = Vector2(object.x, object.y)
      world:add(turret, turret:get_hitbox())
      turret:snap_backwards(world)
    end
  end

  self.active_drone = active_drone
  self.battery_bar = battery_bar
  self.hover_fuel_bar = hover_fuel_bar
  self.camera = Camera.new(Vector2(love.graphics.getDimensions()), drones[active_drone].position, 1)
  self.drones = drones
  self.drone_status_bars = lume.map(drones, DroneStatusBar.new)
  self.hud = hud
  self.map = map
  self.time = 0
  self.turrets = turrets
  self.world = world
end

function Self.get_active_drone (self)
  return self.drones[self.active_drone]
end

function Self.switch_drone (self, new_index)
  self:get_active_drone().is_active = false
  local new_drone = self.drones[new_index]
  self.battery_bar.resource = new_drone.battery
  self.hover_fuel_bar.resource = new_drone.hover_fuel
  self.active_drone = new_index
  new_drone.is_active = true
  new_drone:release_controls()
end

function Self.keypressed (self, key)
  if key >= "1" and key <= "4" then
    self:switch_drone(tonumber(key))
  else
    self:get_active_drone():keypressed(key, self.world)
  end
end

function Self.keyreleased (self, key)
  self:get_active_drone():keyreleased(key, self.time, self.world)
end

function Self.update (self, dt)
  self.time = self.time + dt

  self.map:update(dt)

  for _, item in ipairs(self.world:getItems()) do
    if item.update then
      item:update(dt, self.world)
    end
  end

  self.map:resize(love.graphics.getDimensions())
  self.camera:set_dimensions(Vector2(love.graphics.getDimensions()))
  self.camera:move_to(
    self:get_active_drone().position
      + Vector2(self:get_active_drone().sprite:get_hitbox_dimensions()) / 2
  )
  self:update_sounds()
end

function Self.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()

  local view_origin = self.camera:project(Vector2.zero)
  love.graphics.setColor(1, 1, 1)
  self.map:draw(view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

  if mydebug.hitboxes then
    love.graphics.setColor(1, 1, 1)
    self.map:bump_draw(self.world, view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(W / 2, H / 2 - 10, W / 2, H / 2 + 10)
    love.graphics.line(W / 2 - 10, H / 2, W / 2 + 10, H / 2)
  end

  for _, item in ipairs(self.world:getItems()) do
    if item.draw then
      item:draw(self.camera)
    elseif item.rect then
      item.rect = { -1000, 0, 2000, self.world.cellSize }
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle(
        love.graphics.DrawMode.fill,
        self.camera:project_rect(unpack(item.rect))
      )
    end
  end

  for _, item in ipairs(self.drone_status_bars) do
    item:draw(self.camera)
  end

  self.hud:draw(self.time)
end


function Self.update_sounds (self)
  for _, item in ipairs(self.world:getItems()) do
    if item.update_sounds then
      item:update_sounds(self.camera)
    end
  end
end

return Self
