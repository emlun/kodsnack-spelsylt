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

local lovebird = require("lib.lovebird")
local lurker = require("lib.lurker")

love.graphics.setDefaultFilter("nearest", "nearest")

local SandboxScene = require("scenes.sandbox")
local TitleScreen = require("scenes.title")
local TutorialScene = require("scenes.tutorial")
local mydebug = require("src.debug")
local texts = require("lang.text")

local controller = {
  disguise = "g",
  drop_module = "r",
  hover = "space",
  jump = "up",
  left = "left",
  right = "right",
  take_item = "e",
}

require("local-init")()

love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }

local scenes = {}
local current_scene

local function set_scene (scene)
  current_scene = scene
  if scene.enter then
    scene:enter()
  end
end

scenes.sandbox = SandboxScene.new(controller)
scenes.tutorial = TutorialScene.new(controller)
scenes.title = TitleScreen.new(function () set_scene(scenes.tutorial) end)
scenes.title.on_exit = function() love.event.quit() end
scenes.sandbox.on_exit = function() set_scene(scenes.title) end
scenes.tutorial.on_exit = function() set_scene(scenes.title) end

set_scene(scenes.title)

function love.keypressed(key, scancode, isrepeat) -- luacheck: no unused args
  mydebug.keypressed(key, scancode, isrepeat)

  if scancode == "l" then
    if texts.lang == "en" then
      texts.lang = "sv"
    else
      texts.lang = "en"
    end
  end
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
