local util = require("util")


local function lerp(from, to, scale)
  return from + (to - from) * scale
end

return util.readonlytable({
  lerp = lerp,
})
