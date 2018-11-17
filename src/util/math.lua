local module = {}

function module.isFinite (a)
  return a < math.huge and a > -math.huge
end

return module
