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

local Icons = require("sprites.Icons")
local texts = require("lang.text")


local Self = {}
local Self_mt = { __index = Self }


Self.font = love.graphics.newFont(12)
Self.icon_margin = Icons.height / 2
Self.text_margin = Icons.width

function Self.new ()
  return setmetatable(
    {},
    Self_mt
  )
end

function Self.draw (self, drone, origin_x, origin_y, _, _, opacity)
  opacity = opacity or 1

  local control_text_x = 0

  for i, module in ipairs(drone.modules) do
    local spritesheet, sprite = module.icon:get_sprite()

    local x = origin_x
    local y = origin_y + (i - 1) * (self.icon_margin + Icons.height)

    love.graphics.setColor(1, 1, 1, opacity)
    love.graphics.draw(
      spritesheet,
      sprite,
      x, y,
      0,
      1,
      1
    )

    local name_text = love.graphics.newText(self.font, tostring(module.name:get_capitalized()))

    local icon_center_y = y + Icons.height / 2
    local text_x = x + Icons.width + self.icon_margin
    local text_y = icon_center_y - name_text:getHeight() / 2

    love.graphics.setColor(1, 1, 1, opacity)
    love.graphics.draw(name_text, text_x, text_y)

    control_text_x = math.max(control_text_x, text_x + name_text:getWidth() + self.text_margin)
  end

  for i, module in ipairs(drone.modules) do
    local y = origin_y + (i - 1) * (self.icon_margin + Icons.height)
    local icon_center_y = y + Icons.height / 2

    if module.control then
      local control_text = love.graphics.newText(
        self.font,
        "[" .. texts.controls[drone.controller[module.control]]:get() .. "]"
      )
      local text_y = icon_center_y - control_text:getHeight() / 2

      love.graphics.setColor(1, 1, 1, opacity)
      love.graphics.draw(control_text, control_text_x, text_y)
    end
  end
end

return Self
