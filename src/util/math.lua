local util = require("util.table")


local function lerp(from, to, scale)
  return from + (to - from) * scale
end

return util.readonlytable({
  lerp = lerp,
})
