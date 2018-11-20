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

local lume = require("lib.lume")


local Tests = {}
local Vector2 = {}

local function vector_tostring(self)
  return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end

local function newindex(self, key, value)
  error("Attempted to set [" .. tostring(key) .. "] = [" .. tostring(value) .. "] in " .. tostring(self))
end

function Vector2.new (x, y)
  assert(type(x) == "number", "x must be a number, was " .. type(x))
  assert(type(y) == "number", "y must be a number, was " .. type(y))
  return setmetatable(
    {},
    {
      __index = lume.extend(
        {
          x = x,
          y = y,
        },
        Vector2
      ),
      __unm = Vector2.neg,
      __add = Vector2.add,
      __div = Vector2.div,
      __sub = Vector2.sub,
      __mul = Vector2.mul,
      __eq = Vector2.eq,
      __metatable = false,
      __newindex = newindex,
      __tostring = vector_tostring,
    }
  )
end

function Vector2.from_polar (angle, magnitude)
  assert(type(angle) == "number", "angle must be a number, was " .. type(angle))
  assert(type(magnitude) == "number", "magnitude must be a number, was " .. type(magnitude))
  return Vector2.new(math.cos(angle) * magnitude, math.sin(angle) * magnitude)
end
function Tests.from_polar (Vec2, assert_eq, assert_approx)
  assert_eq(Vec2.from_polar(0, 1), Vector2(1, 0))
  assert_approx(Vec2.from_polar(math.pi / 2, 3), Vector2(0, 3))
  assert_approx(Vec2.from_polar(3 / 2 * math.pi, -5), Vector2(0, 5))
  assert_approx(Vec2.from_polar(math.pi / 6, 0.2), Vector2(math.sqrt(3) / 2, 0.5) * 0.2)
end


function Vector2.from_xy (table)
  return Vector2(table.x, table.y)
end

function Tests.zero (Vec2, assert_eq)
  local a = Vec2.zero
  assert_eq(a.x, 0)
  assert_eq(a.y, 0)
  assert(pcall(function () Vec2.zero.x = 5 end) == false, "x is not immutable")
  assert(pcall(function () Vec2.zero.y = 5 end) == false, "y is not immutable")
end

function Tests.immutable (Vec2)
  local a = Vec2(1, 0)
  assert(pcall(function () a.x = 5 end) == false, "x is not immutable")
  assert(pcall(function () a.y = 5 end) == false, "y is not immutable")
end

function Vector2.add (v1, v2)
  return Vector2.new(v1.x + v2.x, v1.y + v2.y)
end
function Tests.add (Vec2, assert_eq)
  assert_eq(Vec2(1, 0) + Vec2(0, 1), Vec2(1, 1))
  assert_eq(Vec2(1, 0) + Vec2(0, -1), Vec2(1, -1))
  assert_eq(Vec2(3, -4) + Vec2(-2, 5), Vec2(1, 1))
end

function Vector2.angle (v1)
  return math.atan2(v1.y, v1.x) % (math.pi * 2)
end
function Tests.angle (Vec2, assert_eq)
  assert_eq(Vec2(1, 0):angle(), 0)
  assert_eq(Vec2(1, 1):angle(), math.pi / 4)
  assert_eq(Vec2(0, 1):angle(), math.pi / 2)
  assert_eq(Vec2(-1, 0):angle(), math.pi)
  assert_eq(Vec2(0, -1):angle(), 3 * math.pi / 2)
end

function Vector2.div (lhs, rhs)
  if "number" == type(lhs) then
    return Vector2.new(rhs.x / lhs, rhs.y / lhs)
  elseif "number" == type(rhs) then
    return Vector2.new(lhs.x / rhs, lhs.y / rhs)
  else
    error("Exactly one parameter must be a number, was: " .. type(lhs) .. " and " .. type(rhs))
  end
end
function Tests.div (Vec2, assert_eq, assert_approx)
  assert_eq(Vec2(1, 0) / 2, Vec2(0.5, 0))
  assert_approx(Vec2(3, -6) / -0.3, Vec2(-10, 20))
end

function Vector2.sub (v1, v2)
  return Vector2.new(v1.x - v2.x, v1.y - v2.y)
end
function Tests.sub (Vec2, assert_eq)
  assert_eq(Vec2(1, 0) - Vec2(0, 1), Vec2(1, -1))
  assert_eq(Vec2(1, 0) - Vec2(0, -1), Vec2(1, 1))
  assert_eq(Vec2(3, -4) - Vec2(-2, 5), Vec2(5, -9))
end

function Vector2.neg (v)
  return Vector2.new(-v.x, -v.y)
end
function Tests.neg (Vec2, assert_eq)
  assert_eq(-Vec2(1, 0), Vec2(-1, 0))
  assert_eq(-Vec2(-1, 0), Vec2(1, 0))
  assert_eq(-Vec2(3, -4), Vec2(-3, 4))
end

function Vector2.mul (lhs, rhs)
  if "number" == type(lhs) then
    return Vector2.new(lhs * rhs.x, lhs * rhs.y)
  elseif "number" == type(rhs) then
    return Vector2.new(rhs * lhs.x, rhs * lhs.y)
  else
    error("Exactly one parameter must be a number, was: " .. type(lhs) .. " and " .. type(rhs))
  end
end
function Tests.mul (Vec2, assert_eq, assert_approx)
  assert_eq(2 * Vec2(1, 0), Vec2(2, 0))
  assert_approx(-0.34 * Vec2(3, -5), Vec2(-1.02, 1.70))
end

function Vector2.elmul (v1, v2)
  return Vector2.new(v1.x * v2.x, v1.y * v2.y)
end
function Tests.elmul (Vec2, assert_eq)
  assert_eq(Vec2(1, 0):elmul(Vec2(0, 1)), Vec2(0, 0))
  assert_eq(Vec2(1, 1):elmul(Vec2(3, 4)), Vec2(3, 4))
  assert_eq(Vec2(-0.5, 3.4):elmul(Vec2(15, 0.2)), Vec2(-7.5, 0.68))
end

function Vector2.dot (v1, v2)
  return v1.x * v2.x + v1.y * v2.y
end
function Tests.dot (Vec2, assert_eq)
  assert_eq(Vec2(1, 0):dot(Vec2(0, 1)), 0)
  assert_eq(Vec2(1, 1):dot(Vec2(0, 1)), 1)
  assert_eq(Vec2(-1, -1):dot(Vec2(0, 1)), -1)
  assert_eq(Vec2(3, -5):dot(Vec2(2, 3)), -9)
end

function Vector2.project_on (v1, v2)
  return v2:normalized() * (v1:dot(v2))
end
function Tests.project_on (Vec2, assert_eq, assert_approx)
  assert_eq(Vec2(1, 0):project_on(Vec2(0, 1)), Vec2(0, 0))
  assert_eq(Vec2(1, 1):project_on(Vec2(0, 1)), Vec2(0, 1))
  assert_eq(Vec2(-1, -1):project_on(Vec2(0, 1)), Vec2(0, -1))
  assert_approx(Vec2(3, -5):project_on(Vec2(2, 3)), Vec2(-4.99230176, -7.48845264))
end

function Vector2.eq (v1, v2)
  return v1.x == v2.x and v1.y == v2.y
end

function Vector2.normalized (v)
  if v.x == 0 and v.y == 0 then
    return v
  else
    return v * (1 / v:mag())
  end
end
function Tests.normalized (Vec2, _)
  local function assert_normal (v)
    assert(v:normalized():mag() - 1 < 1e-6, tostring(v) .. ":normalized():mag() = " .. v:normalized():mag())
    assert(
      v:normalized():angle() == v:angle(),
      string.format("%s bad angle: %f ~= %f", tostring(v), v:normalized():angle(), v:angle())
    )
  end
  for _, v in ipairs{ Vec2(1, 0), Vec2(1000, 13423434), Vec2(-131, 0.5), Vec2(-0.1, -1e6) } do
    assert_normal(v)
  end
end

function Vector2.mag (v)
  return math.sqrt(v:square_mag())
end
function Tests.mag (Vec2, assert_eq)
  assert_eq(Vec2(1, 0):mag(), 1)
  assert_eq(Vec2(3, 4):mag(), 5)
  assert_eq(Vec2(-4, 3):mag(), 5)
end

function Vector2.square_mag (v)
  return v.x^2 + v.y^2
end
function Tests.square_mag (Vec2, assert_eq)
  assert_eq(Vec2(1, 0):square_mag(), 1)
  assert_eq(Vec2(3, 4):square_mag(), 25)
  assert_eq(Vec2(-4, 3):square_mag(), 25)
end

function Vector2.rotate (v, angle)
  return Vector2(
    v.x * math.cos(angle) + v.y * -math.sin(angle),
    v.x * math.sin(angle) + v.y *  math.cos(angle)
  )
end
function Tests.rotate (Vec2, _, assert_approx)
  assert_approx(Vec2(1, 0):rotate(1 * math.pi * 2 / 8), Vec2(1 / math.sqrt(2), 1 / math.sqrt(2)))
  assert_approx(Vec2(1, 0):rotate(2 * math.pi * 2 / 8), Vec2(0, 1))
  assert_approx(Vec2(1, 0):rotate(4 * math.pi * 2 / 8), Vec2(-1, 0))
  assert_approx(Vec2(1, 0):rotate(6 * math.pi * 2 / 8), Vec2(0, -1))
  assert_approx(Vec2(1, 0):rotate(8 * math.pi * 2 / 8), Vec2(1, 0))
end

function Vector2.unpack (v)
  return v.x, v.y
end

local module = setmetatable(
  Vector2,
  {
    __call = function(_, x, y) return Vector2.new(x, y) end,
    __index = {
      zero = Vector2.new(0, 0),
    },
  }
)

for _, test in pairs(Tests) do
  test(
    module,
    function (a, b) return assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end,
    function (v1, v2) return assert((v1 - v2):mag() < 1e-6, tostring(v1) .. " ~= " .. tostring(v2)) end
  )
end

return module
