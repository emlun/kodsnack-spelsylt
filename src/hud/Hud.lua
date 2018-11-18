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


local Hud = {}
local Hud_mt = { __index = Hud }

function Hud.new (elements)
  local els = elements or {}
  assert(type(els) == "table")
  return setmetatable(
    {
      elements = els,
      previous_id = 1,
    },
    Hud_mt
  )
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

function Hud.update (self, dt)
  for _, element in pairs(self.elements) do
    element.element:update(dt)
  end
end

function Hud.draw (self, time)
  for _, element in pairs(self.elements) do
    if element.element.draw then
      element.element:draw(element.x, element.y, element.rotation, time)
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
