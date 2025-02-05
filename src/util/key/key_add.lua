
local table_unpack = require("src.util.polyfill.table.unpack")

---@param key LuaX.Key
---@param value number
---@return LuaX.Key
local function key_add(key, value)
    local copy = { table_unpack(key) }

    table.insert(copy, value)

    return copy
end

return key_add