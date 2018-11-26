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

local sti = require("lib.sti.init")

local Drone = require("entities.Drone")
local PlayScene = require("scenes.PlayScene")
local SophiaSprite = require("sprites.SophiaAll")
local Vector2 = require("util.Vector2")


local sprite = SophiaSprite.new(2)

local Super_mt = { __index = PlayScene }

local Self = setmetatable({}, Super_mt)
local Self_mt = { __index = Self }

Self.music = love.audio.newSource(
  "resources/audio/Super Metroid Resynthesized - Vol I (mp3 320)/12 Brinstar - Overgrown.mp3",
  love.audio.SourceType.static
)
Self.music:setLooping(true)
Self.music:setVolume(0.3)

function Self.new (controller)
  return setmetatable(
    {
      controller = controller,
    },
    Self_mt
  )
end

function Self.enter (self)
  local map = sti("maps/tutorial-finite.lua", { "bump" })

  local drones = {}
  for _, object in pairs(map.objects) do
    if object.type == "spawn-player" and object.properties.index then
      local drone = Drone.new(
        object.properties.index,
        #drones == 0,
        sprite,
        self.controller,
        {}
      )
      drone.position = Vector2(object.x, object.y)
      drones[object.properties.index] = drone
    end
  end

  if not self.music:isPlaying() then
    self.music:play()
  end

  Super_mt.__index.enter(self, drones, map)
end

function Self.exit (self)
  self.music:stop()
  if self.on_exit then
    self:on_exit()
  end
end

function Self.keypressed (self, key)
  if key == "escape" then
    self:exit()
  else
    Super_mt.__index.keypressed(self, key)
  end
end

return Self
