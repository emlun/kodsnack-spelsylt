local Vector2 = {}

local function vector_tostring(self)
  return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end

local function newindex(self, key, value)
  error("Attempted to set [" .. tostring(key) .. "] = [" .. tostring(value) .. "] in " .. tostring(self))
end

function Vector2.new (x, y)
  return setmetatable(
    {},
    {
      __index = {
        x = assert(x),
        y = assert(y),
        normalized = Vector2.normalized,
        mag = Vector2.mag,
      },
      __unm = Vector2.neg,
      __add = Vector2.add,
      __sub = Vector2.sub,
      __mul = Vector2.mul,
      __eq = Vector2.eq,
      __metatable = false,
      __newindex = newindex,
      __tostring = vector_tostring,
    }
  )
end

function Vector2.add (v1, v2)
  return Vector2.new(v1.x + v2.x, v1.y + v2.y)
end

function Vector2.sub (v1, v2)
  return Vector2.new(v1.x - v2.x, v1.y - v2.y)
end

function Vector2.neg (v)
  return Vector2.new(-v.x, -v.y)
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

function Vector2.mag (v)
  return math.sqrt(v.x^2 + v.y^2)
end

return setmetatable(
  Vector2,
  {
    __call = function(_, x, y) return Vector2.new(x, y) end,
    __index = {
      zero = Vector2.new(0, 0),
    },
  }
)
