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


local Resource = {}
local Resource_mt = { __index = Resource }

function Resource.new (capacity, short_name)
  return setmetatable(
    {
      capacity = assert(capacity),
      short_name = short_name,
      value = capacity,
    },
    Resource_mt
  )
end

function Resource.check (self)
  return self.value
end

function Resource.consume (self, amount)
  assert(amount >= 0, "amount must be nonnegative")
  local value_before = self.value
  self.value = math.max(0, self.value - amount)
  return value_before - self.value
end

function Resource.add (self, amount)
  assert(amount >= 0, "amount must be nonnegative")
  local value_before = self.value
  self.value = math.min(self.capacity, self.value + amount)
  return self.value - value_before
end

return Resource
