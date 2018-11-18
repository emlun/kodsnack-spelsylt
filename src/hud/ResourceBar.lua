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

local Vector2 = require("util.Vector2")


local ResourceBar = {}
local ResourceBar_mt = { __index = ResourceBar }

function ResourceBar.new (resource, w, h, args)
  args = args or {}

  return setmetatable(
    {
      color = args.color or { 0, 1, 1 },
      h = h,
      label = args.label,
      resource = resource,
      show_text = args.show_text == true,
      w = w,
    },
    ResourceBar_mt
  )
end

function ResourceBar.get_border_color (self, opacity)
  return { self.color[1], self.color[2], self.color[3], opacity }
end

function ResourceBar.get_fill_color (self, opacity)
  return { self.color[1], self.color[2], self.color[3], 0.3 * opacity }
end

function ResourceBar.update (self)
  return self
end

function ResourceBar.draw (self, origin_x, origin_y, _, _, opacity)
  opacity = opacity or 1
  local fill_width = self.w * self.resource:check() / self.resource.capacity

  local font = love.graphics.newFont(12)

  local padding = { top = 5, right = 7, bottom = 5, left = 7 }

  local h = self.show_text
    and (font:getHeight() + padding.top + padding.bottom)
    or self.h

  love.graphics.setColor(self:get_fill_color(opacity))
  love.graphics.rectangle("fill", origin_x, origin_y, fill_width, h)
  love.graphics.setColor(self:get_border_color(opacity))
  love.graphics.rectangle("line", origin_x, origin_y, self.w, h)

  if self.show_text then
    local text_pos = Vector2(self.w - padding.right, padding.top)
    local text
    if self.resource.short_name then
      text = string.format("%d %s", self.resource:check(), self.resource.short_name:get())
    else
      text = string.format("%d", self.resource:check())
    end

    local text_graphic = love.graphics.newText(font, text)
    local label_graphic = love.graphics.newText(font, self.label:get_capitalized())
    love.graphics.setColor(1, 1, 1, 1 * opacity)
    love.graphics.draw(label_graphic, origin_x + padding.left, origin_y + padding.top)
    love.graphics.draw(text_graphic, origin_x + text_pos.x - text_graphic:getWidth(), origin_y + text_pos.y)
  end
end

return ResourceBar
