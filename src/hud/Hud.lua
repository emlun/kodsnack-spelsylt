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

local Drone = require("entities.Drone")
local ResourceBar = require("hud.ResourceBar")
local texts = require("lang.text")


local Hud = {}
local Hud_mt = { __index = Hud }

function Hud.new (active_drone, elements)
  local els = elements or {}
  assert(active_drone and active_drone.type == Drone.type)
  assert(type(els) == "table")

  local battery_bar = ResourceBar.new(
    "battery",
    200,
    20,
    {
      show_text = true,
      label = texts.resources.battery.name,
    }
  )
  local hover_fuel_bar = ResourceBar.new(
   "hover_fuel",
    200,
    20,
    {
      show_text = true,
      label = texts.resources.hover_fuel.name,
      color = { 1, 0.5, 0 },
    }
  )

  local self = setmetatable(
    {
      active_drone = active_drone,
      elements = els,
      previous_id = 1,
    },
    Hud_mt
  )

  self:add(battery_bar, 30, 30)
  self:add(hover_fuel_bar, 30, 30 + battery_bar:get_height() + 5)

  return self
end

function Hud.set_active_drone (self, active_drone)
  self.active_drone = active_drone
end

function Hud.add (self, element, x, y)
  local id = self:get_id()
  return lume.push(
    self.elements,
    {
      id = id,
      element = element,
      x = x,
      y = y,
      rotation = 0,
  })
end

function Hud.get_id (self)
  self.previous_id = self.previous_id + 1
  return self.previous_id
end

function Hud.remove (self, id)
  return lume.remove(self.elements, id)
end

function Hud.draw (self, time)
  for _, element in pairs(self.elements) do
    if element.element.draw then
      element.element:draw(self.active_drone, element.x, element.y, element.rotation, time)
    else
      error(string.format(
        "Don't know how to draw element %d: %s %s",
        element.id,
        type(element.element),
        tostring(element.element)
      ))
    end
  end
end

return Hud
