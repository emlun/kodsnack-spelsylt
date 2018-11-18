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


local ResourceBar = require("hud.ResourceBar")
local Vector2 = require("util.Vector2")


local Self = {}
local DroneStatusBar_mt = { __index = Self }

Self.box_padding = 5
Self.box_content_width = 90
Self.box_content_height = 20
Self.bar_spacing = 2
Self.box_height = Self.box_content_height + 2 * Self.box_padding + Self.bar_spacing
Self.box_circle_radius = Self.box_height / 2
Self.box_width = Self.box_content_width + 2 * Self.box_padding + Self.box_circle_radius

function Self.new (drone)
  local battery_bar = ResourceBar.new(
    drone.battery,
    Self.box_content_width,
    Self.box_content_height / 2
  )

  local hover_fuel_bar = ResourceBar.new(
    drone.hover_fuel,
    Self.box_content_width,
    Self.box_content_height / 2,
    { color = { 1, 0.5, 0 } }
  )

  return setmetatable(
    {
      battery_bar = battery_bar,
      hover_fuel_bar = hover_fuel_bar,
      drone = drone,
    },
    DroneStatusBar_mt
  )
end

function Self.draw (self, camera)
  local x, y = self.drone.position:unpack()
  local w, h = self.drone.sprite:get_hitbox_dimensions()

  local margin = 10

  local text_top = y + h + margin
  local center_x = x + w / 2

  local box_left = center_x - self.box_width / 2
  local box_top = text_top
  local box_center_y = box_top + self.box_height / 2
  local box_content_x = box_left + self.box_circle_radius + self.box_padding
  local box_content_y = box_top + self.box_padding

  local opacity_factor = self.drone.is_active and 1 or 0.5
  local text_color = { 1, 1, 1, 0.8 }
  local border_color =
    self.drone.is_active
      and { 1, 1, 1, 0.8 * opacity_factor }
      or { 0.2, 0.7, 0.2, 0.8 * opacity_factor }
  local background_color = { 0, 0.2, 0, 0.5 * opacity_factor }

  local id_font = love.graphics.newFont(16)

  local id_text = love.graphics.newText(id_font, tostring(self.drone.id))

  local rect_x, rect_y, rect_w, rect_h = camera:project_rect(box_left, box_top, self.box_width, self.box_height)
  local circle_x, circle_y = camera:project(Vector2(box_left, box_center_y)):unpack()

  local function mask_circle ()
    love.graphics.circle("line", circle_x, circle_y, self.box_circle_radius)
    love.graphics.circle("fill", circle_x, circle_y, self.box_circle_radius)
  end
  love.graphics.stencil(mask_circle, "replace", 1)
  love.graphics.setStencilTest("equal", 0)

  love.graphics.setColor(unpack(background_color))
  love.graphics.rectangle("fill", rect_x, rect_y, rect_w, rect_h)
  love.graphics.setColor(unpack(border_color))
  love.graphics.line(
    rect_x, rect_y,
    rect_x + rect_w, rect_y,
    rect_x + rect_w, rect_y + rect_h,
    rect_x, rect_y + rect_h
  )

  love.graphics.setStencilTest()

  love.graphics.setColor(unpack(background_color))
  love.graphics.circle("fill", circle_x, circle_y, self.box_circle_radius)
  love.graphics.setColor(unpack(border_color))
  love.graphics.circle("line", circle_x, circle_y, self.box_circle_radius)

  love.graphics.setColor(unpack(text_color))
  love.graphics.draw(id_text, circle_x - id_text:getWidth() / 2, circle_y - id_text:getHeight() / 2)

  local battery_bar_x, battery_bar_y = camera:project(Vector2(box_content_x, box_content_y)):unpack()
  local hover_fuel_bar_x, hover_fuel_bar_y = battery_bar_x, battery_bar_y + self.battery_bar.h + self.bar_spacing

  self.battery_bar:draw(love.graphics, battery_bar_x, battery_bar_y, nil, nil, opacity_factor)
  self.hover_fuel_bar:draw(love.graphics, hover_fuel_bar_x, hover_fuel_bar_y, nil, nil, opacity_factor)
end

return Self
