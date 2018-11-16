local function readonlytable(table)
  return setmetatable(
    {},
    {
      __index = table,
      __newindex = function(t, key, value)
        error(
          "Attempted to set [" .. tostring(key) .. " = " .. tostring(value)
          .. "] in readonly table " .. tostring(t)
        )
      end,
      __metatable = false,
    }
  )
end

return readonlytable({
  readonlytable = readonlytable,
})
