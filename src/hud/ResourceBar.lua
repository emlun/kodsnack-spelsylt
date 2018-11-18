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

local Vector2 = require("util.Vector2")


local ResourceBar = {}
local ResourceBar_mt = { __index = ResourceBar }

function ResourceBar.new (resource, w, h, label)
  return setmetatable(
    {
      h = h,
      w = w,
      resource = resource,
      label = label,
    },
    ResourceBar_mt
  )
end

function ResourceBar.update (self)
  return self
end

function ResourceBar.draw (self, graphics, origin_x, origin_y)
  local fill_width = self.w * self.resource:check() / self.resource.capacity

  local padding = { top = 5, right = 7, bottom = 5, left = 7 }
  local text_pos = Vector2(self.w - padding.right, padding.top)
  local text
  if self.resource.short_name then
    text = string.format("%d %s", self.resource:check(), self.resource.short_name:get())
  else
    text = string.format("%d", self.resource:check())
  end

  local text_graphic = graphics.newText(graphics.newFont(12), text)

  local label_graphic = graphics.newText(graphics.newFont(12), self.label:get_capitalized())

  local h = label_graphic:getHeight() + padding.top + padding.bottom

  graphics.setColor(0, 1, 1, 0.3)
  graphics.rectangle("fill", origin_x, origin_y, fill_width, h)
  graphics.setColor(0, 1, 1, 1)
  graphics.rectangle("line", origin_x, origin_y, self.w, h)

  graphics.setColor(1, 1, 1, 1)
  graphics.draw(label_graphic, origin_x + padding.left, origin_y + padding.top)
  graphics.draw(text_graphic, origin_x + text_pos.x - text_graphic:getWidth(), origin_y + text_pos.y)
end

return ResourceBar
