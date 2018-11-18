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

local texts = require("lang.text").title_screen


local title_image

love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }

local Scene = {}
local Scene_mt = { __index = Scene }

local function init ()
  title_image = love.graphics.newImage("resources/img/title/title.png")
end

init()

function Scene.new (on_start)
  local music = love.audio.newSource("resources/audio/main-theme.mp3", love.audio.SourceType.static)
  music:setLooping(true)

  return setmetatable(
    {
      music = music,
      on_start = function (self)
        self.music:stop()
        return on_start()
      end,
    },
    Scene_mt
  )
end

function Scene.enter (self)
  self.time = 0
  if not self.music:isPlaying() then self.music:play() end
end

function Scene.keypressed (self, key)
  if key == "return" then
    self:on_start()
  elseif key == "escape" then
    self:on_exit()
  end
end

function Scene.keyreleased ()
end

function Scene.update (self, dt)
  self.time = self.time + dt
end

function Scene.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(
    title_image,
    W / 2 - title_image:getWidth() / 2,
    H * (1 - 1 / 1.618) - title_image:getHeight() / 2 + math.sin(self.time * 2 * math.pi / 10) * 10
  )

  local press_return_delay = 3
  if self.time > press_return_delay then
    local text = love.graphics.newText(love.graphics.newFont(12), texts.press_start:get())
    local t = (self.time - press_return_delay) * 2 * math.pi / 5
    love.graphics.setColor(0.8, 0.8, 0.8, 0.5 - math.cos(t) * 0.4)
    love.graphics.draw(text, W / 2 - text:getWidth() / 2, H / 1.618 - text:getHeight() / 2)
  end
end

return Scene
