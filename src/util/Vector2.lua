local new

local function add(v1, v2)
  return new(v1.x + v2.x, v1.y + v2.y)
end

local function sub(v1, v2)
  return new(v1.x - v2.x, v1.y - v2.y)
end

local function neg(v)
  return new(-v.x, -v.y)
end

local function mul(lhs, rhs)
  if "number" == type(lhs) then
    return new(lhs * rhs.x, lhs * rhs.y)
  elseif "number" == type(rhs) then
    return new(rhs * lhs.x, rhs * lhs.y)
  else
    error("Exactly one parameter must be a number, was: " .. type(lhs) .. " and " .. type(rhs))
  end
end

local function eq(v1, v2)
  return v1.x == v2.x and v1.y == v2.y
end

local function normalized(v)
  if v.x == 0 and v.y == 0 then
    return v
  else
    return v * (1 / v:mag())
  end
end

local function mag(v)
  return math.sqrt(v.x^2 + v.y^2)
end

local function vector_tostring(self)
  return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end

local function newindex(self, key, value)
  error("Attempted to set [" .. tostring(key) .. "] = [" .. tostring(value) .. "] in " .. tostring(self))
end

new = function (x, y)
  return setmetatable(
    {},
    {
      __index = {
        x = x,
        y = y,
        normalized = normalized,
        mag = mag,
      },
      __unm = neg,
      __add = add,
      __sub = sub,
      __mul = mul,
      __eq = eq,
      __metatable = false,
      __newindex = newindex,
      __tostring = vector_tostring,
    }
  )
end

return setmetatable(
  {},
  {
    __call = function(self, x, y) return new(x, y) end,
    __index = {
      zero = new(0, 0),
    },
    __newindex = function()
      error("Cannot modify Vector2 module.")
    end,
  }
)
