local util = require("util.table")


local function isFinite(a)
  return a < math.huge and a > -math.huge
end

return util.readonlytable({
  isFinite = isFinite,
})
