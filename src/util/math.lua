local util = require("util.table")


local function isFinite(a)
  return a < math.huge and a > -math.huge
end

local function lerp(from, to, scale)
  return from + (to - from) * scale
end

return util.readonlytable({
  isFinite = isFinite,
  lerp = lerp,
})
