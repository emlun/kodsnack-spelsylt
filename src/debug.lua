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

local module = {
  hitboxes = false,
  keypress = false,
}

function module.keypressed (key, scancode, isrepeat)
  if module.keypress then
    print(string.format("keypressed: %s\tscancode: %s\tisrepeat: %s", key, scancode, isrepeat))
  end

  if scancode == "k" then
    module.keypress = not module.keypress
  end
  if scancode == "h" then
    module.hitboxes = not module.hitboxes
  end
end

return module
