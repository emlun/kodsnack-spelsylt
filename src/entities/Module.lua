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

local Entity = require("entities.Entity")
local Vector2 = require("util.Vector2")

local Super_mt = { __index = Entity }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.type = "module"
Self.scale = 2
Self.oscillation_amplitude = 5
Self.oscillation_period = 4

function Self.new (module, position)
  return setmetatable(
    {
      module = assert(module),
      position = assert(position),
      time = math.random(0, Self.oscillation_period),
    },
    Self_mt
  )
end

function Self.get_hitbox (self)
  return self.position.x, self.position.y, self.module.icon.width * self.scale, self.module.icon.height * self.scale
end

function Self.update (self, dt)
  self.time = self.time + dt
end

function Self.draw (self, camera)
  local spritesheet, sprite = self.module.icon:get_sprite()

  local view_pos = camera:project(
    self.position
      + Vector2(0, 1)
        * self.oscillation_amplitude * math.sin(self.time * 2 * math.pi / self.oscillation_period)
  )

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    spritesheet,
    sprite,
    view_pos.x,
    view_pos.y,
    0,
    self.scale,
    self.scale
  )

  local center_x = view_pos.x + ({sprite:getViewport()})[3] / 2 * self.scale

  local font = love.graphics.newFont(12)
  local text = love.graphics.newText(font, tostring(self.module.name:get_capitalized()))
  local text_opacity = 1 - ((self.position - camera.pos):mag() / 200)^2
  if text_opacity < 0.05 then text_opacity = 0 end
  love.graphics.setColor(0.9, 0.8, 0, text_opacity)
  love.graphics.draw(text, center_x - text:getWidth() / 2, view_pos.y - text:getHeight() * 1.5)

  self:draw_hitbox(camera)
end

return Self
