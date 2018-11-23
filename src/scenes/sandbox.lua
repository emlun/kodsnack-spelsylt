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

local Disguise = require("modules.Disguise")
local Drone = require("entities.Drone")
local Hover = require("modules.Hover")
local Jump = require("modules.Jump")
local PlayScene = require("scenes.PlayScene")
local Reactor = require("modules.Reactor")
local SophiaSprite = require("sprites.SophiaAll")
local Vector2 = require("util.Vector2")


love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }


local sprite = SophiaSprite.new(2)

local Super_mt = { __index = PlayScene }

local Scene = setmetatable({}, Super_mt)
local Scene_mt = { __index = Scene }

Scene.music = love.audio.newSource(
  "resources/audio/Super Metroid Resynthesized - Vol I (mp3 320)/13 Small Boss Confrontation.mp3",
  --"resources/audio/Super Metroid Resynthesized - Vol I (mp3 320)/14 Item Room.mp3",
  love.audio.SourceType.static
)
Scene.music:setLooping(true)
Scene.music:setVolume(0.3)

function Scene.new (controller)
  return setmetatable(
    {
      controller = controller,
    },
    Scene_mt
  )
end

function Scene.generate_module_loadout ()
  local modules = {}
  for _, class in ipairs({ Disguise, Hover, Jump, Reactor }) do
    if math.random() > 0.5 then
      table.insert(modules, class.new())
    end
  end
  return modules
end

function Scene.enter (self)
  local map = sti("maps/sandbox.lua", { "bump" })

  local drones = {}
  for _, object in pairs(map.objects) do
    if object.type == "spawn-player" and object.properties.index then
      local drone = Drone.new(
        object.properties.index,
        #drones == 0,
        sprite,
        self.controller,
        self.generate_module_loadout()
      )
      drone.position = Vector2(object.x, object.y)
      drones[object.properties.index] = drone
    end
  end

  if not self.music:isPlaying() then
    self.music:play()
  end

  print("Cal super-enter")
  Super_mt.__index.enter(self, drones, map)
end

function Scene.exit (self)
  self.music:stop()
  if self.on_exit then
    self:on_exit()
  end
end

function Scene.keypressed (self, key)
  if key == "escape" then
    self:exit()
  else
    Super_mt.__index.keypressed(self, key)
  end
end

return Scene
