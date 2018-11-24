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

local string_util = require("util.string")


local module

local Entry_methods = {}
local Entry_mt = {
  __call = Entry_methods.get,
  __index = Entry_methods,
}

local function Entry (entry)
  return setmetatable(entry, Entry_mt)
end
function Entry_methods.get (self)
  if type(self[module.lang]) == "function" then
    return self[module.lang](module)
  else
    return self[module.lang]
  end
end
function Entry_methods.get_capitalized (self)
  return string_util.capitalize(self:get())
end

local function ControlEntry (entry)
  return setmetatable(
    { entry = Entry(entry) },
    { __index = {
      get = function (self)
        return "[" .. self.entry:get() .. "]"
      end,
    }}
  )
end

local controls = {
  ["e"] = ControlEntry{ en = "E", sv = "E" },
  ["g"] = ControlEntry{ en = "G", sv = "G" },
  ["left"] = ControlEntry{ en = "LEFT ARROW", sv = "VÄNSTERPIL" },
  ["r"] = ControlEntry{ en = "R", sv = "R" },
  ["return"] = ControlEntry{ en = "RETURN", sv = "RETUR" },
  ["right"] = ControlEntry{ en = "RIGHT ARROW", sv = "HÖGERPIL" },
  ["space"] = ControlEntry{ en = "SPACE", sv = "BLANKSTEG" },
  ["up"] = ControlEntry{ en = "UP ARROW", sv = "UPPPIL" },
}

module = {
  lang = "sv",

  controls = controls,

  drone = {
    name = Entry{ en = "drone", sv = "drönare" },
    module = {
      disguise = {
        name = Entry{ en = "disguise", sv = "förklädnad" },
        description = Entry{
          en = "Spend battery charge to make the drone blend into the environment.",
          sv = "Spendera batteri för att få drönaren att smälta in i omgivningen.",
        },
      },
      hover = {
        name = Entry{ en = "hover", sv = "svävare" },
        description = Entry{
          en = function (m) return "Spend " .. m.resources.hover_fuel.name.get() .. " to fly." end,
          sv = function (m) return "Spendera " .. m.resources.hover_fuel.name.get() .. " för att flyga." end,
        },
      },
      jump = {
        name = Entry{ en = "catapult", sv = "katapult" },
        description = Entry{
          en = function (m) return "Spend 10 " .. m.resources.battery.unit_name.get() .. " to leap upward." end,
          sv = function (m) return "Spendera 10 " .. m.resources.battery.unit_name.get() .. " för att hoppa." end,
        },
      },
      reactor = {
        name = Entry{ en = "reactor", sv = "reaktor" },
        description = Entry{
          en = "Slowly recharges battery.",
          sv = "Laddar långsamt upp batteriet.",
        },
      },
    },
  },

  resources = {
    battery = {
      name = Entry{ en = "battery", sv = "batteri" },
      unit_name = Entry{ en = "kJ", sv = "kJ" },
    },
    hover_fuel = {
      name = Entry{ en = "rocket fuel", sv = "raketbränsle" },
      unit_name = Entry{ en = "kg", sv = "kg" },
    },
  },

  title_screen = {
    press_start = Entry{
      en = function (m) return "Press " .. m.controls["return"]:get() end,
      sv = function (m) return "Tryck " .. m.controls["return"]:get() end,
    },
  },
}

return module
