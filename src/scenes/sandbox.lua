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

local bump = require("lib.bump")
local lume = require("lib.lume")
local sti = require("lib.sti.init")

local Camera = require("camera")
local Hud = require("hud.Hud")
local Drone = require("Drone")
local DroneStatusBar = require("hud.DroneStatusBar")
local ResourceBar = require("hud.ResourceBar")
local SophiaSprite = require("sprites.Sophia")
local Vector2 = require("util.Vector2")
local mydebug = require("src.debug")
local texts = require("lang.text")


love.audio.SourceType = { static = "static", stream = "stream" }
love.graphics.DrawMode = { fill = "fill", line = "line" }


local klirr = {
  love.audio.newSource("resources/audio/klirr1.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr2.wav", love.audio.SourceType.static),
  love.audio.newSource("resources/audio/klirr3.wav", love.audio.SourceType.static),
}
local sprite = SophiaSprite.new(2)


local Scene = {}
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

function Scene.enter (self)
  local world = bump.newWorld()

  local active_drone = 1
  local drones = {
    Drone.new(1, true, sprite, self.controller, { jump = klirr }),
    Drone.new(2, false, sprite, self.controller, { jump = klirr }),
    Drone.new(3, false, sprite, self.controller, { jump = klirr }),
    Drone.new(4, false, sprite, self.controller, { jump = klirr }),
  }

  local hud = Hud.new()
  local map = sti("maps/sandbox.lua", { "bump" })
  map:bump_init(world)

  if not self.music:isPlaying() then
    self.music:play()
  end

  local battery_bar = ResourceBar.new(
    drones[active_drone].battery,
    100,
    20,
    {
      show_text = true,
      label = texts.resources.battery.name,
    }
  )
  hud:add(battery_bar, 30, 30)

  for _, object in pairs(map.objects) do
    if object.type == "spawn-player" and object.properties.index then
      if drones[object.properties.index] then
        local drone = drones[object.properties.index]
        drone.position = Vector2(object.x, object.y)
        world:add(drone, drone:get_hitbox())
        drone:pull_to_ground(world)
      end
    end
  end

  self.active_drone = active_drone
  self.battery_bar = battery_bar
  self.camera = Camera.new(Vector2(love.graphics.getDimensions()), drones[active_drone].position, 1)
  self.drones = drones
  self.drone_status_bars = lume.map(drones, DroneStatusBar.new)
  self.hud = hud
  self.map = map
  self.time = 0
  self.world = world
end

function Scene.exit (self)
  self.music:stop()
  if self.on_exit then
    self:on_exit()
  end
end

function Scene.get_active_drone (self)
  return self.drones[self.active_drone]
end

function Scene.switch_drone (self, new_index)
  self:get_active_drone().is_active = false
  local new_drone = self.drones[new_index]
  self.battery_bar.resource = new_drone.battery
  self.active_drone = new_index
  new_drone.is_active = true
end

function Scene.keypressed (self, key)
  if key == "escape" then
    self:exit()
  elseif key >= "1" and key <= "4" then
    self:switch_drone(tonumber(key))
  else
    self:get_active_drone():keypressed(key, self.world)
  end
end

function Scene.keyreleased (self, key)
  self:get_active_drone():keyreleased(key, self.time, self.world)
end

function Scene.update (self, dt)
  self.time = self.time + dt

  self.map:update(dt)

  for _, drone in ipairs(self.drones) do
    drone:update(dt, self.world)
  end

  self.map:resize(love.graphics.getDimensions())
  self.camera:set_dimensions(Vector2(love.graphics.getDimensions()))
  self.camera:move_to(
    self:get_active_drone().position
      + Vector2(self:get_active_drone().sprite:get_hitbox_dimensions()) / 2
  )
end

function Scene.draw (self)
  local H = love.graphics.getHeight()
  local W = love.graphics.getWidth()

  local view_origin = self.camera:project(Vector2.zero)
  love.graphics.setColor(1, 1, 1)
  self.map:draw(view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

  if mydebug.hitboxes then
    love.graphics.setColor(1, 1, 1)
    self.map:bump_draw(self.world, view_origin.x, view_origin.y, self.camera.scale, self.camera.scale)

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(W / 2, H / 2 - 10, W / 2, H / 2 + 10)
    love.graphics.line(W / 2 - 10, H / 2, W / 2 + 10, H / 2)
  end

  for _, item in ipairs(self.world:getItems()) do
    if item.draw then
      item:draw(self.camera)
    elseif item.rect then
      item.rect = { -1000, 0, 2000, self.world.cellSize }
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle(
        love.graphics.DrawMode.fill,
        self.camera:project_rect(unpack(item.rect))
      )
    end
  end

  for _, item in ipairs(self.drone_status_bars) do
    item:draw(self.camera)
  end

  self.hud:draw(love.graphics, self.time)

end

return Scene
