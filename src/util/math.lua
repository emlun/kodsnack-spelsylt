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

local module = {}

function module.is_finite (a)
  return a < math.huge and a > -math.huge
end

function module.min_by (items, metric)
  local min_key, min_metric = nil, math.huge
  for key, value in pairs(items) do
    local m = metric(value)
    if m < min_metric then
      min_metric = m
      min_key = key
    end
  end
  return items[min_key], min_key, min_metric
end

function module.sign (a)
  return a > 0 and 1 or a < 0 and -1 or 0
end

return module
