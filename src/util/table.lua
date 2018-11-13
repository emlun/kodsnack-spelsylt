local function readonlytable(table)
  return setmetatable(
    {},
    {
      __index = table,
      __newindex = function(table, key, value)
        error("Attempted to set [" .. tostring(key) .. " = " .. tostring(value) .. "] in readonly table " .. tostring(table))
      end,
      __metatable = false,
    }
  )
end

return readonlytable({
  readonlytable = readonlytable,
})
