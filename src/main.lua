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

package.path = package.path .. ";./src/?.lua"
local Vector2 = require("util.Vector2")
local mymath = require("util.math")

local canvas_size = Vector2(600, 400)
local camera_pos = Vector2(0, 0)
local camera_scale = 1
local target_camera_pos = camera_pos
local target_camera_scale = camera_scale
local time = 0

love.graphics.DrawMode = { fill = "fill", line = "line" }

function love.load()
  canvas_size = Vector2(love.graphics.getDimensions())
  math.randomseed(os.time())
end

function love.update(dt)
  canvas_size = Vector2(love.graphics.getDimensions())
  time = time + dt

  target_camera_pos = Vector2.zero
  target_camera_scale = 1

  camera_pos = mymath.lerp(camera_pos, target_camera_pos, 0.8 * dt)
  camera_scale = mymath.lerp(camera_scale, target_camera_scale, 0.8 * dt)

end

local function world_to_view_pos(pos, camera_pos, camera_scale, canvas_size)
  return vadd(vmul(camera_scale, vsub(pos, camera_pos)), vmul(0.5, canvas_size))
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle(love.graphics.DrawMode.fill, 0, canvas_size.y * 2 / 3, canvas_size.x, canvas_size.y)
end
