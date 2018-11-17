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

-- luacheck: globals love music

package.path = package.path .. ";./src/?.lua"

-- local bump = require("lib.bump")
local lovebird = require("lib.lovebird")
local lurker = require("lib.lurker")

local SandboxScene = require("scenes.sandbox")
local TitleScreen = require("scenes.title")

local controller = {
  jump = "space",
  left = "left",
  right = "right",
}

love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }

local scenes = {}
local current_scene

scenes.sandbox = SandboxScene.new(controller)
scenes.title = TitleScreen.new(function () current_scene = scenes.sandbox end)

current_scene = scenes.title

function love.keypressed(key, scancode, isrepeat) -- luacheck: no unused args
  current_scene:keypressed(key)
end

function love.keyreleased(key, scancode) -- luacheck: no unused args
  current_scene:keyreleased(key)
end

function love.update(dt)
  lovebird.update()
  lurker.update()

  current_scene:update(dt)
end

function love.draw()
  current_scene:draw()
end
